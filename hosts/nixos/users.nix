{
  pkgs,
  username,
  unstable,
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
        vscode
        slack
        lmstudio
        obsidian
        libreoffice
        vlc
        monitor
        tmux
        scmpuff
        alejandra
        insomnia
        android-studio
        android-studio-tools
        unstable.jetbrains.webstorm
        unstable.jetbrains.datagrip
        virtualbox
        nodejs_20
        pnpm
        maestro
        nodePackages.eas-cli
        watchman
        chromium
        chromedriver
        amdgpu_top
        zapzap
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
