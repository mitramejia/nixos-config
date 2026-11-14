{
  pkgs,
  unstablePkgs,
  ...
}: {
  home.packages = with pkgs; [
    zapzap
    slack
    zoom-us
    thunderbird
    localsend
    virtualbox
    trimage

    obsidian
    gimp
    pinta
    # Disktree is not available in the pinned stable package set.
    unstablePkgs.disktree
    libreoffice
    vlc
    trash-cli
    alpine
    code-cursor
    jetbrains-toolbox
    chromedriver
    amdgpu_top

    wireplumber
    libgtop
    bluez
    networkmanager
    dart-sass
    wl-clipboard
    upower
    gvfs
    obs-studio
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    yubikey-manager
    yubioath-flutter
  ];
}
