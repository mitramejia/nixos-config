{config, ...}: let
  inherit (import ../../variables.nix) keyboardLayout;
in {
  wayland.windowManager.hyprland.settings = {
    xwayland.force_zero_scaling = true;

    misc = {
      focus_on_activate = true;
      layers_hog_keyboard_focus = true;
      force_default_wallpaper = 0;
      initial_workspace_tracking = 0;
      key_press_enables_dpms = false;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      enable_swallow = false;
    };

    # Hyprland 0.55 moved vfr from misc -> debug.
    debug.vfr = false;

    dwindle.preserve_split = true;

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
      sensitivity = 0.8;
      accel_profile = "flat";
    };

    general = {
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
      no_hardware_cursors = 2;
      enable_hyprcursor = false;
      warp_on_change_workspace = 2;
      no_warps = true;
    };

    render.direct_scanout = 0;

    master = {
      new_status = "master";
      new_on_top = 1;
      mfact = 0.5;
    };

    binds.allow_workspace_cycles = true;
  };
}
