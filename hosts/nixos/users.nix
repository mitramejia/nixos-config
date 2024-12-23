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
        vscode
        slack
        lmstudio
        obsidian
        libreoffice
        vlc
        monitor
        rofi-power-menu
        tmux
        scmpuff
        alejandra
        jetbrains.webstorm
        jetbrains.datagrip
        android-studio
        android-studio-tools
        thunderbird
        genymotion
        virtualbox
        httpie
        httpie-desktop
        # Arro Frontend development
        zoom-us
        chromium
        chromedriver
        amdgpu_top
        zapzap
        youtube-music
        grimblast
        lunarvim
        just

        # hyprpanel
        wireplumber
        libgtop
        bluez
        networkmanager
        dart-sass
        wl-clipboard
        upower
        gvfs

        hyprpanel
        ## To record screen through the dashboard record shortcut
        gpu-screen-recorder

        ## To enable the eyedropper color picker with the default snapshot shortcut in the dashboard
        hyprpicker

        ## To enable hyprland's very own blue light filter
        hyprsunset

        ## To enable hyprland's very own idle inhibitor
        hypridle
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
