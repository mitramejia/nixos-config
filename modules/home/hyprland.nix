{
  pkgs,
  config,
  ...
}:
let
  inherit (import ../variables.nix)
    browser
    terminal
    extraMonitorSettings
    keyboardLayout
    ;
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
          "$@"
      fi
    done

    echo "cider-appimage: no executable Cider AppImage found in $HOME/AppImages/Cider" >&2
    exit 1
  '';
in
{
  home.packages = [
    ciderAppImage
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };

    settings = {
      exec-once = [
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "nm-applet --indicator"
        "lxqt-policykit-agent"
        "noctalia-shell"
        "[workspace 1] ${browser}"
        "[workspace 2] bash webstorm"
        "[workspace 5] slack"
        "[workspace 6] obsidian"
        "[workspace 7] cider-appimage"
        "[workspace 9] kitty"
      ];

      env = [
        "NIXOS_OZONE_WL,1"
        "NIXPKGS_ALLOW_UNFREE,1"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "GDK_BACKEND,wayland,x11,*"
        "CLUTTER_BACKEND,wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        # Use stable udev aliases from modules/core/hardware.nix:
        # amd-rx9070 points to PCI 0000:03:00.0, and amd-igpu points to PCI 0000:12:00.0.
        # Find the source devices with `ls -l /dev/dri/by-path`, then match PCI IDs with `lspci -nnk`.
        # AQ_DRM_DEVICES is colon-separated, so raw by-path PCI names cannot be used because they contain ':'.
        # Hyprland uses the first entry as the primary GPU; card0/card1 can swap across boots.
        "AQ_DRM_DEVICES,/dev/dri/amd-rx9070:/dev/dri/amd-igpu"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "TERMINAL,kitty"
        "EDITOR,nvim"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      misc = {
        focus_on_activate = true;
        layers_hog_keyboard_focus = true;
        force_default_wallpaper = 0;
        initial_workspace_tracking = 0;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vfr = false; # Variable Frame Rate
      };

      #The selected code defines a configuration block for the `dwindle` layout in Hyprland, a Wayland compositor.
      #
      #- `pseudotile = true;`: Enables pseudotiling, which allows windows to appear tiled but not resize to fit the layout.
      #- `preserve_split = true;`: Ensures that the split direction of the layout is preserved when managing windows.
      #
      #This configuration is part of the `wayland.windowManager.hyprland.settings` block, which customizes the behavior and appearance of the Hyprland window manager.
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "${keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        follow_mouse = 1;
        float_switch_override_focus = 2;
        scroll_factor = 3;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
        sensitivity = 0.8; # -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat";
      };

      general = {
        "$modifier" = "SUPER";
        layout = "dwindle";
        gaps_in = 6;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" =
          "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 4;
          passes = 1;
          ignore_opacity = true;
          new_optimizations = true;
        };
        shadow = {
          enabled = false;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      render = {
        direct_scanout = 0;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      bind = [
        "$modifier,Return,exec,${terminal}"
        "$modifier,SPACE,exec,noctalia-shell ipc call launcher toggle"
        "$modifier SHIFT,W,exec,noctalia-shell ipc call plugin:web-search toggle"
        "$modifier ALT,F,exec,noctalia-shell ipc call plugin:file-search toggle"
        "$modifier,TAB,cyclenext"
        "$modifier,TAB,bringactivetotop"
        "$modifier CTRL,R,exec,noctalia-shell ipc call plugin:screen-recorder toggle"
        "$modifier ALT,T,exec,noctalia-shell ipc call plugin:timer toggle"
        "$modifier CTRL,L,exec,noctalia-shell ipc call lockScreen lock"
        "$modifier SHIFT,R,exec,restart.noctalia"
        "$modifier,W,exec,${browser}"
        "$modifier,M,exec,cider-appimage"
        # Take screenshot
        "$modifier,S,exec,sh -lc 'mkdir -p \"$HOME/Pictures/Screenshots\" && hyprshot -m region -o \"$HOME/Pictures/Screenshots\"'"
        "$modifier,D,exec,discord"
        "$modifier,O,exec,obs"
        "$modifier,E,exec,hyprpicker -a"
        "$modifier,G,exec,gimp"
        "$modifierSHIFT,G,exec,godot4"
        "$modifier,T,exec,yazy"
        "$modifier,Q,killactive"
        "$modifier,P,pseudo,"
        "$modifierSHIFT,I,togglesplit,"
        "$modifier,F,fullscreen,"
        "$modifierSHIFT,F,togglefloating,"
        "$modifierSHIFT,Q,exit,"
        "$modifierSHIFT,left,movewindow,l"
        "$modifierSHIFT,right,movewindow,r"
        "$modifierSHIFT,up,movewindow,u"
        "$modifierSHIFT,down,movewindow,d"
        "$modifierSHIFT,h,movewindow,l"
        "$modifierSHIFT,l,movewindow,r"
        "$modifierSHIFT,k,movewindow,u"
        "$modifierSHIFT,j,movewindow,d"
        "$modifier,left,movefocus,l"
        "$modifier,right,movefocus,r"
        # Volume up through wireplumber
        "$modifier,up,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        # Volume down through wireplumber
        "$modifier,down,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
        "$modifier,h,movefocus,l"
        "$modifier,l,movefocus,r"
        "$modifier,k,movefocus,u"
        "$modifier,j,movefocus,d"
        "$modifier,1,workspace,1"
        "$modifier,2,workspace,2"
        "$modifier,3,workspace,3"
        "$modifier,4,workspace,4"
        "$modifier,5,workspace,5"
        "$modifier,6,workspace,6"
        "$modifier,7,workspace,7"
        "$modifier,8,workspace,8"
        "$modifier,9,workspace,9"
        "$modifier,0,workspace,10"
        "$modifierSHIFT,1,movetoworkspace,1"
        "$modifierSHIFT,2,movetoworkspace,2"
        "$modifierSHIFT,3,movetoworkspace,3"
        "$modifierSHIFT,4,movetoworkspace,4"
        "$modifierSHIFT,5,movetoworkspace,5"
        "$modifierSHIFT,6,movetoworkspace,6"
        "$modifierSHIFT,7,movetoworkspace,7"
        "$modifierSHIFT,8,movetoworkspace,8"
        "$modifierSHIFT,9,movetoworkspace,9"
        "$modifierSHIFT,0,movetoworkspace,10"
        "$modifierCONTROL,right,workspace,e+1"
        "$modifierCONTROL,left,workspace,e-1"
        "$modifier,mouse_down,workspace, e+1"
        "$modifier,mouse_up,workspace, e-1"
        # https://wiki.hyprland.org/Configuring/Variables/#binds - the values mentioned here obviously configure hyprland behaviour
        # https://wiki.hyprland.org/Configuring/Dispatchers/#workspaces - this part gives us the keywords/dispatchers and tell us what we can do with the workspace, for instance going to the previous workspace
        # Cycle recent workspaces
        "$modifier, Tab, workspace,previous"
        # Switch tabs
        "ALT, Tab, cyclenext"
        "ALT, Tab, bringactivetotop"
        "SHIFT ALT, Tab, cyclenext, prev"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
      ];

      bindm = [
        "$modifier, mouse:272, movewindow"
        "$modifier, mouse:273, resizewindow"
      ];

      binds = {
        allow_workspace_cycles = true;
      };

      windowrulev2 = [
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
        "focusonactivate, class:^(.*jetbrains.*)$, title:^(win.*)$"
        "focusonactivate, floating:1, class:^(.*jetbrains.*)$"
        # fix tooltips (always have a title of `win.<id>`)
        #        "noinitialfocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
        #        "nofocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
        # fix tab dragging (always have a single space character as their title)
        #        "noinitialfocus, class:^(.*jetbrains.*)$, title:^\\s$"
        #        "nofocus, class:^(.*jetbrains.*)$, title:^\\s$"
        "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, class:^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
        "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^(brave)$"
        "tag +browser, class:^(zen)$"
        "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
        "tag +projects, class:^(.*jetbrains.*)$"
        "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, class:^(VSCode|code-url-handler)$"
        "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, class:^([Ww]hatsapp-for-linux)$"
        "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +games, class:^(gamescope)$"
        "tag +games, class:^(steam_app_\d+)$"
        "tag +gamestore, class:^([Ss]team)$"
        "tag +gamestore, title:^([Ll]utris)$"
        "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "tag +settings, class:^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, class:(xdg-desktop-portal-gtk)"
        "tag +settings, class:(.blueman-manager-wrapped)"
        "tag +settings, class:(nwg-displays)"
        "move 72% 7%,title:^(Picture-in-Picture)$"
        "center, class:^([Ff]erdium)$"
        "float, class:^([Ww]aypaper)$"
        "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "center, title:^(Authentication Required)$"
        "idleinhibit fullscreen, class:^(*)$"
        "idleinhibit fullscreen, title:^(*)$"
        "idleinhibit fullscreen, fullscreen:1"
        "float, tag:settings*"
        "float, class:^([Ff]erdium)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(mpv|com.github.rafostar.Clapper)$"
        "float, title:^(Authentication Required)$"
        "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
        "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
        "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "float, initialTitle:(Add Folder to Workspace)"
        "float, initialTitle:(Open Files)"
        "float, initialTitle:(wants to save)"
        "size 70% 60%, initialTitle:(Open Files)"
        "size 70% 60%, initialTitle:(Add Folder to Workspace)"
        "size 70% 70%, tag:settings*"
        "size 60% 70%, class:^([Ff]erdium)$"
        "pin, title:^(Picture-in-Picture)$"
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "noblur, tag:games*"
        "fullscreen, tag:games*"
        "workspace 1, tag:browser*"
        "workspace 5, tag:im*"
        "workspace 8, tag:games*"
        "workspace 6, class:^(obsidian)$"
        "workspace 7, class:^(Cider)$"
      ];

      animations = {
        enabled = true;
        bezier = [
          "easeOut, 0.25, 1, 0.5, 1"
          "easeInOut, 0.42, 0, 0.58, 1"
        ];
        animation = [
          "windows, 1, 2, easeOut, popin 80%"
          "windowsOut, 1, 1, easeInOut"
          "windowsIn, 1, 1, easeOut"
          "windowsMove, 1, 2, easeInOut"
          "fade, 1, 2, easeOut"
          "workspaces, 1, 2, easeOut"
        ];
      };
    };

    extraConfig = "
        ${
              extraMonitorSettings
            }
        workspace = 1, monitor:DP-1, default:true
        workspace = 2, monitor:DP-1, default:true
        workspace = 3, monitor:DP-1, default:true
        workspace = 4, monitor:DP-1, default:true
        workspace = 5, monitor:DP-1, default:true
        workspace = 6, monitor:DP-1, default:true
        workspace = 7, monitor:DP-1, default:true
        workspace = 8, monitor:DP-1, default:true
        workspace = 9, monitor:DP-2, default:true
        workspace = 10, monitor:DP-2, default:true
     ";
  };
}
