{...}: {
  imports = [
    ./agent-skills.nix
    ./bat.nix
    ./codex
    ./direnv.nix
    ./eza.nix
    ./gh.nix
    ./git.nix
    ./ideavim
    ./neovim.nix
    ./packages.nix
    ./starship.nix
  ];

  programs.home-manager.enable = true;
}
