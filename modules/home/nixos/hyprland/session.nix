{
  hyprlandPkgs,
  lib,
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
    # Home Manager 26.05 still passes a hyprland override, but the pinned
    # portal no longer depends on it. Drop only that obsolete argument.
    portalPackage =
      lib.makeOverridable
      (args: hyprlandPkgs.xdg-desktop-portal-hyprland.override (builtins.removeAttrs args ["hyprland"]))
      {};
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
  };
}
