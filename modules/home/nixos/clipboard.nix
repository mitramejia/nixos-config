{
  config,
  lib,
  pkgs,
  ...
}: let
  lua = lib.generators.mkLuaInline;
  modKey = key: lua ''mod .. " + ${key}"'';
  terminalClasses = [
    "kitty"
    "kitty-dropterm"
  ];
  forwardShortcut = key:
    lua ''
      function()
        local window = hl.get_active_window()
        local modifiers = "CTRL"
        if window ~= nil and (${lib.concatMapStringsSep " or " (class: "tostring(window.class) == ${builtins.toJSON class}") terminalClasses}) then
          modifiers = "SUPER"
        end
        hl.dispatch(hl.dsp.send_shortcut({ mods = modifiers, key = ${builtins.toJSON key} }))
      end
    '';
  clipboardPaste = pkgs.writeShellScriptBin "clipboard-paste" ''
    # This runs after Noctalia's external picker returns, so paste through
    # Hyprland's Lua IPC entry point.
    ${config.wayland.windowManager.hyprland.package}/bin/hyprctl eval 'hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }))'
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
        (forwardShortcut "C")
      ];
    }
    {
      _args = [
        (modKey "V")
        (forwardShortcut "V")
      ];
    }
    {
      _args = [
        (modKey "X")
        (forwardShortcut "X")
      ];
    }
  ];

  systemd.user.services = {
    cliphist-text = mkCliphistWatcher "text" "Clipboard history watcher for text";
    cliphist-image = mkCliphistWatcher "image" "Clipboard history watcher for images";
  };
}
