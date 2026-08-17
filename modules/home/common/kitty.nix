{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
      size =
        if pkgs.stdenv.isDarwin
        then 14
        else 11.5;
    };
    shellIntegration.enableZshIntegration = true;
    settings = {
      scrollback_lines = 10000;
      scrollback_pager_history_size = 32;
      modify_font = "cell_width 102%";
      window_padding_width = 14;
      confirm_os_window_close = "-1 count-background";
      notify_on_cmd_finish = "invisible 15.0";
      enable_audio_bell = false;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      enabled_layouts = "splits";
    };
    themeFile = "Catppuccin-Mocha";
    keybindings = {
      "ctrl+insert" = "copy_to_clipboard";
      "shift+insert" = "paste_from_clipboard";
    };
  };
}
