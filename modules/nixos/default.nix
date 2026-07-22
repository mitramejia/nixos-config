{
  pkgs,
  host,
  inputs,
  options,
  ...
}: let
  inherit (import ../variables.nix) keyboardLayout;
in {
  imports = [
    ./packages.nix
    ./user.nix
    ./stylix.nix
    ./nix-ld.nix
    ./nh.nix
    ./ollama.nix
    ./boot.nix
    ./timezone.nix
    ./starship.nix
    ./thunar.nix
    ./steam.nix
    ./greetd.nix
    ./virtualisation.nix
    inputs.stylix.nixosModules.stylix
  ];

  networking = {
    networkmanager.enable = true;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
    firewall = {
      enable = false;
      allowedTCPPorts = [80 8081 8082 8080 8083 3000 5000 8000];
    };
  };

  nixpkgs.config.allowUnfree = true;
  fonts.packages = with pkgs; [
    inter
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    font-awesome
    material-icons
  ];

  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = keyboardLayout;
        variant = "";
      };
    };
    displayManager.autoLogin = {
      enable = true;
      user = host.username;
    };
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
    upower.enable = true;
    power-profiles-daemon.enable = true;
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

  services.blueman.enable = true;
  services.pulseaudio.enable = false;
  zramSwap.enable = true;

  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
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
    };
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  console.keyMap = keyboardLayout;
}
