{
  inputs,
  config,
  ...
}: let
  inherit (import ../variables.nix) keyboardLayout;
in {
  imports = [inputs.noctalia-greeter.nixosModules.default];

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      # UWSM owns the graphical user-systemd lifecycle that starts Noctalia.
      session.default = "Hyprland (uwsm-managed)";
      cursor = {
        theme = config.stylix.cursor.name;
        size = config.stylix.cursor.size;
        path = "${config.stylix.cursor.package}/share/icons";
      };
      keyboard = {
        layout = keyboardLayout;
      };
    };
  };
}
