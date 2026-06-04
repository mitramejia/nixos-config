{
  programs.nixvim.keymaps = [
    {
      key = "jk";
      mode = ["i"];
      action = "<ESC>";
      options.desc = "Exit insert mode";
    }

    {
      key = "<leader>f";
      mode = ["n"];
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find file";
    }
    {
      key = "<leader>ff";
      mode = ["n"];
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find files";
    }
    {
      key = "<leader>fp";
      mode = ["n"];
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "Find in project";
    }
    {
      key = "<leader>fr";
      mode = ["n"];
      action = "<cmd>Telescope oldfiles<cr>";
      options.desc = "Recent files";
    }
    {
      key = "<leader>fn";
      mode = ["n"];
      action = "<cmd>enew<cr>";
      options.desc = "New file";
    }
    {
      key = "<leader>e";
      mode = ["n"];
      action = "<cmd>Neotree toggle<cr>";
      options.desc = "File browser toggle";
    }

    {
      key = "<A-n>";
      mode = ["n"];
      action = "<cmd>tabnext<cr>";
      options.desc = "Next tab";
    }
    {
      key = "<A-p>";
      mode = ["n"];
      action = "<cmd>tabprevious<cr>";
      options.desc = "Previous tab";
    }

    {
      key = "<A-h>";
      mode = ["n"];
      action = "<C-w>h";
      options.desc = "Pane left";
    }
    {
      key = "<A-j>";
      mode = ["n"];
      action = "<C-w>j";
      options.desc = "Pane down";
    }
    {
      key = "<A-k>";
      mode = ["n"];
      action = "<C-w>k";
      options.desc = "Pane up";
    }
    {
      key = "<A-l>";
      mode = ["n"];
      action = "<C-w>l";
      options.desc = "Pane right";
    }
    {
      key = "<C-h>";
      mode = ["t"];
      action = "<C-\\><C-n><Cmd>TmuxNavigateLeft<CR>";
      options.desc = "Tmux navigate left (terminal)";
    }
    {
      key = "<C-j>";
      mode = ["t"];
      action = "<C-\\><C-n><Cmd>TmuxNavigateDown<CR>";
      options.desc = "Tmux navigate down (terminal)";
    }
    {
      key = "<C-k>";
      mode = ["t"];
      action = "<C-\\><C-n><Cmd>TmuxNavigateUp<CR>";
      options.desc = "Tmux navigate up (terminal)";
    }
    {
      key = "<C-l>";
      mode = ["t"];
      action = "<C-\\><C-n><Cmd>TmuxNavigateRight<CR>";
      options.desc = "Tmux navigate right (terminal)";
    }

    {
      key = "<leader>wv";
      mode = ["n"];
      action = "<cmd>vsplit<cr>";
      options.desc = "Split vertical";
    }
    {
      key = "<leader>ws";
      mode = ["n"];
      action = "<cmd>split<cr>";
      options.desc = "Split horizontal";
    }
    {
      key = "<leader>wu";
      mode = ["n"];
      action = "<cmd>only<cr>";
      options.desc = "Unsplit";
    }
    {
      key = "<leader>wm";
      mode = ["n"];
      action = "<cmd>wincmd L<cr>";
      options.desc = "Move window";
    }

    {
      key = "<leader>.";
      mode = ["n"];
      action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
      options.desc = "Comment line";
    }
    {
      key = "<leader>.";
      mode = ["v"];
      action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
      options.desc = "Comment selection";
    }

    {
      key = "cl";
      mode = ["n"];
      action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
      options.desc = "Comment line";
    }
    {
      key = "cl";
      mode = ["v"];
      action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
      options.desc = "Comment selection";
    }

    {
      key = "<leader>dj";
      mode = ["n"];
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      options.desc = "Go to next diagnostic";
    }
    {
      key = "<leader>dk";
      mode = ["n"];
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      options.desc = "Go to previous diagnostic";
    }
    {
      key = "<leader>dl";
      mode = ["n"];
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options.desc = "Show diagnostic details";
    }
    {
      key = "<leader>dt";
      mode = ["n"];
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Toggle diagnostics list";
    }

    {
      key = "<leader>am";
      mode = ["n"];
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options.desc = "Code actions";
    }
    {
      key = "<leader>as";
      mode = ["n"];
      action = "<cmd>Telescope builtin<CR>";
      options.desc = "Search everywhere";
    }
    {
      key = "<leader>ar";
      mode = ["n"];
      action = "<cmd>Telescope commands<CR>";
      options.desc = "Run command";
    }
    {
      key = "<leader>gf";
      mode = ["n"];
      action = "<cmd>Telescope git_files<CR>";
      options.desc = "Git files";
    }
    {
      key = "<leader>gb";
      mode = ["n"];
      action = "<cmd>Telescope git_branches<CR>";
      options.desc = "Git branches";
    }
    {
      key = "<leader>gs";
      mode = ["n"];
      action = "<cmd>Telescope git_status<CR>";
      options.desc = "Git status";
    }
    {
      key = "<leader>gl";
      mode = ["n"];
      action = "<cmd>Telescope git_commits<CR>";
      options.desc = "Git log";
    }
    {
      key = "<leader>gH";
      mode = ["n"];
      action = "<cmd>DiffviewFileHistory %<CR>";
      options.desc = "File history";
    }
    {
      key = "<leader>gA";
      mode = ["n"];
      action = "<cmd>DiffviewFileHistory<CR>";
      options.desc = "Project history";
    }
    {
      key = "<leader>gd";
      mode = ["n"];
      action = "<cmd>DiffviewOpen<CR>";
      options.desc = "Open diffview";
    }
    {
      key = "<leader>gq";
      mode = ["n"];
      action = "<cmd>DiffviewClose<CR>";
      options.desc = "Close diffview";
    }
    {
      key = "<leader>ghn";
      mode = ["n"];
      action = "<cmd>Gitsigns next_hunk<CR>";
      options.desc = "Next hunk";
    }
    {
      key = "<leader>ghp";
      mode = ["n"];
      action = "<cmd>Gitsigns prev_hunk<CR>";
      options.desc = "Previous hunk";
    }
    {
      key = "<leader>ghs";
      mode = ["n" "v"];
      action = "<cmd>Gitsigns stage_hunk<CR>";
      options.desc = "Stage hunk";
    }
    {
      key = "<leader>ghr";
      mode = ["n" "v"];
      action = "<cmd>Gitsigns reset_hunk<CR>";
      options.desc = "Reset hunk";
    }
    {
      key = "<leader>ghu";
      mode = ["n"];
      action = "<cmd>Gitsigns undo_stage_hunk<CR>";
      options.desc = "Undo stage hunk";
    }
    {
      key = "<leader>ghv";
      mode = ["n"];
      action = "<cmd>Gitsigns preview_hunk<CR>";
      options.desc = "Preview hunk";
    }
    {
      key = "<leader>gtb";
      mode = ["n"];
      action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
      options.desc = "Toggle line blame";
    }
    {
      key = "<leader>gtw";
      mode = ["n"];
      action = "<cmd>Gitsigns toggle_word_diff<CR>";
      options.desc = "Toggle word diff";
    }

    {
      key = "<leader>q";
      mode = ["n"];
      action = "<cmd>q<CR>";
      options.desc = "Close current window";
    }

    {
      key = "H";
      mode = ["n" "v"];
      action = "^";
      options.desc = "Line start";
    }
    {
      key = "L";
      mode = ["n" "v"];
      action = "$";
      options.desc = "Line end";
    }

    {
      key = "<F1>";
      mode = ["n" "i" "v" "x" "s" "o" "t" "c"];
      action = "<Nop>";
      options.desc = "Disable accidental F1 help";
    }
    {
      key = "<leader>h";
      mode = ["n"];
      action = ":help<Space>";
      options = {
        desc = "Open :help prompt";
        nowait = true;
      };
    }
    {
      key = "<leader>H";
      mode = ["n"];
      action = ":help <C-r><C-w><CR>";
      options.desc = "Help for word under cursor";
    }
  ];
}
