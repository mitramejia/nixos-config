{
  pkgs,
  username,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
in {
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "adbusersr"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      packages = with pkgs; [
        pkgs.bitwarden-desktop
        pkgs.vscode
        pkgs.bitwarden-cli
        pkgs.slack
        pkgs.lmstudio
        pkgs.obsidian
        pkgs.libreoffice
        pkgs.vlc
        pkgs.monitor
        pkgs.rofi-power-menu
        pkgs.tmux
        pkgs.scmpuff
        pkgs.alejandra
        pkgs.jetbrains.webstorm
        pkgs.jetbrains.datagrip
        pkgs.android-studio
        pkgs.android-studio-tools
        pkgs.genymotion
        pkgs.virtualbox
        pkgs.httpie
        pkgs.httpie-desktop
        # Arro Frontend development
        pkgs.nodejs_20
        pkgs.pnpm
        pkgs.maestro
        pkgs.nodePackages.eas-cli
        pkgs.watchman
        pkgs.zoom-us
        pkgs.firefox
        pkgs.chromium
        pkgs.chromedriver
        pkgs.amdgpu_top
        pkgs.zapzap
        pkgs.youtube-music
      ];
    };
    # "newuser" = {
    #   homeMode = "755";
    #   isNormalUser = true;
    #   description = "New user account";
    #   extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    #   shell = pkgs.bash;
    #   ignoreShellProgramCheck = true;
    #   packages = with pkgs; [];
    # };
  };
}
