{
  pkgs,
  config,
  host,
  ...
}: let
  sessionWrapper = pkgs.writeShellScript "session-log-wrapper" ''
    exec "$@" > /tmp/session.log 2>&1
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = host.username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session --cmd start-hyprland --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --session-wrapper '${sessionWrapper}'";
      };
    };
  };
}
