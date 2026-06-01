{pkgs, ...}: let
  imvDesktopFile = "imv.desktop";
  imvMimeTypes = [
    "image/png"
    "image/jpeg"
    "image/jpg"
    "image/gif"
    "image/bmp"
    "image/webp"
    "image/tiff"
    "image/x-xcf"
    "image/x-portable-pixmap"
    "image/x-xbitmap"
  ];
in {
  xdg = {
    desktopEntries.imv = {
      name = "Image Viewer";
      exec = "${pkgs.imv}/bin/imv %F";
      icon = "imv";
      terminal = false;
      categories = ["Graphics" "Viewer"];
      mimeType = imvMimeTypes;
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      # 26.05 HM flipped this default true -> false; keep exporting XDG_*_DIR env vars.
      setSessionVariables = true;
    };
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications =
        builtins.listToAttrs
        (map (mimeType: {
            name = mimeType;
            value = imvDesktopFile;
          })
          imvMimeTypes);
    };
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      configPackages = [pkgs.hyprland];
    };
  };
}
