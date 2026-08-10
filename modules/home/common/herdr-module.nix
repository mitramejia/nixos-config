{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption;
  cfg = config.programs.herdr;
  tomlFormat = pkgs.formats.toml {};
  settingsFile = tomlFormat.generate "herdr-config.toml" cfg.settings;
  binPath =
    if cfg.package == null
    then "herdr"
    else lib.getExe cfg.package;
in {
  options.programs.herdr = {
    enable = lib.mkEnableOption "Herdr";

    package = lib.mkPackageOption pkgs "herdr" {nullable = true;};

    settings = mkOption {
      inherit (tomlFormat) type;
      default = {};
      example = {
        onboarding = false;
        terminal = {
          default_shell = "nu";
          shell_mode = "auto";
          new_cwd = "follow";
        };
        theme = {
          name = "catppuccin";
          auto_switch = true;
          light_name = "catppuccin-latte";
          dark_name = "catppuccin";
        };
        ui = {
          sidebar_width = 32;
          agent_panel_sort = "priority";
          toast.delivery = "herdr";
          sound.enabled = true;
        };
        keys = {
          prefix = "ctrl+b";
          command = [
            {
              key = "prefix+l";
              type = "plugin_action";
              command = "example.layout.apply";
              description = "apply layout";
            }
          ];
        };
      };
      description = ''
        Configuration copied to
        {file}`$XDG_CONFIG_HOME/herdr/config.toml`. Herdr persists UI
        preferences in this file, so it is kept as a user-writable regular
        file rather than linked from the Nix store. Declarative settings are
        reapplied whenever Home Manager activates. See
        <https://herdr.dev/docs/configuration/> for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [cfg.package];

    home.activation.installHerdrConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
      configPath="${config.xdg.configHome}/herdr/config.toml"
      persistedAgentPanelSort=""

      if [ -f "$configPath" ] && ! ${pkgs.gnugrep}/bin/grep -q "^[[:space:]]*agent_panel_sort[[:space:]]*=" ${settingsFile}; then
        persistedAgentPanelSort="$(${pkgs.gnused}/bin/sed -nE 's/^[[:space:]]*agent_panel_sort[[:space:]]*=[[:space:]]*"(spaces|priority)"[[:space:]]*$/\1/p' "$configPath")"
      fi

      if [ -L "$configPath" ]; then
        linkTarget="$(${pkgs.coreutils}/bin/readlink -f "$configPath")"
        case "$linkTarget" in
          ${builtins.storeDir}/*)
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -- "$configPath"
            ;;
          *)
            echo "Refusing to replace non-store Herdr config symlink: $configPath -> $linkTarget" >&2
            exit 1
            ;;
        esac
      fi

      if [ ! -e "$configPath" ] || ! ${pkgs.diffutils}/bin/cmp -s ${settingsFile} "$configPath"; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm644 ${settingsFile} "$configPath"

        if [ -z "''${DRY_RUN-}" ]; then
          # Herdr owns this UI preference unless it is set declaratively.
          case "$persistedAgentPanelSort" in
            spaces|priority)
              if ${pkgs.gnugrep}/bin/grep -q "^\[ui\]$" "$configPath"; then
                ${pkgs.gnused}/bin/sed -i "/^\[ui\]$/a agent_panel_sort = \"$persistedAgentPanelSort\"" "$configPath"
              else
                printf '\n[ui]\nagent_panel_sort = "%s"\n' "$persistedAgentPanelSort" >> "$configPath"
              fi
              ;;
          esac
        fi

        $DRY_RUN_CMD ${binPath} server reload-config || true
      fi
    '';
  };
}
