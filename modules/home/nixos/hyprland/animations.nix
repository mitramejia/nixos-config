_: {
  wayland.windowManager.hyprland.settings = {
    config.animations.enabled = true;
    curve = [
      {
        _args = [
          "easeOut"
          {
            type = "bezier";
            points = [
              [0.25 1]
              [0.5 1]
            ];
          }
        ];
      }
      {
        _args = [
          "easeInOut"
          {
            type = "bezier";
            points = [
              [0.42 0]
              [0.58 1]
            ];
          }
        ];
      }
    ];
    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 2;
        bezier = "easeOut";
        style = "popin 80%";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 1;
        bezier = "easeInOut";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 1;
        bezier = "easeOut";
      }
      {
        leaf = "windowsMove";
        enabled = true;
        speed = 2;
        bezier = "easeInOut";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 2;
        bezier = "easeOut";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 2;
        bezier = "easeOut";
      }
    ];
  };
}
