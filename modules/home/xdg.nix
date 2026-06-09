{
  inputs,
  pkgs,
  ...
}: let
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};

  defaultAssociations = mimeTypes: desktopFile:
    builtins.listToAttrs (
      map (mimeType: {
        name = mimeType;
        value = desktopFile;
      })
      mimeTypes
    );

  browserDesktopFile = "app.zen_browser.zen.desktop";
  browserMimeTypes = [
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];

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
      categories = [
        "Graphics"
        "Viewer"
      ];
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
        (defaultAssociations imvMimeTypes imvDesktopFile)
        // (defaultAssociations browserMimeTypes browserDesktopFile);
    };
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = [
        "hyprland"
        "gtk"
      ];
      configPackages = [hyprlandPkgs.hyprland];
    };
  };
}
