{
  host,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./dock
    ./home-manager.nix
    ./homebrew.nix
    ./user.nix
  ];

  # Determinate Nix owns the Nix installation and daemon on this host.
  nix.enable = false;
  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = ["@admin" host.username];
      substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org"];
    };
    gc = {
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
    overlays = [
      inputs.claude-code.overlays.default
      inputs.codex-cli-nix.overlays.default
      (final: prev: {
        direnv = prev.direnv.overrideAttrs (_: {
          doCheck = false;
        });
      })
    ];
  };

  system = {
    checks.verifyNixPath = false;
    primaryUser = host.username;
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
      dock = {
        autohide = true;
        show-recents = true;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        _FXShowPosixPathInTitle = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
