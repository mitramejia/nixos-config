{
  lib,
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
in
  with lib; {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [wallpaper_img];
        wallpaper = [", ${wallpaper_img}"];
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      extraConfig = let
        modifier = "SUPER";
      in
        concatStrings [
          ''
             env = NIXOS_OZONE_WL, 1
             env = MOZ_ENABLE_WAYLAND, 1
             env = NIXPKGS_ALLOW_UNFREE, 1
             env = XDG_CURRENT_DESKTOP, Hyprland
             env = XDG_SESSION_TYPE, wayland
             env = XDG_SESSION_DESKTOP, Hyprland
             env = GDK_BACKEND, wayland, x11
             env = CLUTTER_BACKEND, wayland
             env = QT_QPA_PLATFORM=wayland;xcb
             env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
             env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
             env = SDL_VIDEODRIVER, x11
             env = GDK_SCALE, 1.25
             env = HYPRCURSOR_SIZE,14

             exec-once = dbus-update-activation-environment --systemd --all
             exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
             exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
             exec-once = waybar
             exec-once = hyprpaper
             exec-once = swaync

             exec-once = nm-applet --indicator
             exec-once = lxqt-policykit-agent


             monitor=DP-1,preferred,auto,1.25
             monitor=DP-2,preferred,auto,1.25,transform,3

             ${extraMonitorSettings}

             xwayland {
               force_zero_scaling = true
             }

             misc {
               focus_on_activate = false
             }

             general {
               gaps_in = 6
               gaps_out = 8
               layout = dwindle
               resize_on_border = true
               col.active_border = rgb(${config.stylix.base16Scheme.base08}) rgb(${config.stylix.base16Scheme.base0C}) 45deg
               col.inactive_border = rgb(${config.stylix.base16Scheme.base01})
             }
             input {
               kb_layout = ${keyboardLayout}
               kb_options = grp:alt_shift_toggle
               kb_options = caps:super
               follow_mouse = 1

               touchpad {
                 natural_scroll = true
                 disable_while_typing = true
                 scroll_factor = 0.8
               }
               sensitivity = 1 # -1.0 - 1.0, 0 means no modification.
               accel_profile = flat
             }

            windowrule = noborder,^(wofi)$
            windowrule = center,^(wofi)$
            windowrule = center,^(steam)$
            windowrule = float, nm-connection-editor|blueman-manager
            windowrule = float, swayimg|vlc|Viewnior|pavucontrol
            windowrule = float, nwg-look|qt5ct|mpv
            windowrulev2 = stayfocused, title:^()$,class:^(steam)$
            windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
            windowrulev2 = noinitialfocus,class:^(jetbrains-webstorm)$,floating:1
            windowrulev2 = noinitialfocus,class:^(jetbrains-datagrip)$,floating:1

            windowrulev2 = workspace 1, class:^(${browser})$
            windowrulev2 = workspace 2, class:^(jetbrains-webstorm)$
            windowrulev2 = workspace 3, class:^(jetbrains-datagrip)$
            windowrulev2 = workspace 4, class:^(slack)$
            windowrulev2 = workspace 4, class:^(zapzap)$
            windowrulev2 = workspace 6, class:^(Cider)$
            windowrulev2 = workspace 5, class:^(obsidian)$
            windowrulev2 = workspace 6, class:^(Cider)$
            windowrulev2 = workspace 7, class:^(Genymotion)$

            workspace = 1, monitor:DP-1, default:true
            workspace = 8, monitor:DP-2

            exec-once = [workspace 8 silent] kitty
            exec-once = [workspace 1 silent] ${browser}
            exec-once = [workspace 2 silent] webstorm
            exec-once = [workspace 3 silent] datagrip
            exec-once = [workspace 4 silent] slack
            exec-once = [workspace 4 silent] zapzap
            exec-once = [workspace 5 silent] obsidian
            exec-once = [workspace 6 silent] appimage-run ~/AppImages/Cider/Cider.AppImage
            exec-once = [workspace 7 silent] genymotion

            gestures {
              workspace_swipe = true
              workspace_swipe_fingers = 3
            }
            misc {
              initial_workspace_tracking = 0
              mouse_move_enables_dpms = true
              key_press_enables_dpms = false
            }
            animations {
              enabled = yes
              bezier = wind, 0.05, 0.9, 0.1, 1.05
              bezier = winIn, 0.1, 1.1, 0.1, 1.1
              bezier = winOut, 0.3, -0.3, 0, 1
              bezier = liner, 1, 1, 1, 1
              animation = windows, 1, 0.3, default
              animation = windowsIn, 1, 0.3, default
              animation = windowsOut, 1, 0.3, default
              animation = windowsMove, 1, 0.3, default
              animation = border, 1, 1, liner
              animation = fade, 1, 3, default
              animation = workspaces, 1, 3, wind
            }
            decoration {
              rounding = 10
              drop_shadow = true
              shadow_range = 4
              shadow_render_power = 3
              col.shadow = rgba(1a1a1aee)
              blur {
                  enabled = true
                  size = 5
                  passes = 3
                  new_optimizations = on
                  ignore_opacity = off
              }
            }
            plugin {
              hyprtrails {
              }
            }
            dwindle {
              pseudotile = true
              preserve_split = true
            }


             bind = ${modifier},Return,exec,${terminal}
             bind = ${modifier},SPACE,exec,rofi-launcher
             bind = ${modifier}SHIFT,W,exec,web-search
             bind = ${modifier}ALT,W,exec,wallsetter
             bind = ${modifier}SHIFT,N,exec,swaync-client -rs
             bind = ${modifier},W,exec,${browser}
             bind = ${modifier}SHIFT,E,exec,emopicker9000
             # Take screenshot
             bind = ${modifier},S,exec,grimblast save area
             bind = ${modifier},D,exec,discord
             bind = ${modifier},O,exec,obs
             bind = ${modifier},E,exec,hyprpicker -a
             bind = ${modifier},G,exec,gimp
             bind = ${modifier}SHIFT,G,exec,godot4
             bind = ${modifier},T,exec,thunar
             bind = ${modifier},M,exec,cider
             bind = ${modifier},Q,killactive
             bind = ${modifier},P,pseudo,
             bind = ${modifier}SHIFT,I,togglesplit,
             bind = ${modifier},F,fullscreen,
             bind = ${modifier}SHIFT,F,togglefloating,
             bind = ${modifier}SHIFT,Q,exit,
             bind = ${modifier}SHIFT,left,movewindow,l
             bind = ${modifier}SHIFT,right,movewindow,r
             bind = ${modifier}SHIFT,up,movewindow,u
             bind = ${modifier}SHIFT,down,movewindow,d
             bind = ${modifier}SHIFT,h,movewindow,l
             bind = ${modifier}SHIFT,l,movewindow,r
             bind = ${modifier}SHIFT,k,movewindow,u
             bind = ${modifier}SHIFT,j,movewindow,d
             bind = ${modifier},left,movefocus,l
             bind = ${modifier},right,movefocus,r
             bind = ${modifier},up,movefocus,u
             bind = ${modifier},down,movefocus,d
             bind = ${modifier},TAB,cyclenext
             bind = ${modifier},h,movefocus,l
             bind = ${modifier},l,movefocus,r
             bind = ${modifier},k,movefocus,u
             bind = ${modifier},j,movefocus,d
             bind = ${modifier},1,workspace,1
             bind = ${modifier},2,workspace,2
             bind = ${modifier},3,workspace,3
             bind = ${modifier},4,workspace,4
             bind = ${modifier},5,workspace,5
             bind = ${modifier},6,workspace,6
             bind = ${modifier},7,workspace,7
             bind = ${modifier},8,workspace,8
             bind = ${modifier},9,workspace,9
             bind = ${modifier},0,workspace,10
             # bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
             # bind = ${modifier},SPACE,togglespecialworkspace
             bind = ${modifier}SHIFT,1,movetoworkspace,1
             bind = ${modifier}SHIFT,2,movetoworkspace,2
             bind = ${modifier}SHIFT,3,movetoworkspace,3
             bind = ${modifier}SHIFT,4,movetoworkspace,4
             bind = ${modifier}SHIFT,5,movetoworkspace,5
             bind = ${modifier}SHIFT,6,movetoworkspace,6
             bind = ${modifier}SHIFT,7,movetoworkspace,7
             bind = ${modifier}SHIFT,8,movetoworkspace,8
             bind = ${modifier}SHIFT,9,movetoworkspace,9
             bind = ${modifier}SHIFT,0,movetoworkspace,10
             bind = ${modifier}CONTROL,right,workspace,e+1
             bind = ${modifier}CONTROL,left,workspace,e-1
             bind = ${modifier},mouse_down,workspace, e+1
             bind = ${modifier},mouse_up,workspace, e-1
             bindm = ${modifier},mouse:272,movewindow
             bindm = ${modifier},mouse:273,resizewindow
             bind = ${modifier},Tab,cyclenext
             bind = ${modifier},Tab,bringactivetotop
             # https://wiki.hyprland.org/Configuring/Variables/#binds - the values mentioned here obviously configure hyprland behaviour
             #https://wiki.hyprland.org/Configuring/Dispatchers/#workspaces - this part gives us the keywords/dispatchers and tell us what we can do with the workspace, for instance going to the previous workspace
             binds {
              allow_workspace_cycles = true
             }
             # Switch tabs
             bind = ALT, Tab, cyclenext
             bind = ALT, Tab, bringactivetotop
             bind = SHIFT ALT, Tab, cyclenext, prev
             # Cycle recent workspaces
             bind = ${modifier}, Tab, workspace,previous
             bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
             bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
             binde = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
             bind = ,XF86AudioPlay, exec, playerctl play-pause
             bind = ,XF86AudioPause, exec, playerctl play-pause
             bind = ,XF86AudioNext, exec, playerctl next
             bind = ,XF86AudioPrev, exec, playerctl previous
             bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
             bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%
          ''
        ];
    };
  }
