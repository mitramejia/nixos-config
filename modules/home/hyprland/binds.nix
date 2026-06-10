{lib, ...}: let
  inherit
    (import ../../variables.nix)
    browser
    terminal
    ;

  mk = key: description: binding: {inherit key description binding;};

  workspaceKeys = (map builtins.toString (lib.range 1 9)) ++ ["0"];
  workspaceNumbers = (map builtins.toString (lib.range 1 9)) ++ ["10"];

  workspaceBindings =
    lib.concatLists
    (lib.imap0 (index: key: let
        workspace = builtins.elemAt workspaceNumbers index;
      in [
        (mk "Super+${key}" "Switch to workspace ${workspace}" "$modifier,${key},workspace,${workspace}")
        (mk "Super+Shift+${key}" "Move window to workspace ${workspace}" "$modifier SHIFT,${key},movetoworkspace,${workspace}")
      ])
      workspaceKeys);

  mediaBindings = [
    (mk "XF86AudioRaiseVolume" "Raise volume" ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    (mk "XF86AudioLowerVolume" "Lower volume" ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    (mk "XF86AudioMute" "Toggle mute" " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    (mk "XF86AudioPlay" "Play or pause" ",XF86AudioPlay, exec, playerctl play-pause")
    (mk "XF86AudioPause" "Play or pause" ",XF86AudioPause, exec, playerctl play-pause")
    (mk "XF86AudioNext" "Next track" ",XF86AudioNext, exec, playerctl next")
    (mk "XF86AudioPrev" "Previous track" ",XF86AudioPrev, exec, playerctl previous")
    (mk "XF86MonBrightnessDown" "Lower brightness" ",XF86MonBrightnessDown,exec,brightnessctl set 5%-")
    (mk "XF86MonBrightnessUp" "Raise brightness" ",XF86MonBrightnessUp,exec,brightnessctl set +5%")
  ];

  keybindings =
    [
      (mk "Super+Return" "Open terminal" "$modifier,Return,exec,${terminal}")
      (mk "Super+Space" "Toggle Noctalia launcher" "$modifier,SPACE,exec,noctalia msg panel-toggle launcher")
      (mk "Super+Shift+W" "Toggle web search" "$modifier SHIFT,W,exec,noctalia msg plugin:web-search toggle")
      (mk "Super+Alt+F" "Toggle file search" "$modifier ALT,F,exec,noctalia msg plugin:file-search toggle")
      (mk "Super+Tab" "Cycle next window" "$modifier,TAB,cyclenext")
      (mk "Super+Tab" "Bring cycled window to top" "$modifier,TAB,bringactivetotop")
      (mk "Super+Ctrl+R" "Toggle screen recorder" "$modifier CTRL,R,exec,noctalia msg plugin:screen-recorder toggle")
      (mk "Super+Alt+T" "Toggle timer" "$modifier ALT,T,exec,noctalia msg plugin:timer toggle")
      (mk "Super+Ctrl+L" "Lock session" "$modifier CTRL,L,exec,noctalia msg session lock")
      (mk "Super+Shift+R" "Restart Noctalia" "$modifier SHIFT,R,exec,restart.noctalia")
      (mk "Super+W" "Open browser" "$modifier,W,exec,${browser}")
      (mk "Super+M" "Open Cider" "$modifier,M,exec,cider-appimage")
      (mk "Super+S" "Take region screenshot" "$modifier,S,exec,sh -lc 'mkdir -p \"$HOME/Pictures/Screenshots\" && hyprshot -m region -o \"$HOME/Pictures/Screenshots\"'")
      (mk "Super+D" "Open Discord" "$modifier,D,exec,discord")
      (mk "Super+O" "Open OBS" "$modifier,O,exec,obs")
      (mk "Super+E" "Pick color" "$modifier,E,exec,hyprpicker -a")
      (mk "Super+G" "Open GIMP" "$modifier,G,exec,gimp")
      (mk "Super+Shift+G" "Open Godot" "$modifier SHIFT,G,exec,godot4")
      (mk "Super+T" "Open Yazi" "$modifier,T,exec,${terminal} -e yazi")
      (mk "Super+Q" "Kill active window" "$modifier,Q,killactive")
      (mk "Super+P" "Toggle pseudo tiling" "$modifier,P,pseudo,")
      (mk "Super+Shift+I" "Toggle split" "$modifier SHIFT,I,layoutmsg,togglesplit")
      (mk "Super+F" "Toggle fullscreen" "$modifier,F,fullscreen,")
      (mk "Super+Shift+F" "Toggle floating" "$modifier SHIFT,F,togglefloating,")
      (mk "Super+Shift+Q" "Exit Hyprland" "$modifier SHIFT,Q,exit,")
      (mk "Super+Shift+Left" "Move window left" "$modifier SHIFT,left,movewindow,l")
      (mk "Super+Shift+Right" "Move window right" "$modifier SHIFT,right,movewindow,r")
      (mk "Super+Shift+Up" "Move window up" "$modifier SHIFT,up,movewindow,u")
      (mk "Super+Shift+Down" "Move window down" "$modifier SHIFT,down,movewindow,d")
      (mk "Super+Shift+H" "Move window left" "$modifier SHIFT,h,movewindow,l")
      (mk "Super+Shift+L" "Move window right" "$modifier SHIFT,l,movewindow,r")
      (mk "Super+Shift+K" "Move window up" "$modifier SHIFT,k,movewindow,u")
      (mk "Super+Shift+J" "Move window down" "$modifier SHIFT,j,movewindow,d")
      (mk "Super+Left" "Focus left" "$modifier,left,movefocus,l")
      (mk "Super+Right" "Focus right" "$modifier,right,movefocus,r")
      (mk "Super+Up" "Raise volume" "$modifier,up,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
      (mk "Super+Down" "Lower volume" "$modifier,down,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-")
      (mk "Super+H" "Focus left" "$modifier,h,movefocus,l")
      (mk "Super+L" "Focus right" "$modifier,l,movefocus,r")
      (mk "Super+K" "Focus up" "$modifier,k,movefocus,u")
      (mk "Super+J" "Focus down" "$modifier,j,movefocus,d")
    ]
    ++ workspaceBindings
    ++ [
      (mk "Super+Ctrl+Right" "Next workspace" "$modifier CONTROL,right,workspace,e+1")
      (mk "Super+Ctrl+Left" "Previous workspace" "$modifier CONTROL,left,workspace,e-1")
      (mk "Super+MouseDown" "Next workspace" "$modifier,mouse_down,workspace, e+1")
      (mk "Super+MouseUp" "Previous workspace" "$modifier,mouse_up,workspace, e-1")
      (mk "Super+Tab" "Previous workspace" "$modifier, Tab, workspace,previous")
      (mk "Alt+Tab" "Cycle next window" "ALT, Tab, cyclenext")
      (mk "Alt+Tab" "Bring cycled window to top" "ALT, Tab, bringactivetotop")
      (mk "Shift+Alt+Tab" "Cycle previous window" "SHIFT ALT, Tab, cyclenext, prev")
    ]
    ++ mediaBindings;
in {
  wayland.windowManager.hyprland.settings = {
    bind = map (binding: binding.binding) keybindings;

    bindm = [
      "$modifier, mouse:272, movewindow"
      "$modifier, mouse:273, resizewindow"
    ];
  };

  home.file.".config/hypr/keybindings.md".text =
    ''
      # Hyprland Keybindings

      Generated from `modules/home/hyprland/binds.nix`.

    ''
    + lib.concatMapStrings (binding: "- `${binding.key}`: ${binding.description}\n") keybindings;
}
