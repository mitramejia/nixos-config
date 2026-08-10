{lib, ...}: let
  inherit
    (import ../../../variables.nix)
    browser
    terminal
    ;
  startupCommands = [
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "nm-applet --indicator"
    "blueman-applet"
    "lxqt-policykit-agent"
  ];

  workspaceStartupCommands = [
    {
      workspace = 1;
      command = browser;
    }
    {
      workspace = 2;
      command = "${terminal} -e tmux new-session -A -s 2";
    }
    {
      workspace = 3;
      command = "${terminal} -e tmux new-session -A -s 3";
    }
    {
      workspace = 5;
      command = "slack";
    }
    {
      workspace = 5;
      command = "zapzap";
    }
    {
      workspace = 6;
      command = "obsidian";
    }
    {
      workspace = 7;
      command = "cider-appimage";
    }
    {
      workspace = 9;
      command = terminal;
    }
  ];

  startupCommand = command: "  hl.exec_cmd(${builtins.toJSON command})\n";
  workspaceStartupCommand = {
    workspace,
    command,
  }: "  hl.exec_cmd(${builtins.toJSON command}, { workspace = ${builtins.toJSON (toString workspace)} })\n";
in {
  # Noctalia is deliberately absent: its Home Manager user service owns its
  # startup, restart, and Wayland-session lifecycle under UWSM.
  wayland.windowManager.hyprland.settings.on = {
    _args = [
      "hyprland.start"
      (lib.generators.mkLuaInline (
        "function()\n"
        # `hl.dsp.exec_cmd` builds a dispatcher for `hl.bind`; it does not run
        # in an event callback. `hl.exec_cmd` launches each command here, and
        # its rule table replaces legacy `[workspace N] command` syntax.
        + lib.concatMapStrings startupCommand startupCommands
        + lib.concatMapStrings workspaceStartupCommand workspaceStartupCommands
        + "end"
      ))
    ];
  };
}
