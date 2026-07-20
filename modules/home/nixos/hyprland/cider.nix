{pkgs, ...}: let
  ciderAppImage = pkgs.writeShellScriptBin "cider-appimage" ''
    set -euo pipefail

    for app in "$HOME/AppImages/Cider/Cider.AppImage"; do
      if [ -x "$app" ]; then
        export ELECTRON_OZONE_PLATFORM_HINT=wayland
        export NIXOS_OZONE_WL=1
        export GDK_BACKEND=wayland,x11,*

        exec ${pkgs.appimage-run}/bin/appimage-run "$app" \
          --ozone-platform=wayland \
          --disable-zero-copy \
          --disable-gpu-memory-buffer-video-frames \
          "$@" >>"$HOME/.cache/cider.log" 2>&1
      fi
    done

    echo "cider-appimage: no executable Cider AppImage found in $HOME/AppImages/Cider" >&2
    exit 1
  '';
in {
  home.packages = [
    ciderAppImage
  ];
}
