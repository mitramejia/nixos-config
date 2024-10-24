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
        bitwarden-desktop
        vscode
        bitwarden-cli
        slack
        lmstudio
        obsidian
        libreoffice
        vlc
        monitor
        spotify
        rofi-power-menu
        tmux
        scmpuff
        alejandra
        jira-cli-go
        jetbrains.webstorm
        jetbrains.datagrip
        genymotion
        virtualbox
        httpie
        httpie-desktop
        # Arro Frontend development
        nodejs_20
        pnpm
        maestro
        nodePackages.eas-cli
        watchman
        zoom-us
        firefox
        chromium
        chromedriver
        amdgpu_top
        zapzap
        youtube-music
        grimblast
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
