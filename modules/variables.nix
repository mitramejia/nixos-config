{
  # Git Configuration (For Pulling Software Repositories)
  # Set your Git username and email for repository operations.
  # More info: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
  gitUsername = "mitramejia";
  gitEmail = "mitra.mejia@gmail.com";

  # Hyprland Settings
  # Configure monitor settings like resolution, orientation, etc.
  # Documentation: https://github.com/larkery/Hyprland
  # To see monitor ID's i.e DP-1, run in terminal:  hyprctl monitors all
  extraMonitorSettings = ''
    monitor=DP-1,preferred,auto,1.50
    monitor=DP-2,preferred,auto,1.50,transform,3
  '';

  wallpaper_img = "/home/mitra/Pictures/Wallpapers/pexels.jpg"; # Path to the wallpaper image
  stylixImage = ../assets/wallpapers/pexels.jpg;

  # Program Options
  # Set default applications for the system.
  browser = "brave"; # Default web browser (e.g. google-chrome-stable for Google Chrome)
  terminal = "kitty"; # Default terminal emulator
  keyboardLayout = "us"; # Keyboard layout configuration
}
