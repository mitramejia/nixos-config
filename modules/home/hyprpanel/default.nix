{
  # Hyprpanel via Home Manager
  # - programs.hyprpanel.enable: Enables Hyprpanel for this user (installs the program and configures its user service to start it).
  # - programs.hyprpanel.settings: The full Hyprpanel configuration. Now imported from a native Nix attrset (no external JSON needed).
  #   You can override specific keys here if desired.
  programs.hyprpanel = {
    # Enable Hyprpanel: installs the package and sets up the user service under Home Manager.
    enable = true;

    # Use the Nix-native settings attrset (ported from hyprpanel.config.json).
    settings = import ./settings.nix;
  };
}
