{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  catppuccinMoz = ../../../assets/catppuccin-zen-browser/mocha/blue;
  catppuccinLogoPath = "${config.home.homeDirectory}/.local/share/catppuccin-zen-browser/mocha/blue/zen-logo.svg";
  catppuccinUserChrome = builtins.readFile "${catppuccinMoz}/userChrome.css";
  catppuccinUserContent =
    lib.replaceStrings
    ["url(\"zen-logo-mocha.svg\")"]
    ["url(\"file://${catppuccinLogoPath}\")"]
    (builtins.readFile "${catppuccinMoz}/userContent.css");
in {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  home.file = {
    ".local/share/catppuccin-zen-browser/mocha/blue/zen-logo.svg".source = "${catppuccinMoz}/zen-logo.svg";
  };

  programs.zen-browser = {
    enable = true;

    profiles.default = {
      settings = {
        # Required for userChrome/userContent styles to be loaded.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Mocha is intended for dark mode.
        "ui.systemUsesDarkTheme" = 1;
      };

      extensions.packages = with firefox-addons; [
        react-devtools
        reduxdevtools
        ublock-origin
        vimium
      ];

      userChrome = catppuccinUserChrome;
      userContent = catppuccinUserContent;
    };

    policies.ExtensionSettings = {
      "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };
}
