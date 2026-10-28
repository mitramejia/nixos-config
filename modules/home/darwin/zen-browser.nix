{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zen-browser;
  signedPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped;
  # Home Manager's apps link is generation-independent. Never register the
  # versioned /nix/store app directly as the user's default browser.
  app = "${config.home.homeDirectory}/${config.targets.darwin.linkApps.directory}/${cfg.package.applicationName}.app";
  bundleId = "app.zen-browser.zen";
  lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";
  defaultHandlers = pkgs.runCommand "zen-default-handlers" {nativeBuildInputs = [pkgs.python3];} ''
    python3 -B -m unittest discover -s ${./zen-browser} -p 'test_*.py' -v
    mkdir -p "$out"
    cp ${./zen-browser/default_handlers.py} "$out/default_handlers.py"
  '';
in {
  assertions = [
    {
      assertion = config.targets.darwin.linkApps.enable;
      message = "Zen's stable application registration requires targets.darwin.linkApps.enable.";
    }
  ];

  programs.zen-browser = {
    darwin.packageMode = "signed";
    # HM 26.05 always calls the Firefox wrapper's override interface, even
    # on Darwin. Adapt only that call without wrapping/mutating the signed
    # app. Policies are delivered via targets.darwin.defaults by the module.
    # Reject wrapper-only features rather than silently dropping them.
    package =
      signedPackage
      // {
        override = overrides: let
          args =
            if builtins.isFunction overrides
            then overrides {}
            else overrides;
        in
          assert lib.all (name: builtins.elem name ["cfg" "extraPolicies" "pkcs11Modules"]) (builtins.attrNames args);
          assert (args.cfg or {}) == {enableGnomeExtensions = false;};
          assert (args.pkcs11Modules or []) == [];
          assert (args.extraPolicies or {}) == cfg.policies; signedPackage;
      };
  };

  home.packages = [pkgs.duti];

  home.activation.zenDefaultBrowser = lib.hm.dag.entryAfter ["linkGeneration"] ''
    if [ -n "''${DRY_RUN:-}" ]; then
      echo "Would register ${app} and set Zen as the HTTP/HTTPS/HTML/XHTML handler."
    else
      if [ ! -d ${lib.escapeShellArg app} ]; then
        echo "Zen: expected Home Manager application link missing: ${app}" >&2
        exit 1
      fi
      actualId=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' ${lib.escapeShellArg "${app}/Contents/Info.plist"})
      if [ "$actualId" != ${lib.escapeShellArg bundleId} ]; then
        echo "Zen: unexpected application bundle identifier: $actualId" >&2
        exit 1
      fi
      run ${lsregister} -f ${lib.escapeShellArg app}
      # LaunchServices may reject rewriting an already-selected HTTPS handler.
      run ${pkgs.python3}/bin/python3 ${defaultHandlers}/default_handlers.py \
        ${lib.escapeShellArg bundleId} ${pkgs.duti}/bin/duti
    fi
  '';
}
