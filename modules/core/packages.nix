{pkgs, ...}: {
  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    firefox.enable = false; # Firefox is not installed by default
    hyprland.enable = true; #someone forgot to set this so desktop file is created
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    adb.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    hyprshot
    bash
    ollama-rocm # Run AI models locally
    vim # Text editor
    wget # File download utility
    killall # Process termination utility
    eza # Modern replacement for ls
    git # Version control system
    cmatrix # Terminal matrix effect
    lolcat # Rainbow text colorizer
    libvirt # Virtualization API
    lxqt.lxqt-policykit # PolicyKit authentication agent
    lm_sensors # Hardware monitoring utilities
    unzip # ZIP file extraction
    unrar # RAR file extraction
    v4l-utils # Video4Linux utilities
    ydotool # X11 automation tool
    duf # Disk usage utility
    ncdu # NCurses disk usage analyzer
    wl-clipboard # Wayland clipboard utilities
    pciutils # PCI utilities
    ffmpeg # Multimedia framework
    socat # Multipurpose relay tool
    ripgrep # Fast grep alternative
    lshw # Hardware lister
    pkg-config # Development tool
    meson # Build system
    hyprpicker # Color picker for Hyprland
    ninja # Build system
    brightnessctl # Brightness control
    virt-viewer # Virtual machine viewer
    swappy # Screenshot editor
    appimage-run # AppImage runner
    networkmanagerapplet # Network manager GUI
    yad # Dialog display utility
    inxi # System information tool
    playerctl # Media player controller
    nixfmt-rfc-style # Nix code formatter
    libvirt # Virtualization API
    hyprpaper # Hyprland wallpaper utility
    grim # Screenshot utility
    slurp # Region selector
    file-roller # Archive manager
    imv # Image viewer
    mpv # Media player
    tree # Directory listing tool
    neofetch # System info display
    greetd.tuigreet # TUI greeter
    gearlever # Distrobox manager
    pavucontrol # PulseAudio volume control
    nwg-displays #configure monitor configs via GUI
  ];
}
