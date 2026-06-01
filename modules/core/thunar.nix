{pkgs, ...}: {
  programs = {
    thunar = {
      enable = true;
      # 26.05 moved these thunar plugins from pkgs.xfce.* to top-level.
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
        tumbler
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # Need For Video / Image Preview
  ];
}
