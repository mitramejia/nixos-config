{
  host,
  inputs,
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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowInsecure = false;
    };
    overlays = [
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
