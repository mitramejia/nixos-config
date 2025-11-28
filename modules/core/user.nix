{
  pkgs,
  inputs,
  username,
  host,
  ags,
  ...
}: let
  inherit (import ../variables.nix) gitUsername;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit username; # Makes the username available to user modules
      inherit inputs; # Passes all flake inputs to home-manager modules
      inherit host; # Lets modules perform host-specific customization
      inherit ags; # Passes AGS reference for per-user shell widgets
    };
    users.${username} = {
      imports = [../home];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };

  nix.settings.allowed-users = ["${username}"];

  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "adbusers"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "wheel"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;

    # User-specific package installations
    packages = with pkgs; [
      # Programming language and toolchain managers
      pnpm # JavaScript package manager (alternative to npm/yarn)
      cargo # Rust package manager
      rustc # Rust compiler
      ruby # Ruby language
      jdk17 # Java Development Kit
      jq

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

      # Code editors and IDEs
      code-cursor # Visual Studio Code editor
      jetbrains-toolbox # JetBrains Toolbox for IDE management
      android-studio # Android development IDE
      android-studio-tools # Android Studio extra tools
      chromedriver # ChromeDriver for browser automation
      lmstudio

      # Frontend-focused development tools
      amdgpu_top # AMD GPU monitoring tool
      grimblast # Screenshot utility for Wayland compositors
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

      ## Utilities to enhance the Hyprland experience
      gpu-screen-recorder # GPU-accelerated screen recorder
      hyprpicker # Color picker for Hyprland
      hyprsunset # Blue light filter for display

      ## Security
      yubikey-manager
      yubioath-flutter
    ];
  };
}
