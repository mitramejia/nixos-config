{
  stylix.targets = {
    kitty.enable = false;
    waybar.enable = false;
    hyprland.enable = false;
    noctalia-shell.enable = false;
    # Leave opencode alone: this target manages tui.json, which opencode
    # rewrites at runtime (the vim plugin toggle persists there).
    opencode.enable = false;
    firefox.profileNames = ["default"];
    yazi.enable = true;
  };
}
