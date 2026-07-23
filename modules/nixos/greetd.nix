{
  pkgs,
  config,
  host,
  ...
}: let
  sessionWrapper = pkgs.writeShellScript "session-log-wrapper" ''
    exec "$@" > /tmp/session.log 2>&1
  '';
  hyprlandUWSMCommand = "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop";
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = host.username;
        # UWSM activates the graphical user-systemd session that Noctalia uses.
        # Let its Hyprland desktop entry load Home Manager's Nix-generated
        # configuration through the normal start-hyprland path.
        # Do not remember the old direct Hyprland session as tuigreet's default.
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${hyprlandUWSMCommand}' --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --session-wrapper '${sessionWrapper}'";
      };
    };
  };
}
