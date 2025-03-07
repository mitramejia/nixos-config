{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;

    /*
    Define Firefox profiles and settings.
    Documentation: https://nixos.org/manual/nixos/stable/index.html#sec-browser-profiles
    */
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;

        settings = {
          /*
          Disable Firefox password manager.
          Documentation: https://support.mozilla.org/en-US/kb/password-manager-remember-delete-change-and-import
          */
          "signon.rememberSignons" = false;

          /*
          Use XDG Desktop Portal for file picking.
          Documentation: https://wiki.archlinux.org/title/XDG_Portal
          */
          "widget.use-xdg-desktop-portal.file-picker" = 1;

          /*
          Do not show warning when accessing about:config.
          Documentation: https://support.mozilla.org/en-US/kb/about-config-editor-firefox
          */
          "browser.aboutConfig.showWarning" = false;

          /*
          Do not show compact mode.
          Documentation: https://support.mozilla.org/en-US/questions/1339926
          */
          "browser.compactmode.show" = false;

          /*
          Disable disk cache to be kind to hard drive.
          Documentation: https://support.mozilla.org/en-US/questions/1069522
          */
          "browser.cache.disk.enable" = false;

          /*
          Set custom mouse wheel scroll speed.
          Documentation: https://support.mozilla.org/en-US/kb/how-scroll-web-pages-faster-slow-using-keyboard
          */
          "mousewheel.default.delta_multiplier_x" = 20;
          "mousewheel.default.delta_multiplier_y" = 20;
          "mousewheel.default.delta_multiplier_z" = 20;

          /*
          Disable workspace management.
          Documentation: https://bugzilla.mozilla.org/show_bug.cgi?id=1694178
          */
          "widget.disable-workspace-management" = true;

          default = {
            id = 0;
            name = "default";
            isDefault = true;

            search = {
              engines = {
                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@np"];
                };
                "NixOS Wiki" = {
                  urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                  iconUpdateURL = "https://nixos.wiki/favicon.png";
                  /*
                  Update interval set to every day.
                  Documentation: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/search/SearchEngine
                  */
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = ["@nw"];
                };
              };
            };
          };
        };
      };
    };
  };
}
