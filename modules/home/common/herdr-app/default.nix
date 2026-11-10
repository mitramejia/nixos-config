{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}: let
  json = pkgs.formats.json {};
  # GPUI represents prefix sequences as space-separated keystrokes.
  prefix = lib.replaceStrings ["+"] ["-"] config.programs.herdr.settings.keys.prefix;
  defaults = {
    "settings.json" = {
      theme = "nix-catppuccin-mocha";
    };
    "keys.json".global = {
      "${prefix} ," = "app.settings";
      "${prefix} d" = "window.close";
      "${prefix} c" = "tab.new";
      "${prefix} -" = "pane.split:down";
      "${prefix} shift-|" = "pane.split:right";
      "${prefix} h" = "pane.go:left";
      "${prefix} j" = "pane.go:down";
      "${prefix} k" = "pane.go:up";
      "${prefix} l" = "pane.go:right";
      "${prefix} shift-:" = "app.palette";
    };
    "themes/nix-catppuccin-mocha.json" = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection = "#585b70";
      cursor = "#f5e0dc";
      ansi = [
        "#45475a"
        "#f38ba8"
        "#a6e3a1"
        "#f9e2af"
        "#89b4fa"
        "#f5c2e7"
        "#94e2d5"
        "#bac2de"
        "#585b70"
        "#f38ba8"
        "#a6e3a1"
        "#f9e2af"
        "#89b4fa"
        "#f5c2e7"
        "#94e2d5"
        "#a6adc8"
      ];
    };
  };
  defaultsFile = json.generate "herdr-app-defaults.json" defaults;
  keysSeed = "${unstablePkgs.herdr-desktop.src}/defaults/keys${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ".macos"}.json";
  reconcile = pkgs.writeShellApplication {
    name = "reconcile-herdr-app";
    runtimeInputs = [pkgs.python3];
    text = ''
      exec python3 ${./reconcile.py} "$@"
    '';
  };
  check = pkgs.runCommand "herdr-app-mutable-config" {} ''
    export HERDR_APP_DEFAULTS=${defaultsFile}
    export HERDR_APP_KEYS_SEED=${keysSeed}
    ${pkgs.python3}/bin/python3 -B -m unittest discover -s ${./.} -v
    mkdir -p "$out"
  '';
in {
  options.private.herdrAppConfigCheck = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    description = "Regression checks for writable Herdr desktop preferences.";
  };

  config = {
    private.herdrAppConfigCheck = check;
    # Do not use xdg.configFile: the app must be able to save these files.
    home.activation.reconcileHerdrApp = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe reconcile} \
        ${lib.escapeShellArg "${config.xdg.configHome}/herdr-app"} \
        ${lib.escapeShellArg "${config.xdg.stateHome}/herdr-app/home-manager-defaults.json"} \
        ${defaultsFile} \
        ${keysSeed}
    '';
  };
}
