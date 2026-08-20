{
  config,
  lib,
  pkgs,
  ...
}: let
  startupCommands = [
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "nm-applet --indicator"
    "blueman-applet"
    "lxqt-policykit-agent"
  ];

  workspaceStartupCommands = config.private.hyprlandWorkspaceIntent.startupCommands or [];

  startupCommand = command: "  hl.exec_cmd(${builtins.toJSON command})\n";
  workspaceStartupCommand = {
    workspace,
    command,
  }: "  hl.exec_cmd(${builtins.toJSON command}, { workspace = ${builtins.toJSON workspace} })\n";
  workspaceStartupLua = lib.concatMapStrings workspaceStartupCommand workspaceStartupCommands;
  workspaceStartupCheck = assert lib.assertMsg (workspaceStartupLua == "  hl.exec_cmd(\"zen-beta\", { workspace = \"1\" })\n  hl.exec_cmd(\"kitty -e herdr --session 2\", { workspace = \"2\" })\n  hl.exec_cmd(\"kitty -e herdr --session 3\", { workspace = \"3\" })\n  hl.exec_cmd(\"slack\", { workspace = \"5\" })\n  hl.exec_cmd(\"zapzap\", { workspace = \"5\" })\n  hl.exec_cmd(\"obsidian\", { workspace = \"6\" })\n  hl.exec_cmd(\"cider-appimage\", { workspace = \"7\" })\n  hl.exec_cmd(\"kitty\", { workspace = \"9\" })\n") "Hyprland exec-once must preserve workspace startup Lua.";
    pkgs.runCommand "hyprland-workspace-startup-lua" {} "mkdir -p $out";
in {
  options.private.hyprlandExecOnce.workspaceStartupCheck = lib.mkOption {
    type = lib.types.package;
    internal = true;
    description = "Focused exec-once workspace startup Lua verification result.";
  };

  # Noctalia is deliberately absent: its Home Manager user service owns its
  # startup, restart, and Wayland-session lifecycle under UWSM.
  config = {
    wayland.windowManager.hyprland.settings.on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline (
          "function()\n"
          # `hl.dsp.exec_cmd` builds a dispatcher for `hl.bind`; it does not run
          # in an event callback. `hl.exec_cmd` launches each command here, and
          # its rule table replaces legacy `[workspace N] command` syntax.
          + lib.concatMapStrings startupCommand startupCommands
          + workspaceStartupLua
          + "end"
        ))
      ];
    };

    private.hyprlandExecOnce.workspaceStartupCheck = workspaceStartupCheck;
  };
}
