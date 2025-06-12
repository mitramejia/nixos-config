{
  pkgs,
  host,
  username,
  options,
  ...
}: let
  inherit (import ./variables.nix) keyboardLayout;
in {
  imports = [
    ./hardware.nix
    ./users.nix
    ./stylix.nix
    ./nix-ld.nix
    ./boot.nix
    ./timezone.nix
    ./starship.nix
    ./thunar.nix
    ./steam.nix
    ./greetd.nix
  ];

  virtualisation.docker.enable = true;
  # Styling Options

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = host;
  networking.timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

  programs.hyprland = {
    enable = true;
  };

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;

    adb.enable = true;

    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    virt-manager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
  };

  environment.systemPackages = with pkgs; [
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
    libnotify # Desktop notifications library
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
    swww # Wayland wallpaper daemon
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

  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      # Commenting Symbola out to fix install this will need to be fixed or an alternative found.
      # symbola
      material-icons
    ];
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    xdgOpenUsePortal = true;
    configPackages = [pkgs.hyprland];
  };

  # Services to start
  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };
    displayManager.autoLogin.enable = false;
    displayManager.autoLogin.user = "mitra";
    smartd = {
      enable = false;
      autodetect = true;
    };
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    rpcbind.enable = false;
    nfs.server.enable = false;
  };
  services.twingate.enable = true;
  systemd.services.flatpak-repo = {
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Extra Logitech Support
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Bluetooth Support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  # Security / Polkit
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';

  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };

  # Virtualization / Containers
  virtualisation.libvirtd.enable = true;

  console.keyMap = "${keyboardLayout}";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [80 8081 8082 8080 8083 3000 5000 8000];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
