_: {
  wayland.windowManager.hyprland.settings.env = [
    {_args = ["NIXOS_OZONE_WL" "1"];}
    {_args = ["NIXPKGS_ALLOW_UNFREE" "1"];}
    {_args = ["XDG_CURRENT_DESKTOP" "Hyprland"];}
    {_args = ["XDG_SESSION_TYPE" "wayland"];}
    {_args = ["XDG_SESSION_DESKTOP" "Hyprland"];}
    {_args = ["ELECTRON_OZONE_PLATFORM_HINT" "wayland"];}
    {_args = ["GDK_BACKEND" "wayland,x11,*"];}
    {_args = ["CLUTTER_BACKEND" "wayland"];}
    {_args = ["QT_QPA_PLATFORM" "wayland;xcb"];}
    {_args = ["QT_WAYLAND_DISABLE_WINDOWDECORATION" "1"];}
    {_args = ["QT_AUTO_SCREEN_SCALE_FACTOR" "1"];}
    {_args = ["SDL_VIDEODRIVER" "wayland"];}
    {_args = ["MOZ_ENABLE_WAYLAND" "1"];}
    # Use stable udev aliases from hosts/nixos/hardware.nix. AQ_DRM_DEVICES is
    # colon-separated, so raw by-path PCI names cannot be used because they
    # contain ':'.
    {_args = ["AQ_DRM_DEVICES" "/dev/dri/amd-rx9070:/dev/dri/amd-igpu"];}
    {_args = ["GDK_SCALE" "1"];}
    {_args = ["QT_SCALE_FACTOR" "1"];}
    {_args = ["TERMINAL" "ghostty"];}
    {_args = ["EDITOR" "nvim"];}
  ];
}
