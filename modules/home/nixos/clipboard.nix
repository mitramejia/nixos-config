{
  config,
  lib,
  pkgs,
  ...
}: let
  lua = lib.generators.mkLuaInline;
  modKey = key: lua ''mod .. " + ${key}"'';
  exec = command: lua "hl.dsp.exec_cmd(${builtins.toJSON command})";
  clipboardPaste = pkgs.writeShellScriptBin "clipboard-paste" ''
    # This runs after the external Noctalia picker returns, so use Hyprland's
    # Lua IPC entry point rather than the removed legacy dispatcher syntax.
    ${config.wayland.windowManager.hyprland.package}/bin/hyprctl eval 'hl.dispatch(hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))'
  '';

  mkCliphistWatcher = type: description: {
    Unit = {
      Description = description;
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };

    Install.WantedBy = ["hyprland-session.target"];
  };
in {
  home.packages = [
    pkgs.cliphist
    pkgs.wl-clipboard
    clipboardPaste
  ];

  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        (modKey "C")
        (lua ''hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" })'')
      ];
    }
    {
      _args = [
        (modKey "V")
        (exec "clipboard-paste")
      ];
    }
    {
      _args = [
        (modKey "X")
        (lua ''hl.dsp.send_shortcut({ mods = "CTRL", key = "X" })'')
      ];
    }
  ];

  systemd.user.services = {
    cliphist-text = mkCliphistWatcher "text" "Clipboard history watcher for text";
    cliphist-image = mkCliphistWatcher "image" "Clipboard history watcher for images";
  };
}
