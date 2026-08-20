{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (import ../../../variables.nix)
    browser
    terminal
    ;

  inherit (lib) mkOption types;
  lua = lib.generators.mkLuaInline;

  mk = key: description: action: {
    inherit key description action;
    mouse = false;
    document = true;
  };
  mkMouse = key: action: {
    inherit key action;
    description = null;
    mouse = true;
    document = false;
  };

  normalizeModifier = modifier:
    {
      Super = "$modifier";
      Shift = "SHIFT";
      Ctrl = "CTRL";
      Control = "CONTROL";
      Alt = "ALT";
    }.${
      modifier
    } or (throw "Unsupported Hyprland key modifier: ${modifier}");

  normalizeKey = key:
    {
      MouseDown = "mouse_down";
      MouseUp = "mouse_up";
    }.${
      key
    } or key;

  parseKey = key: let
    parts = lib.splitString "+" key;
  in
    if builtins.length parts < 1
    then throw "Hyprland keybinding must declare a key."
    else {
      modifiers = map normalizeModifier (lib.init parts);
      key = normalizeKey (builtins.elemAt parts (builtins.length parts - 1));
    };

  renderKey = {
    modifiers,
    key,
  }: let
    modifiersWithPlus = lib.concatStringsSep " + " modifiers;
  in
    if modifiersWithPlus == ""
    then builtins.toJSON key
    else if lib.hasPrefix "$modifier" modifiersWithPlus
    then "mod .. ${builtins.toJSON "${lib.removePrefix "$modifier" modifiersWithPlus} + ${key}"}"
    else builtins.toJSON "${modifiersWithPlus} + ${key}";

  directionFor = direction:
    {
      l = "left";
      r = "right";
      u = "up";
      d = "down";
    }.${
      direction
    } or (throw "Unsupported Hyprland direction: ${direction}");

  actionToLua = action: let
    actionNames = builtins.attrNames action;
    requireAction = name:
      if actionNames == [name]
      then action.${name}
      else throw "Unsupported Hyprland action: ${builtins.concatStringsSep ", " actionNames}";
  in
    if builtins.hasAttr "exec" action
    then lua "hl.dsp.exec_cmd(${builtins.toJSON (requireAction "exec")})"
    else if builtins.hasAttr "cycleAndBringToTop" action
    then
      assert requireAction "cycleAndBringToTop";
        lua ''
          function()
            hl.dispatch(hl.dsp.window.cycle_next())
            hl.dispatch(hl.dsp.window.bring_to_top())
          end
        ''
    else if builtins.hasAttr "cycleNext" action
    then
      if requireAction "cycleNext" == "previous"
      then lua "hl.dsp.window.cycle_next({ next = false })"
      else if requireAction "cycleNext" == "next"
      then lua "hl.dsp.window.cycle_next()"
      else throw "Unsupported cycle-next direction: ${requireAction "cycleNext"}"
    else if builtins.hasAttr "bringActiveToTop" action
    then
      assert requireAction "bringActiveToTop";
        lua "hl.dsp.window.bring_to_top()"
    else if builtins.hasAttr "closeActive" action
    then
      assert requireAction "closeActive";
        lua "hl.dsp.window.close()"
    else if builtins.hasAttr "pseudo" action
    then
      assert requireAction "pseudo";
        lua "hl.dsp.window.pseudo()"
    else if builtins.hasAttr "layout" action
    then lua "hl.dsp.layout(${builtins.toJSON (requireAction "layout")})"
    else if builtins.hasAttr "fullscreen" action
    then
      assert requireAction "fullscreen";
        lua ''hl.dsp.window.fullscreen({ action = "toggle" })''
    else if builtins.hasAttr "toggleFloating" action
    then
      assert requireAction "toggleFloating";
        lua ''hl.dsp.window.float({ action = "toggle" })''
    else if builtins.hasAttr "exit" action
    then
      assert requireAction "exit";
        lua "hl.dsp.exit()"
    else if builtins.hasAttr "moveWindow" action
    then
      if requireAction "moveWindow" == null
      then lua "hl.dsp.window.drag()"
      else lua ''hl.dsp.window.move({ direction = "${directionFor (requireAction "moveWindow")}" })''
    else if builtins.hasAttr "resizeWindow" action
    then
      assert requireAction "resizeWindow";
        lua "hl.dsp.window.resize()"
    else if builtins.hasAttr "focus" action
    then lua ''hl.dsp.focus({ direction = "${directionFor (requireAction "focus")}" })''
    else if builtins.hasAttr "workspace" action
    then lua "hl.dsp.focus({ workspace = ${builtins.toJSON (requireAction "workspace")} })"
    else if builtins.hasAttr "moveToWorkspace" action
    then lua "hl.dsp.window.move({ workspace = ${builtins.toJSON (requireAction "moveToWorkspace")} })"
    else throw "Unsupported Hyprland action: ${builtins.concatStringsSep ", " actionNames}";

  renderBinding = binding: {
    _args =
      [
        (lua (renderKey (parseKey binding.key)))
        (actionToLua binding.action)
      ]
      ++ lib.optional binding.mouse {mouse = true;};
  };

  workspaceKeys = (map builtins.toString (lib.range 1 9)) ++ ["0"];
  workspaceNumbers = (map builtins.toString (lib.range 1 9)) ++ ["10"];

  workspaceBindings = lib.concatLists (lib.imap0 (index: key: let
      workspace = builtins.elemAt workspaceNumbers index;
    in [
      (mk "Super+${key}" "Switch to workspace ${workspace}" {workspace = workspace;})
      (mk "Super+Shift+${key}" "Move window to workspace ${workspace}" {moveToWorkspace = workspace;})
    ])
    workspaceKeys);

  mediaBindings = [
    (mk "XF86AudioRaiseVolume" "Raise volume" {exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";})
    (mk "XF86AudioLowerVolume" "Lower volume" {exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";})
    (mk "XF86AudioMute" "Toggle mute" {exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";})
    (mk "XF86AudioPlay" "Play or pause" {exec = "playerctl play-pause";})
    (mk "XF86AudioPause" "Play or pause" {exec = "playerctl play-pause";})
    (mk "XF86AudioNext" "Next track" {exec = "playerctl next";})
    (mk "XF86AudioPrev" "Previous track" {exec = "playerctl previous";})
    (mk "XF86MonBrightnessDown" "Lower brightness" {exec = "brightnessctl set 5%-";})
    (mk "XF86MonBrightnessUp" "Raise brightness" {exec = "brightnessctl set +5%";})
  ];

  keybindings =
    [
      (mk "Super+Return" "Open terminal" {exec = terminal;})
      ((mk "Super+SPACE" "Toggle Noctalia launcher" {exec = "noctalia msg panel-toggle launcher";}) // {documentationKey = "Super+Space";})
      (mk "Super+Shift+W" "Toggle web search" {exec = "noctalia msg plugin:web-search toggle";})
      (mk "Super+Alt+F" "Toggle file search" {exec = "noctalia msg plugin:file-search toggle";})
      ((mk "Super+TAB" "Switch to previous workspace" {workspace = "previous";}) // {documentationKey = "Super+Tab";})
      (mk "Super+Ctrl+R" "Toggle screen recorder" {exec = "noctalia msg plugin:screen-recorder toggle";})
      (mk "Super+Alt+T" "Toggle timer" {exec = "noctalia msg plugin:timer toggle";})
      (mk "Super+Ctrl+L" "Lock session" {exec = "noctalia msg session lock";})
      (mk "Super+Shift+R" "Restart Noctalia" {exec = "restart.noctalia";})
      (mk "Super+W" "Open browser" {exec = browser;})
      (mk "Super+M" "Open Cider" {exec = "cider-appimage";})
      (mk "Super+S" "Take region screenshot" {exec = "sh -lc 'mkdir -p \"$HOME/Pictures/Screenshots\" && hyprshot -m region -o \"$HOME/Pictures/Screenshots\"'";})
      (mk "Super+D" "Open Discord" {exec = "discord";})
      (mk "Super+O" "Open OBS" {exec = "obs";})
      (mk "Super+E" "Pick color" {exec = "hyprpicker -a";})
      (mk "Super+G" "Open GIMP" {exec = "gimp";})
      (mk "Super+Shift+G" "Open Godot" {exec = "godot4";})
      (mk "Super+T" "Open Yazi" {exec = "${terminal} -e yazi";})
      (mk "Super+Q" "Close active window" {closeActive = true;})
      (mk "Super+P" "Toggle pseudo tiling" {pseudo = true;})
      (mk "Super+Shift+I" "Toggle split" {layout = "togglesplit";})
      (mk "Super+F" "Toggle fullscreen" {fullscreen = true;})
      (mk "Super+Shift+F" "Toggle floating" {toggleFloating = true;})
      (mk "Super+Shift+Q" "Exit Hyprland" {exit = true;})
      ((mk "Super+Shift+left" "Move window left" {moveWindow = "l";}) // {documentationKey = "Super+Shift+Left";})
      ((mk "Super+Shift+right" "Move window right" {moveWindow = "r";}) // {documentationKey = "Super+Shift+Right";})
      ((mk "Super+Shift+up" "Move window up" {moveWindow = "u";}) // {documentationKey = "Super+Shift+Up";})
      ((mk "Super+Shift+down" "Move window down" {moveWindow = "d";}) // {documentationKey = "Super+Shift+Down";})
      ((mk "Super+Shift+h" "Move window left" {moveWindow = "l";}) // {documentationKey = "Super+Shift+H";})
      ((mk "Super+Shift+l" "Move window right" {moveWindow = "r";}) // {documentationKey = "Super+Shift+L";})
      ((mk "Super+Shift+k" "Move window up" {moveWindow = "u";}) // {documentationKey = "Super+Shift+K";})
      ((mk "Super+Shift+j" "Move window down" {moveWindow = "d";}) // {documentationKey = "Super+Shift+J";})
      ((mk "Super+left" "Focus left" {focus = "l";}) // {documentationKey = "Super+Left";})
      ((mk "Super+right" "Focus right" {focus = "r";}) // {documentationKey = "Super+Right";})
      ((mk "Super+up" "Raise volume" {exec = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";}) // {documentationKey = "Super+Up";})
      ((mk "Super+down" "Lower volume" {exec = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";}) // {documentationKey = "Super+Down";})
      ((mk "Super+h" "Focus left" {focus = "l";}) // {documentationKey = "Super+H";})
      ((mk "Super+l" "Focus right" {focus = "r";}) // {documentationKey = "Super+L";})
      ((mk "Super+k" "Focus up" {focus = "u";}) // {documentationKey = "Super+K";})
      ((mk "Super+j" "Focus down" {focus = "d";}) // {documentationKey = "Super+J";})
    ]
    ++ workspaceBindings
    ++ [
      ((mk "Super+Control+right" "Next workspace" {workspace = "e+1";}) // {documentationKey = "Super+Ctrl+Right";})
      ((mk "Super+Control+left" "Previous workspace" {workspace = "e-1";}) // {documentationKey = "Super+Ctrl+Left";})
      (mk "Super+MouseDown" "Next workspace" {workspace = "e+1";})
      (mk "Super+MouseUp" "Previous workspace" {workspace = "e-1";})
    ]
    ++ mediaBindings;

  mouseBindings = [
    (mkMouse "Super+mouse:272" {moveWindow = null;})
    (mkMouse "Super+mouse:273" {resizeWindow = true;})
  ];

  luaBindings = map renderBinding (keybindings ++ mouseBindings);
  documentation =
    ''
      # Hyprland Keybindings

      Generated from `modules/home/nixos/hyprland/binds.nix`.

    ''
    + lib.concatMapStrings (binding: "- `${binding.documentationKey or binding.key}`: ${binding.description}\n") (lib.filter (binding: binding.document) keybindings);

  representativeBindings = [
    (mk "Super+Return" "Open terminal" {exec = terminal;})
    (mk "Super+1" "Switch to workspace 1" {workspace = "1";})
    (mk "XF86AudioRaiseVolume" "Raise volume" {exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";})
    (mkMouse "Super+mouse:272" {moveWindow = null;})
  ];
  caseSensitiveBindings = [
    (mk "Super+SPACE" "Toggle Noctalia launcher" {exec = "noctalia msg panel-toggle launcher";})
    (mk "Super+TAB" "Switch to previous workspace" {workspace = "previous";})
    (mk "Super+Shift+left" "Move window left" {moveWindow = "l";})
    (mk "Super+right" "Focus right" {focus = "r";})
    (mk "Super+Control+right" "Next workspace" {workspace = "e+1";})
  ];
  invalidAction = builtins.tryEval (builtins.deepSeq (renderBinding (mk "Super+I" "Invalid action" {unsupported = true;})) true);

  keybindingCheck = let
    inherit (lib) assertMsg take;
    finalBindings = config.wayland.windowManager.hyprland.settings.bind;
    expectedRepresentativeBindings = [
      {
        _args = [
          (lua ''mod .. " + Return"'')
          (lua ''hl.dsp.exec_cmd("kitty")'')
        ];
      }
      {
        _args = [
          (lua ''mod .. " + 1"'')
          (lua ''hl.dsp.focus({ workspace = "1" })'')
        ];
      }
      {
        _args = [
          (lua ''"XF86AudioRaiseVolume"'')
          (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'')
        ];
      }
      {
        _args = [
          (lua ''mod .. " + mouse:272"'')
          (lua ''hl.dsp.window.drag()'')
          {mouse = true;}
        ];
      }
    ];
  in
    assert assertMsg (map renderBinding representativeBindings == expectedRepresentativeBindings) "Hyprland keybinding intent must render normal, workspace, media, and mouse bindings as Lua.";
    assert assertMsg (map renderBinding caseSensitiveBindings
      == [
        {
          _args = [
            (lua ''mod .. " + SPACE"'')
            (lua ''hl.dsp.exec_cmd("noctalia msg panel-toggle launcher")'')
          ];
        }
        {
          _args = [
            (lua ''mod .. " + TAB"'')
            (lua ''hl.dsp.focus({ workspace = "previous" })'')
          ];
        }
        {
          _args = [
            (lua ''mod .. " + SHIFT + left"'')
            (lua ''hl.dsp.window.move({ direction = "left" })'')
          ];
        }
        {
          _args = [
            (lua ''mod .. " + right"'')
            (lua ''hl.dsp.focus({ direction = "right" })'')
          ];
        }
        {
          _args = [
            (lua ''mod .. " + CONTROL + right"'')
            (lua ''hl.dsp.focus({ workspace = "e+1" })'')
          ];
        }
      ]) "Hyprland keybinding intent must preserve case-sensitive key names in Lua.";
    assert assertMsg (!invalidAction.success) "Hyprland keybinding intent must reject invalid actions.";
    assert assertMsg (take (builtins.length luaBindings) finalBindings == luaBindings) "Hyprland keybinding intent must render the Hyprland Lua bindings before later binding adapters.";
    assert assertMsg (config.home.file.".config/hypr/keybindings.md".text == documentation) "Hyprland keybinding intent must render the keybinding documentation.";
      pkgs.runCommand "hyprland-keybinding-intent" {} "mkdir -p $out";
in {
  options.private.hyprlandKeybindingIntent = {
    luaBindings = mkOption {
      type = types.listOf types.attrs;
      default = [];
      internal = true;
      description = "Hyprland Lua bindings rendered from keybinding intent.";
    };
    documentation = mkOption {
      type = types.str;
      default = "";
      internal = true;
      description = "Hyprland keybinding Markdown rendered from keybinding intent.";
    };
    check = mkOption {
      type = types.package;
      internal = true;
      description = "Focused keybinding-intent verification result.";
    };
  };

  config = {
    private.hyprlandKeybindingIntent = {
      inherit luaBindings documentation;
      check = keybindingCheck;
    };

    # Home Manager renders this Nix list as hl.bind calls for Hyprland 0.56.
    wayland.windowManager.hyprland.settings.bind = luaBindings;
    home.file.".config/hypr/keybindings.md".text = documentation;
  };
}
