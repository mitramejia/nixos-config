{...}: {
  imports = [
    ./android.nix
    ./btop.nix
    ./clipboard.nix
    ./fzf.nix
    ./ghostty.nix
    ./hyprland
    ./kitty.nix
    ./lazygit.nix
    ./noctalia.nix
    ./noctalia-clipboard.nix
    ./packages.nix
    ./qt.nix
    ./stylix.nix
    ./swapy.nix
    ./tmux.nix
    ./virtualisation.nix
    ./xdg.nix
    ./yazi.nix
    ./zen-browser.nix
    ./zsh.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../../assets/wallpapers;
    recursive = true;
  };
}
