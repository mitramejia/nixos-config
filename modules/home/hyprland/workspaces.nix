_: let
  inherit (import ../../variables.nix) extraMonitorSettings;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    ${extraMonitorSettings}
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
  '';
}
