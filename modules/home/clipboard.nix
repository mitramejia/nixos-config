{pkgs, ...}: let
  clipboardPaste = pkgs.writeShellScriptBin "clipboard-paste" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "SHIFT, Insert, activewindow"
  '';

  noctaliaDmenuSelect = pkgs.writeShellScriptBin "noctalia-dmenu-select" ''
    set -euo pipefail

    prompt="''${1:?missing prompt}"
    items_file="''${2:?missing items file}"
    timeout_secs="''${3:-30}"
    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
    result_dir="$(${pkgs.coreutils}/bin/mktemp -d "$runtime_dir/noctalia-dmenu.XXXXXX")"
    result_file="$result_dir/result"

    cleanup() {
      ${pkgs.coreutils}/bin/rm -rf "$result_dir"
    }
    trap cleanup EXIT

    notify_unavailable() {
      ${pkgs.libnotify}/bin/notify-send "Noctalia picker unavailable" "$1"
    }

    if ! command -v noctalia >/dev/null 2>&1; then
      notify_unavailable "noctalia was not found."
      exit 1
    fi

    options="$(${pkgs.jq}/bin/jq -nc \
      --arg prompt "$prompt" \
      --arg resultFile "$result_file" \
      '{prompt: $prompt, resultFile: $resultFile, resultFormat: "plain", maxResults: 200}')"

    if ! noctalia msg plugin:dmenu showFromFile "$items_file" "$options" >/dev/null 2>&1; then
      notify_unavailable "The dmenu plugin is not ready."
      exit 1
    fi

    elapsed=0
    timeout_ms=$((timeout_secs * 1000))
    while [ ! -f "$result_file" ]; do
      if [ "$timeout_secs" -gt 0 ] && [ "$elapsed" -ge "$timeout_ms" ]; then
        exit 1
      fi

      ${pkgs.coreutils}/bin/sleep 0.1
      elapsed=$((elapsed + 100))
    done

    ${pkgs.coreutils}/bin/cat "$result_file"
  '';

  cliphistNoctaliaPaste = pkgs.writeShellScriptBin "cliphist-noctalia-paste" ''
    set -euo pipefail

    items_file="$(${pkgs.coreutils}/bin/mktemp)"
    cleanup() {
      ${pkgs.coreutils}/bin/rm -f "$items_file"
    }
    trap cleanup EXIT

    ${pkgs.cliphist}/bin/cliphist list > "$items_file"
    if [ ! -s "$items_file" ]; then
      ${pkgs.libnotify}/bin/notify-send "Clipboard history empty"
      exit 0
    fi

    selection="$(${noctaliaDmenuSelect}/bin/noctalia-dmenu-select Clipboard "$items_file" 30 || true)"
    [ -n "$selection" ] || exit 0

    printf '%s' "$selection" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.coreutils}/bin/sleep 0.05
    ${clipboardPaste}/bin/clipboard-paste
  '';

  cliphistNoctaliaClear = pkgs.writeShellScriptBin "cliphist-noctalia-clear" ''
    set -euo pipefail

    items_file="$(${pkgs.coreutils}/bin/mktemp)"
    cleanup() {
      ${pkgs.coreutils}/bin/rm -f "$items_file"
    }
    trap cleanup EXIT

    printf 'No\nYes\n' > "$items_file"
    answer="$(${noctaliaDmenuSelect}/bin/noctalia-dmenu-select "Clear clipboard history?" "$items_file" 30 || true)"
    [ "$answer" = "Yes" ] || exit 0

    ${pkgs.cliphist}/bin/cliphist wipe
    ${pkgs.libnotify}/bin/notify-send "Clipboard history cleared."
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
    noctaliaDmenuSelect
    cliphistNoctaliaPaste
    cliphistNoctaliaClear
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "$modifier,C,sendshortcut,CTRL,Insert,activewindow"
    "$modifier,V,exec,clipboard-paste"
    "$modifier,X,sendshortcut,CTRL,X,activewindow"
    "$modifier CTRL,V,exec,cliphist-noctalia-paste"
    "$modifier SHIFT CTRL,V,exec,cliphist-noctalia-clear"
  ];

  systemd.user.services = {
    cliphist-text = mkCliphistWatcher "text" "Clipboard history watcher for text";
    cliphist-image = mkCliphistWatcher "image" "Clipboard history watcher for images";
  };
}
