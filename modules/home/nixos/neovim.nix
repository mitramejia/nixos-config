{pkgs, ...}: {
  programs.nixvim.extraPackages = [
    pkgs.wl-clipboard
    pkgs.hyprls
  ];
}
