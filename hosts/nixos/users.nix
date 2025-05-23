# Module for configuring user accounts and their associated packages
{
  pkgs,
  username,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
in {
  users.users = {
    # Primary user configuration with development environment
    "${username}" = {
      homeMode = "755"; # Set home directory permissions
      isNormalUser = true; # Configure as regular user account
      description = "${gitUsername}"; # Set user description from git config
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "adbusers"
        "docker"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      # User-specific package installations
      packages = with pkgs; [
        pnpm # JavaScript package manager (alternative to npm/yarn)
        ruby

        # Internet-related packages
        zapzap # Possibly a messaging app
        slack # Team collaboration and messaging app
        thunderbird # Email client
        zoom-us # Video conferencing application
        discord # Chat

        # Development tools for coding, configuration, and virtualization
        alejandra # Nix formatter
        lazydocker # Terminal UI for managing Docker
        rofi-power-menu # Power menu extension for Rofi
        tmux # Terminal multiplexer
        scmpuff # Git SCM command helper
        act # Run GitHub Actions locally
        actionlint # Static checker for GitHub Actions workflow files
        genymotion # Android emulator
        virtualbox # Virtual machine manager
        httpie # Modern command-line HTTP client
        httpie-desktop # HTTPie GUI
        lmstudio # Possibly a software IDE
        just # Task runner for project scripts
        docker-compose
        trimage

        # General applications for productivity and media
        obsidian # Note-taking app
        gimp # Image editing software
        libreoffice # Office suite
        vlc # Media player
        monitor # Monitoring tool (likely a placeholder for an actual tool)

        # Code editors and IDEs
        vscode # Visual Studio Code
        jetbrains-toolbox # JetBrains Toolbox for managing IDE installations
        android-studio # Android development IDE
        android-studio-tools # Android Studio tools for development
        chromium
        chromedriver

        # Tools specifically for Arro Frontend development
        amdgpu_top # A monitoring tool for AMD GPUs
        grimblast # Screenshot tool for Wayland-based compositions
        lunarvim # A Neovim-based text editor for developers
        twingate
        doppler

        # Hyprland and system packages for Wayland-based environments
        wireplumber # Audio session manager for PipeWire
        libgtop # Library for system monitoring
        bluez # Bluetooth stack
        networkmanager # Network configuration and management
        dart-sass # Sass compiler for stylesheets
        wl-clipboard # Clipboard utility for Wayland
        upower # Power management support
        gvfs # Virtual filesystem layer
        obs-studio

        hyprpanel # Panel for Hyprland compositor
        ## Utilities to enhance the Hyprland experience
        gpu-screen-recorder # Tool for recording screens on the GPU
        hyprpicker # Eyedropper color picker for screenshots
        hyprsunset # Blue light filter for reducing eye strain
        hypridle # Idle inhibitor for Hyprland
      ];
    };
    # Template for additional user accounts
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
