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
    # Hyprland 0.56 uses Lua internally. Home Manager renders this Nix
    # attribute tree to ~/.config/hypr/hyprland.lua; no Lua source file is
    # maintained by hand.
    configType = "lua";
    package = hyprlandPkgs.hyprland;
    portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
  };
}
