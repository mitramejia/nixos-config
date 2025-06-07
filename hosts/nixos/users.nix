# Module for configuring user accounts and their associated packages
{
  pkgs,
  username,
  ...
}: let
  # Import the Git username from variables file
  inherit (import ./variables.nix) gitUsername;
in {
  users.users = {
    # Primary user configuration with development environment
    "${username}" = {
      homeMode = "755"; # Set home directory permissions
      isNormalUser = true; # Configure as regular user account
      description = "${gitUsername}"; # Set user description from git config
      extraGroups = [
        "networkmanager" # Network management permissions
        "wheel" # Sudo/administrative rights
        "libvirtd" # Virtualization permissions (KVM/QEMU)
        "scanner" # Access to scanner devices
        "lp" # Access to printers
        "adbusers" # Android Debug Bridge group
        "docker" # Docker group for container management
      ];
      shell = pkgs.zsh; # Set Zsh as the default shell
      ignoreShellProgramCheck = true; # Skip shell program validation

      # User-specific package installations
      packages = with pkgs; [
        # Programming language and toolchain managers
        pnpm # JavaScript package manager (alternative to npm/yarn)
        cargo # Rust package manager
        rustc # Rust compiler
        ruby # Ruby language
        jdk17 # Java Development Kit

        # Internet and communication applications
        zapzap # Messaging app (possibly WhatsApp client)
        slack # Team collaboration and messaging app
        thunderbird # Email client
        zoom-us # Video conferencing application
        discord # Chat for communities

        # Development tools for code, system, and infrastructure
        alejandra # Nix formatter
        lazydocker # Terminal UI for managing Docker
        rofi-power-menu # Power menu extension for Rofi
        tmux # Terminal multiplexer
        scmpuff # Git command helper tool
        act # Run GitHub Actions locally
        actionlint # Linter for GitHub Actions workflow files
        virtualbox # Virtual machine manager
        just # Task/command runner for project scripts
        docker-compose # Define and run multi-container applications
        trimage # Image compression utility

        # Productivity, media, and general GUI applications
        obsidian # Note-taking app
        gimp # Image editing software
        libreoffice # Office suite
        vlc # Media player
        monitor # System monitoring tool (placeholder name)

        # Code editors and IDEs
        vscode # Visual Studio Code editor
        jetbrains-toolbox # JetBrains Toolbox for IDE management
        android-studio # Android development IDE
        android-studio-tools # Android Studio extra tools
        chromedriver # ChromeDriver for browser automation
        lmstudio

        # Frontend-focused development tools
        amdgpu_top # AMD GPU monitoring tool
        grimblast # Screenshot utility for Wayland compositors
        lunarvim # Neovim-based IDE
        twingate # Remote network access tool
        doppler # Secrets management for application configs

        # Hyprland and core system packages for Wayland environments
        wireplumber # PipeWire audio session manager
        libgtop # System monitoring library
        bluez # Bluetooth protocol stack
        networkmanager # Networking configuration/management
        dart-sass # Sass CSS compiler
        wl-clipboard # Clipboard utility for Wayland
        upower # Power management utilities
        gvfs # Virtual filesystem layer
        obs-studio # Screen recording and streaming software

        hyprpanel # Panel for Hyprland window manager
        ## Utilities to enhance the Hyprland experience
        gpu-screen-recorder # GPU-accelerated screen recorder
        hyprpicker # Color picker for Hyprland
        hyprsunset # Blue light filter for display
        hypridle # Idle detection for Hyprland
      ];
    };

    # Template for additional user accounts (example, commented out)
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
