{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit
    (import ../variables.nix)
    wallpaper_img
    wallpaper_img_vertical
    ;

  system = pkgs.stdenv.hostPlatform.system;
  wallpaperDirectory = "${config.home.homeDirectory}/Pictures/Wallpapers";
  pluginSource = "https://github.com/noctalia-dev/noctalia-plugins";
  enabledPlugins = [
    "web-search"
    "file-search"
    "model-usage"
    "workspace-overview"
    "screen-recorder"
    "timer"
    "dmenu"
    "clipboard"
  ];

  pluginStates = lib.genAttrs enabledPlugins (_: {
    enabled = true;
    sourceUrl = pluginSource;
  });

  noctaliaPackage = inputs.noctalia.packages.${system}.default.override {
    extraPackages = with pkgs; [
      fd
      gpu-screen-recorder
      jq
    ];
  };

  restartNoctalia = pkgs.writeShellScriptBin "restart.noctalia" ''
    set -euo pipefail

    list_target_pids() {
      ${pkgs.procps}/bin/ps -eo pid=,cmd= | while read -r pid cmd; do
        [ "$pid" = "$$" ] && continue

        if [[ "$cmd" =~ (^|/)noctalia-shell([[:space:]]|$) ]] ||
           [[ "$cmd" =~ (^|[[:space:]])(qs|quickshell)([[:space:]]).*-c(=|[[:space:]])?noctalia-shell([[:space:]]|$) ]]; then
          printf '%s\n' "$pid"
        fi
      done
    }

    terminate_targets() {
      mapfile -t pids < <(list_target_pids || true)
      if ((''${#pids[@]} > 0)); then
        kill -TERM "''${pids[@]}" 2>/dev/null || true
      fi

      for _ in {1..15}; do
        mapfile -t left < <(list_target_pids || true)
        ((''${#left[@]} == 0)) && return
        ${pkgs.coreutils}/bin/sleep 0.2
      done

      if ((''${#left[@]} > 0)); then
        kill -KILL "''${left[@]}" 2>/dev/null || true
      fi
    }

    start_noctalia() {
      ${pkgs.util-linux}/bin/setsid -f ${noctaliaPackage}/bin/noctalia-shell >/dev/null 2>&1
    }

    terminate_targets
    start_noctalia
  '';

  setNoctaliaWallpapers = pkgs.writeShellScriptBin "set-noctalia-wallpapers" ''
    set -euo pipefail

    wait_for_noctalia() {
      for _ in {1..50}; do
        if ${noctaliaPackage}/bin/noctalia-shell ipc call wallpaper get all >/dev/null 2>&1; then
          return 0
        fi
        ${pkgs.coreutils}/bin/sleep 0.2
      done
      echo "set-noctalia-wallpapers: noctalia-shell IPC unavailable" >&2
      exit 1
    }

    wait_for_noctalia
    ${noctaliaPackage}/bin/noctalia-shell ipc call wallpaper set "${wallpaper_img}" DP-1
    ${noctaliaPackage}/bin/noctalia-shell ipc call wallpaper set "${wallpaper_img_vertical}" DP-2
  '';
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = false;
    package = noctaliaPackage;

    settings = {
      general = {
        showChangelogOnStartup = false;
        lockOnSuspend = true;
      };

      bar = {
        position = "top";
        displayMode = "always_visible";
        widgets = {
          left = [
            {id = "Launcher";}
            {id = "Workspace";}
            {id = "ActiveWindow";}
          ];
          center = [
            {id = "MediaMini";}
          ];
          right = [
            {id = "Tray";}
            {id = "Volume";}
            {id = "Bluetooth";}
            {id = "Clock";}
            {id = "NotificationHistory";}
            {id = "ControlCenter";}
          ];
        };
      };

      colorSchemes = {
        darkMode = true;
        useWallpaperColors = false;
      };

      dock.enabled = false;

      idle = {
        enabled = true;
        lockTimeout = 900;
        screenOffTimeout = 1200;
        suspendTimeout = 0;
      };

      wallpaper = {
        enabled = true;
        directory = wallpaperDirectory;
        enableMultiMonitorDirectories = true;
        setWallpaperOnAllMonitors = false;
        monitorDirectories = [
          {
            name = "DP-1";
            directory = wallpaperDirectory;
          }
          {
            name = "DP-2";
            directory = wallpaperDirectory;
          }
        ];
      };
    };

    plugins = {
      version = 2;
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = pluginSource;
        }
      ];
      states = pluginStates;
    };
  };

  home.packages = [
    restartNoctalia
    setNoctaliaWallpapers
  ];
}
