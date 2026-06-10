{
  hyprlandPkgs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.gcr # Provides org.gnome.keyring.SystemPrompter
  ];

  services.gnome-keyring.enable = true;

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # 26.05 Home Manager flipped configType default "hyprlang" -> "lua". This
    # config is hyprlang, so pin it to keep behavior.
    configType = "hyprlang";
    package = hyprlandPkgs.hyprland;
    portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };

    settings."$modifier" = "SUPER";
  };
}
