_: let
  inherit (import ../../../variables.nix) extraMonitorSettings;
in {
  wayland.windowManager.hyprland.settings = {
    # Each Nix attrset is rendered as one hl.monitor call.
    monitor = extraMonitorSettings;
    workspace_rule =
      map (workspace: {
        inherit workspace;
        monitor = "DP-1";
        default = true;
      }) ["1" "2" "3" "4" "5" "6" "7" "8"]
      ++ map (workspace: {
        inherit workspace;
        monitor = "DP-2";
        default = true;
      }) ["9" "10"];
  };
}
