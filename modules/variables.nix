{
  # Git Configuration (For Pulling Software Repositories)
  # Set your Git username and email for repository operations.
  # More info: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
  gitUsername = "mitramejia";
  gitEmail = "mitra.mejia@gmail.com";

  # Hyprland Settings
  # Configure monitor settings like resolution, orientation, etc.
  # To see monitor IDs such as DP-1, run: hhyprctl monitors allyprctl monitors all
  # Home Manager renders each Nix attrset as one hl.monitor call.
  extraMonitorSettings = [
    {
      output = "DP-1";
      mode = "3840x2160@120";
      position = "0x0";
      scale = 1.33;
      bitdepth = 10;
      cm = "srgb";
    }
    {
      output = "DP-2";
      mode = "preferred";
      # At effective 4/3 scale, center 1620x2880 portrait beside 2880x1620: (1620 - 2880) / 2 = -630.
      position = "2880x-630";
      scale = 1.33;
      transform = 3;
      bitdepth = 8;
      cm = "srgb";
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
