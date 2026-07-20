{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    # 26.05 HM changed the shell-wrapper name default "yy" -> "y"; keep "yy".
    shellWrapperName = "yy";
    extraPackages = [
      pkgs.dragon-drop
    ];
    settings = {
      yazi = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        image_quality = 90;
        tab_size = 1;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        ueberzug_scale = 1;
        ueberzug_offset = [
          0
          0
          0
          0
        ];
      };

      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<C-n>";
          run = "shell -- ${pkgs.dragon-drop}/bin/dragon-drop -x -i -T %h";
          desc = "Drag hovered file";
        }
      ];
    };
  };
}
