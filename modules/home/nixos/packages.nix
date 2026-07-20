{pkgs, ...}: {
  home.packages = with pkgs; [
    zapzap
    slack
    zoom-us
    discord
    thunderbird
    localsend
    virtualbox
    trimage

    obsidian
    gimp
    libreoffice
    vlc
    trash-cli
    alpine
    code-cursor
    jetbrains-toolbox
    chromedriver
    amdgpu_top
    twingate

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
