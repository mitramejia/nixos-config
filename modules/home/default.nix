{
  pkgs,
  ags,
  ...
}: {
  # Import Program Configurations
  imports = [
    ./hyprland.nix
    ./emoji.nix
    ./rofi/rofi.nix
    ./rofi/config-emoji.nix
    ./rofi/config-long.nix
    ./neovim.nix
    ./chromium.nix
    ./virtualisation.nix
    ./ideavim
    ./kitty.nix
    ./stylix.nix
    ./gtk.nix
    ./qt.nix
    ./swapy.nix
    ./btop.nix
    ./xdg.nix
    ./eza.nix
    ./fzf.nix
    ./lazygit.nix
    ./bat.nix
    ./tmux.nix
    ./starship.nix
    ./direnv.nix
    ./zsh.nix
    ./git.nix
    ./gh.nix
  ];

  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../../assets/wallpapers;
    recursive = true;
  };

  # Scripts
  home.packages = [
    (import ./scripts/emopicker9000.nix {inherit pkgs;})
    (import ./scripts/web-search.nix {inherit pkgs;})
    (import ./scripts/rofi-launcher.nix {inherit pkgs;})
    (import ./scripts/screenshootin.nix {inherit pkgs;})
    ags.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;
}
