_: let
  inherit
    (import ../../variables.nix)
    browser
    terminal
    ;
in {
  wayland.windowManager.hyprland.settings.exec-once = [
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "nm-applet --indicator"
    "blueman-applet"
    "lxqt-policykit-agent"
    "noctalia"
    "[workspace 1] ${browser}"
    "[workspace 2] ${terminal} -e tmux new-session -A -s 2"
    "[workspace 3] ${terminal} -e tmux new-session -A -s 3"
    "[workspace 5] slack"
    "[workspace 5] zapzap"
    "[workspace 6] obsidian"
    "[workspace 7] cider-appimage"
    "[workspace 9] kitty"
  ];
}
