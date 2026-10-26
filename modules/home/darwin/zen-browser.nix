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
      # duti uses two arguments for schemes, three for UTI + role.
      # Do not claim PDF, plain text, JSON, mailto, or reset the LS database.
      if ! ${pkgs.duti}/bin/duti -s ${bundleId} http ||
         ! ${pkgs.duti}/bin/duti -s ${bundleId} https ||
         ! ${pkgs.duti}/bin/duti -s ${bundleId} public.html all ||
         ! ${pkgs.duti}/bin/duti -s ${bundleId} public.xhtml all; then
        echo "Zen: macOS did not accept a default handler. Confirm Zen in System Settings > Desktop & Dock > Default web browser, then verify HTML/XHTML via Finder Get Info > Open with." >&2
        exit 1
      fi
    fi
  '';
}
