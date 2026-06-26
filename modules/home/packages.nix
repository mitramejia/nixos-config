{
  inputs,
  pkgs,
  ...
}: let
  claudeCode = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  headroomAi = pkgs.callPackage ../../packages/headroom-ai.nix {};
  scmpuff070 = pkgs.scmpuff.overrideAttrs (old: rec {
    version = "0.7.0";

    src = pkgs.fetchFromGitHub {
      owner = "mroth";
      repo = "scmpuff";
      rev = "v${version}";
      hash = "sha256-PrnZYk0moWH46AT5njQPk7kVOQaktwVbOGMAX307tyY=";
    };

    vendorHash = "sha256-Uu3tZhIoYPq4QWc63Y5cPNa+MZtFklwuZyUc0CJLlXc=";

    nativeCheckInputs =
      (old.nativeCheckInputs or [])
      ++ (with pkgs; [
        coreutils
        fish
        git
        which
        zsh
      ]);

    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace internal/cmd/inits/data/status_shortcuts.sh internal/cmd/inits/data/status_shortcuts.fish \
          --replace-fail /usr/bin/env ${pkgs.coreutils}/bin/env
      '';
  });
in {
  home.packages = with pkgs; [
    # Programming language and toolchain managers
    pnpm
    cargo
    rustc
    ruby
    jdk17
    jq

    # Internet and communication applications
    zapzap
    slack
    thunderbird
    zoom-us
    discord
    localsend

    # Development tools for code, system, and infrastructure
    claudeCode
    alejandra
    statix
    lazydocker
    tmux
    scmpuff070
    act
    actionlint
    headroomAi
    rtk
    virtualbox
    just
    docker-compose
    trimage

    # Mobile app development tools
    detekt
    gradle
    just-lsp
    kotlin
    kotlin-language-server
    ktlint
    sourcekit-lsp
    swift
    swift-format
    swiftlint
    watchman

    # Productivity, media, and general GUI applications
    obsidian
    gimp
    libreoffice
    vlc
    trash-cli

    # Code editors and IDEs
    code-cursor
    jetbrains-toolbox
    chromedriver

    # Frontend-focused development tools
    amdgpu_top
    twingate
    doppler

    # Hyprland and core system packages for Wayland environments
    wireplumber
    libgtop
    bluez
    networkmanager
    dart-sass
    wl-clipboard
    upower
    gvfs
    obs-studio

    # Utilities to enhance the Hyprland experience
    gpu-screen-recorder
    hyprpicker
    hyprsunset

    # Security
    yubikey-manager
    yubioath-flutter
  ];
}
