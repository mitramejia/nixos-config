{ config, ... }: {
  gtk = {
    # 26.05 HM changed gtk.gtk4.theme default config.gtk.theme -> null. We keep the legacy
    # default (home.stateVersion < 26.05 = adw-gtk3 from stylix); pin it explicitly to match
    # current behavior and silence the warning. Stylix sets gtk.theme but not gtk4.theme, so
    # no conflicting definition.
    gtk4.theme = config.gtk.theme;
    #    iconTheme = {
    #      name = "Papirus-Dark";
    #      package = pkgs.papirus-icon-theme;
    #    };
    #    gtk3.extraConfig = {
    #      gtk-application-prefer-dark-theme = 1;
    #    };
    #    gtk4.extraConfig = {
    #      gtk-application-prefer-dark-theme = 1;
    #    };
  };
}
