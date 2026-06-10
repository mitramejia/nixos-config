_: {
  wayland.windowManager.hyprland.settings.animations = {
    enabled = true;
    bezier = [
      "easeOut, 0.25, 1, 0.5, 1"
      "easeInOut, 0.42, 0, 0.58, 1"
    ];
    animation = [
      "windows, 1, 2, easeOut, popin 80%"
      "windowsOut, 1, 1, easeInOut"
      "windowsIn, 1, 1, easeOut"
      "windowsMove, 1, 2, easeInOut"
      "fade, 1, 2, easeOut"
      "workspaces, 1, 2, easeOut"
    ];
  };
}
