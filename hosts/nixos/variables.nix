{
  # Git Configuration (For Pulling Software Repositories)
  # Set your Git username and email for repository operations.
  # More info: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
  gitUsername = "mitramejia";
  gitEmail = "mitra@arrofinance.com";

  # Hyprland Settings
  # Configure monitor settings like resolution, orientation, etc.
  # Documentation: https://github.com/larkery/Hyprland
  # To see monitor ID's i.e DP-1, run in terminal:  hyprctl monitors all
  extraMonitorSettings = ''
    monitor=DP-1,preferred,auto,1.333
    monitor=DP-2,preferred,auto,1.333,transform,3
  '';

  # Waybar Settings
  # Customize the Waybar appearance and settings, which is a highly customizable status bar for Wayland.
  # Documentation: https://github.com/Alexays/Waybar
  clock24h = false; # Set to true for 24-hour format, false for 12-hour format
  theme = "Catppuccin-Mocha"; # Theme for Waybar
  wallpaper_img = "/home/mitra/Pictures/Wallpapers/pexels.jpg"; # Path to the wallpaper image

  # Program Options
  # Set default applications for the system.
  browser = "firefox"; # Default web browser (e.g. google-chrome-stable for Google Chrome)
  terminal = "kitty"; # Default terminal emulator
  keyboardLayout = "us"; # Keyboard layout configuration
}
