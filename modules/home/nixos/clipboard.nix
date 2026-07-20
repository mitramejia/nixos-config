{pkgs, ...}: let
  clipboardPaste = pkgs.writeShellScriptBin "clipboard-paste" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "SHIFT, Insert, activewindow"
  '';

  mkCliphistWatcher = type: description: {
    Unit = {
      Description = description;
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };

    Install.WantedBy = ["hyprland-session.target"];
  };
in {
  home.packages = [
    pkgs.cliphist
    pkgs.wl-clipboard
    clipboardPaste
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "$modifier,C,sendshortcut,CTRL,Insert,activewindow"
    "$modifier,V,exec,clipboard-paste"
    "$modifier,X,sendshortcut,CTRL,X,activewindow"
  ];

  systemd.user.services = {
    cliphist-text = mkCliphistWatcher "text" "Clipboard history watcher for text";
    cliphist-image = mkCliphistWatcher "image" "Clipboard history watcher for images";
  };
}
