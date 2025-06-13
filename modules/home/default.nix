{
  pkgs,
  inputs,
  username,
  host,
  ags,
  ...
}: let
  inherit (import ../variables.nix) gitUsername gitEmail;
in {
  # Import Program Configurations
  imports = [
    ./emoji.nix
    ./rofi/rofi.nix
    ./rofi/config-emoji.nix
    ./rofi/config-long.nix
    ./neovim.nix
    ./chromium.nix
    ./hyprland.nix
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
    ags.homeManagerModules.default
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

  services = {
    hypridle = {
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs.home-manager.enable = true;
}
