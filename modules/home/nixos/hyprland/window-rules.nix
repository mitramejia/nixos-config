{...}: let
  rule = match: effects: {inherit match;} // effects;
in {
  # Typed Nix tables become hl.window_rule calls in the 0.56 Lua backend.
  wayland.windowManager.hyprland.settings.window_rule = [
    (rule {
      title = "^()$";
      class = "^(steam)$";
    } {stay_focused = true;})
    (rule {
      title = "^()$";
      class = "^(steam)$";
    } {min_size = [1 1];})
    (rule {
      class = "^(.*jetbrains.*)$";
      title = "^(win.*)$";
    } {focus_on_activate = true;})
    (rule {class = "^dev.noctalia.Noctalia$";} {
      float = true;
      size = [1080 920];
    })
    (rule {
      float = true;
      class = "^(.*jetbrains.*)$";
    } {focus_on_activate = true;})
    (rule {class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$";} {tag = "+file-manager";})
    (rule {class = "^(org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$";} {tag = "+terminal";})
    (rule {class = "^(Brave-browser(-beta|-dev|-unstable)?)$";} {tag = "+browser";})
    (rule {class = "^(brave)$";} {tag = "+browser";})
    (rule {class = "^(zen|zen-beta)$";} {tag = "+browser";})
    (rule {class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";} {tag = "+browser";})
    (rule {class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$";} {tag = "+browser";})
    (rule {class = "^([Tt]horium-browser|[Cc]achy-browser)$";} {tag = "+browser";})
    (rule {class = "^(.*jetbrains.*)$";} {tag = "+projects";})
    (rule {class = "^(codium|codium-url-handler|VSCodium)$";} {tag = "+projects";})
    (rule {class = "^(VSCode|code-url-handler)$";} {tag = "+projects";})
    (rule {class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop|[Ss]lack)$";} {tag = "+im";})
    (rule {class = "^([Ww]hatsapp-for-linux|zapzap|com[.]rtosta[.]zapzap)$";} {tag = "+im";})
    (rule {class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$";} {tag = "+im";})
    (rule {class = "^(gamescope)$";} {tag = "+games";})
    (rule {class = "^(steam_app_\\d+)$";} {tag = "+games";})
    (rule {class = "^([Ss]team)$";} {tag = "+gamestore";})
    (rule {title = "^([Ll]utris)$";} {tag = "+gamestore";})
    (rule {class = "^(gnome-disks|wihotspot(-gui)?)$";} {tag = "+settings";})
    (rule {class = "^(file-roller|org.gnome.FileRoller)$";} {tag = "+settings";})
    (rule {class = "^(nm-applet|nm-connection-editor|blueman-manager)$";} {tag = "+settings";})
    (rule {class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";} {tag = "+settings";})
    (rule {class = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$";} {tag = "+settings";})
    (rule {class = "(xdg-desktop-portal-gtk)";} {tag = "+settings";})
    (rule {class = "(.blueman-manager-wrapped)";} {tag = "+settings";})
    (rule {class = "(nwg-displays)";} {tag = "+settings";})
    (rule {title = "^(Picture-in-Picture)$";} {move = ["72%" "7%"];})
    (rule {class = "^([Ff]erdium)$";} {center = true;})
    (rule {class = "^([Ww]aypaper)$";} {float = true;})
    (rule {class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";} {center = true;})
    (rule {
      class = "([Tt]hunar)";
      title = "negative:(.*[Tt]hunar.*)";
    } {center = true;})
    (rule {title = "^(Authentication Required)$";} {center = true;})
    (rule {class = "^.*$";} {idle_inhibit = "fullscreen";})
    (rule {title = "^.*$";} {idle_inhibit = "fullscreen";})
    (rule {fullscreen = 1;} {idle_inhibit = "fullscreen";})
    (rule {tag = "settings*";} {float = true;})
    (rule {class = "^([Ff]erdium)$";} {float = true;})
    (rule {title = "^(Picture-in-Picture)$";} {float = true;})
    (rule {class = "^(mpv|com.github.rafostar.Clapper)$";} {float = true;})
    (rule {title = "^(Authentication Required)$";} {float = true;})
    (rule {
      class = "(codium|codium-url-handler|VSCodium)";
      title = "negative:(.*codium.*|.*VSCodium.*)";
    } {float = true;})
    (rule {
      class = "^([Ss]team)$";
      title = "negative:^([Ss]team)$";
    } {float = true;})
    (rule {
      class = "([Tt]hunar)";
      title = "negative:(.*[Tt]hunar.*)";
    } {float = true;})
    (rule {initial_title = "(Add Folder to Workspace)";} {float = true;})
    (rule {initial_title = "(Open Files)";} {float = true;})
    (rule {initial_title = "(wants to save)";} {float = true;})
    (rule {initial_title = "(Open Files)";} {size = ["70%" "60%"];})
    (rule {initial_title = "(Add Folder to Workspace)";} {size = ["70%" "60%"];})
    (rule {tag = "settings*";} {size = ["70%" "70%"];})
    (rule {class = "^([Ff]erdium)$";} {size = ["60%" "70%"];})
    (rule {title = "^(Picture-in-Picture)$";} {pin = true;})
    (rule {title = "^(Picture-in-Picture)$";} {keep_aspect_ratio = true;})
    (rule {tag = "games*";} {no_blur = true;})
    (rule {tag = "games*";} {fullscreen = true;})
  ];
}
