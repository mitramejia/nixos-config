{
  lib,
  pkgs,
  host,
  config,
  ...
}: let
  inherit
    (import ../hosts/${host}/variables.nix)
    browser
    terminal
    extraMonitorSettings
    keyboardLayout
    wallpaper_img
    ;
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [wallpaper_img];
      wallpaper = [", ${wallpaper_img}"];
    };
  };

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
      variables = ["--all"];
    };

    settings = {
      exec-once = [
        "dbus-update-activation-environment --systemd --all"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "nm-applet --indicator"
        "lxqt-policykit-agent"
        "hyprpanel & hyprpaper"
        "[workspace 1 silent] ${browser}"
        "[workspace 5 silent] slack"
        "[workspace 5 silent] discord"
        "[workspace 6 silent] obsidian"
        "[workspace 7 silent] flatpak run sh.cider.genten"
        "[workspace 9 silent] kitty"
        "[workspace 2] bash webstorm"
      ];

      env = [
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,nvim"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      misc = {
        focus_on_activate = false;
        layers_hog_keyboard_focus = true;
        force_default_wallpaper = 0;
        initial_workspace_tracking = 0;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vfr = true; # Variable Frame Rate
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
        follow_mouse = 2;
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
        "col.active_border" = "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
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

      gestures = {
        workspace_swipe = 1;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 500;
        workspace_swipe_invert = 1;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = 1;
        workspace_swipe_forever = 1;
      };

      bind = [
        "$modifier,Return,exec,${terminal}"
        "$modifier,SPACE,exec,rofi-launcher"
        "$modifierSHIFT,W,exec,web-search"
        "$modifierSHIFT,N,exec,swaync-client -rs"
        "$modifier,W,exec,${browser}"
        "$modifierSHIFT,E,exec,emopicker9000"
        "$modifier,M,exec,flatpak run sh.cider.genten"
        # Take screenshot
        "$modifier,S,exec,grimblast save area"
        "$modifier,D,exec,discord"
        "$modifier,O,exec,obs"
        "$modifier,E,exec,hyprpicker -a"
        "$modifier,G,exec,gimp"
        "$modifierSHIFT,G,exec,godot4"
        "$modifier,T,exec,thunar"
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
        "$modifier,TAB,cyclenext"
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
        "$modifier,Tab,cyclenext"
        "$modifier,Tab,bringactivetotop"
        # https://wiki.hyprland.org/Configuring/Variables/#binds - the values mentioned here obviously configure hyprland behaviour
        #https://wiki.hyprland.org/Configuring/Dispatchers/#workspaces - this part gives us the keywords/dispatchers and tell us what we can do with the workspace, for instance going to the previous workspace
        # Switch tabs
        "ALT, Tab, cyclenext"
        "ALT, Tab, bringactivetotop"
        "SHIFT ALT, Tab, cyclenext, prev"
        # Cycle recent workspaces
        "$modifier, Tab, workspace,previous"
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
        "center,class:^jetbrains-(?!toolbox),floating:1"
        "move 30% 30%,class:^jetbrains-(?!toolbox),title:^(?!win.*),floating:1"
        "size 40% 40%,class:^jetbrains-(?!toolbox),title:^(?!win.*),floating:1"
        # center the pops excepting context menu"
        "workspace 1, class:^(${browser})$"
        "workspace 5, class:^(slack)$"
        "workspace 5, class:^(zapzap)$"
        "workspace 5, class:^(discord)$"
        "noblur, tag:games*"
        "fullscreen, tag:games*"
        "workspace 6, class:^(obsidian)$"
        "workspace 7, class:^(Cider)$"
      ];
      windowrule = [
        "noborder,^(wofi)$"
        "center,^(wofi)$"
        "center,^(steam)$"
        "float, nm-connection-editor|blueman-manager"
        "float, vlc|Viewnior|pavucontrol"
        "float, nwg-look|qt5ct|mpv"
      ];

      animations = {
        enabled = true;
        bezier = [
          "wind, -1.05, 0.9, 0.1, 1.05"
          "winIn, -1.1, 1.1, 0.1, 1.1"
          "winOut, -1.3, -0.3, 0, 1"
          "liner, 0, 1, 1, 1"
        ];
        animation = [
          "windows, 0, 6, wind, slide"
          "windowsIn, 0, 6, winIn, slide"
          "windowsOut, 0, 5, winOut, slide"
          "windowsMove, 0, 5, wind, slide"
          "border, 0, 1, liner"
          "fade, 0, 10, default"
          "workspaces, 0, 5, wind"
        ];
      };
    };

    extraConfig = "
        ${extraMonitorSettings}

        workspace = 1, monitor:DP-1, default:true
        workspace = 2, monitor:DP-1, default:true
        workspace = 3, monitor:DP-1, default:true
        workspace = 4, monitor:DP-1, default:true
        workspace = 5, monitor:DP-1, default:true
        workspace = 6, monitor:DP-1, default:true
        workspace = 7, monitor:DP-1, default:true
        workspace = 8, monitor:DP-1, default:true
        workspace = 9, monitor:DP-2, default: true

     ";
  };
}
