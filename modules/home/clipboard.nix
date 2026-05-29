{ pkgs, ... }:
let
  clipboardPaste = pkgs.writeShellScriptBin "clipboard-paste" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "SHIFT, Insert, activewindow"
  '';

  cliphistRofiPaste = pkgs.writeShellScriptBin "cliphist-rofi-paste" ''
    set -euo pipefail

    selection="$(${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -i -dmenu -p Clipboard || true)"

    [ -n "$selection" ] || exit 0

    printf '%s' "$selection" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    sleep 0.05
    ${clipboardPaste}/bin/clipboard-paste
  '';

  cliphistRofiClear = pkgs.writeShellScriptBin "cliphist-rofi-clear" ''
    set -euo pipefail

    answer="$(printf 'No\nYes\n' | ${pkgs.rofi}/bin/rofi -dmenu -p 'Clear clipboard history?' || true)"

    [ "$answer" = "Yes" ] || exit 0

    ${pkgs.cliphist}/bin/cliphist wipe
    ${pkgs.libnotify}/bin/notify-send "Clipboard history cleared."
  '';

  mkCliphistWatcher = type: description: {
    Unit = {
      Description = description;
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "hyprland-session.target" ];
  };
in
{
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    clipboardPaste
    cliphistRofiPaste
    cliphistRofiClear
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "$modifier,C,sendshortcut,CTRL,Insert,activewindow"
    "$modifier,V,exec,clipboard-paste"
    "$modifier,X,sendshortcut,CTRL,X,activewindow"
    "$modifier CTRL,V,exec,cliphist-rofi-paste"
    "$modifier SHIFT CTRL,V,exec,cliphist-rofi-clear"
  ];

  systemd.user.services = {
    cliphist-text = mkCliphistWatcher "text" "Clipboard history watcher for text";
    cliphist-image = mkCliphistWatcher "image" "Clipboard history watcher for images";
  };
}
