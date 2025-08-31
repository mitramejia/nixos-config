{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableZshIntegration = true;
    settings = {
      font_size = 11.5;
      scrollback_lines = 2000;
      wheel_scroll_min_lines = 1;
      window_padding_width = 6;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      tab_fade = 1;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";
      tab_bar_edge = "top";
      tab_bar_margin_width = 0;
      tab_bar_style = "powerline";
      enabled_layouts = "splits";
    };
    themeFile = "Catppuccin-Mocha";
    extraConfig = ''
      # Clipboard
      map ctrl+shift+v        paste_from_selection
      map shift+insert        paste_from_selection
      # Miscellaneous
      map ctrl+shift+up      increase_font_size
      map ctrl+shift+down    decrease_font_size
      map ctrl+shift+backspace restore_font_size
    '';
  };
}
