{pkgs, ...}: {
  programs = {
    ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      enableZshIntegration = true;
      settings = {
        theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";
        font-family = "JetBrainsMono NFM Regular";
        font-size = 14.5;
        window-padding-x = 2;
        window-padding-y = 2;
        adjust-cell-height = 10;
        cursor-style = "block";
        cursor-style-blink = true;
        scrollback-limit = 200000;
        copy-on-select = false;
        link-url = true;
        clipboard-read = "allow";
        clipboard-write = "allow";
        mouse-hide-while-typing = true;
        shell-integration = "detect";
        image-storage-limit = 4294967295;
      };
    };
  };
}
