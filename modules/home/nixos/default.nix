{pkgs, ...}: {
  imports = [
    ./hyprland
    ./clipboard.nix
    ./terminal-shortcuts.nix
    ./neovim.nix
    ./android.nix
    ./packages.nix
    ./noctalia.nix
    ./noctalia-clipboard.nix
    ./zen-browser.nix
    ./virtualisation.nix
    ./stylix.nix
    ./qt.nix
    ./swapy.nix
    ./btop.nix
    ./xdg.nix
    ./yazi.nix
    ./fzf.nix
    ./lazygit.nix
    ./tmux.nix
    ./zsh.nix
    ./voxtype.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../../assets/wallpapers;
    recursive = true;
  };

  services.espanso.enable = true;

  services.voxtype = {
    enable = true;
    package = pkgs.voxtype.override {vulkanSupport = true;};
    loadModels = ["large-v3-turbo"];
    wayland.display = "wayland-1";
    settings = {
      hotkey.enabled = false;
      whisper = {
        model = "large-v3-turbo";
        language = "en";
      };
    };
  };
}
