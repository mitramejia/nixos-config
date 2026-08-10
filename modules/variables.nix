{
  # Git Configuration (For Pulling Software Repositories)
  # Set your Git username and email for repository operations.
  # More info: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
  gitUsername = "mitramejia";
  gitEmail = "mitra.mejia@gmail.com";

  # Hyprland Settings
  # Configure monitor settings like resolution, orientation, etc.
  # To see monitor IDs such as DP-1, run: hyprctl monitors all
  # Home Manager renders each Nix attrset as one hl.monitor call.
  extraMonitorSettings = [
    {
      output = "DP-1";
      mode = "preferred";
      position = "auto";
      scale = 1.33;
    }
    {
      output = "DP-2";
      mode = "preferred";
      position = "auto";
      scale = 1.33;
      transform = 3;
    }
  ];

  stylixImage = ../assets/wallpapers/pexels.jpg;

  # Program Options
  # Set default applications for the system.
  browser = "zen-beta"; # Default web browser (e.g. google-chrome-stable for Google Chrome)
  terminal = "kitty"; # Default terminal emulator
  keyboardLayout = "us"; # Keyboard layout configuration

  # Extra MIME defaults merged into modules/home/xdg.nix.
  mimeDefaultApplications = {};
}
