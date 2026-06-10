{...}: {
  nixpkgs.config.allowUnfree = true;

  # Import Program Configurations
  imports = [
    ./hyprland
    ./clipboard.nix
    ./codex
    ./agent-skills.nix
    ./android.nix
    ./packages.nix
    ./noctalia.nix
    ./noctalia-clipboard.nix
    ./neovim.nix
    ./chromium.nix
    ./virtualisation.nix
    ./ideavim
    ./kitty.nix
    ./stylix.nix
    ./qt.nix
    ./swapy.nix
    ./btop.nix
    ./xdg.nix
    ./yazi.nix
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

  programs.home-manager.enable = true;
}
