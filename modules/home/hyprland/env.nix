_: {
  wayland.windowManager.hyprland.settings.env = [
    "NIXOS_OZONE_WL,1"
    "NIXPKGS_ALLOW_UNFREE,1"
    "XDG_CURRENT_DESKTOP,Hyprland"
    "XDG_SESSION_TYPE,wayland"
    "XDG_SESSION_DESKTOP,Hyprland"
    "ELECTRON_OZONE_PLATFORM_HINT,wayland"
    "GDK_BACKEND,wayland,x11,*"
    "CLUTTER_BACKEND,wayland"
    "QT_QPA_PLATFORM,wayland;xcb"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
    "SDL_VIDEODRIVER,wayland"
    "MOZ_ENABLE_WAYLAND,1"
    # Use stable udev aliases from modules/core/hardware.nix. AQ_DRM_DEVICES is
    # colon-separated, so raw by-path PCI names cannot be used because they
    # contain ':'.
    "AQ_DRM_DEVICES,/dev/dri/amd-rx9070:/dev/dri/amd-igpu"
    "GDK_SCALE,1"
    "QT_SCALE_FACTOR,1"
    "TERMINAL,kitty"
    "EDITOR,nvim"
  ];
}
