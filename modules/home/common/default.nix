{...}: {
  imports = [
    ./agent-skills.nix
    ./bat.nix
    ./codex
    ./direnv.nix
    ./eza.nix
    ./gh.nix
    ./git.nix
    ./herdr.nix
    ./ideavim
    ./kitty.nix
    ./neovim.nix
    ./packages.nix
    ./shell-aliases.nix
    ./starship.nix
  ];

  programs.home-manager.enable = true;
}
