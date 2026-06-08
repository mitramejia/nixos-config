{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      web-devicons.enable = true;
      lualine = {
        enable = true;
        settings = {
          options = {theme = "auto";};
        };
      };
      bufferline.enable = true;
      indent-blankline.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;

      neo-tree = {
        enable = true;
        settings = {
          window.mappings = {
            "<space>" = "none";
          };
          filesystem.window.mappings = {
            "o" = "open";
          };
          filesystem.follow_current_file = {
            enabled = true;
            leave_dirs_open = false;
          };
          filesystem.filtered_items = {
            visible = true;
            hide_dotfiles = false;
            hide_gitignored = false;
          };
        };
      };
      telescope.enable = true;

      treesitter.enable = true;
      treesitter-context.enable = false;

      project-nvim.enable = true;

      notify.enable = true;
      noice.enable = true;

      alpha = {
        enable = true;
        theme = "dashboard";
      };

      gitsigns.enable = true;
      diffview.enable = true;

      hop.enable = true;
      leap.enable = true;
      vim-surround.enable = true;
      comment.enable = true;
      which-key = {
        enable = true;
        settings = {
          delay = 300;
        };
      };
      tmux-navigator.enable = true;

      nvim-autopairs = {
        enable = true;
        settings = {
          check_ts = true;
          enable_check_bracket_line = false;
          fast_wrap = {
            enable = true;
            map = "<M-e>";
            chars = ["{" "[" "(" "\"" "'" "`"];
          };
        };
      };

      toggleterm = {
        enable = true;
        settings = {direction = "float";};
      };

      trouble.enable = true;
      markdown-preview.enable = true;
      schemastore = {
        enable = true;
        yaml.enable = false;
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            preset = "default";
            "<C-n>" = ["show" "select_next" "fallback"];
            "<C-p>" = ["show" "select_prev" "fallback"];
            "<CR>" = ["accept" "fallback"];
            "<Tab>" = ["select_next" "fallback"];
            "<S-Tab>" = ["select_prev" "fallback"];
          };
          appearance = {
            nerd_font_variant = "mono";
          };
          completion = {
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 500;
            };
          };
          sources = {
            default = ["lsp" "path" "snippets" "buffer"];
          };
          snippets = {
            preset = "luasnip";
          };
          fuzzy = {
            implementation = "prefer_rust_with_warning";
          };
          signature = {
            enabled = true;
          };
        };
      };

      luasnip.enable = true;
      friendly-snippets.enable = true;
      lsp-signature.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      cmp-npm
      snacks-nvim
    ];
  };
}
