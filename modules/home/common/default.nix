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
    ./opencode.nix
    ./packages.nix
    ./shell-aliases.nix
    ./starship.nix
    ./zen-browser.nix
  ];

  programs.home-manager.enable = true;
}
