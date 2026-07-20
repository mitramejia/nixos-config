{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-size = 11.5;
      confirm-close-surface = false;
      font-family = "JetBrainsMono Nerd Font Mono";
      scrollback-limit = 200000;
      mouse-hide-while-typing = true;
      window-padding-x = 8;
      window-padding-y = 8;
      shell-integration = "detect";
      theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";
      keybind = [
        "ctrl+shift+c=copy_to_clipboard:mixed"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+insert=copy_to_clipboard:mixed"
        "shift+insert=paste_from_clipboard"
        "ctrl++=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"
        "ctrl+shift+up=increase_font_size:1"
        "ctrl+shift+down=decrease_font_size:1"
        "ctrl+shift+backspace=reset_font_size"
      ];
    };
  };
}
