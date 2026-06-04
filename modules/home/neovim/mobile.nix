{
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    plugins = {
      lsp.servers = {
        kotlin_language_server.enable = true;
        # SourceKit is useful for Swift editing on Linux, but iOS SDK/Xcode
        # symbol resolution still needs a macOS/Xcode build environment.
        sourcekit.enable = true;
        just.enable = true;
      };

      conform-nvim.settings.formatters_by_ft = {
        kotlin = ["ktlint"];
        swift = ["swift_format"];
        just = ["just"];
      };

      lint = {
        enable = true;
        lintersByFt = {
          kotlin = ["ktlint"];
          swift = ["swiftlint"];
        };
      };

      package-info = {
        enable = true;
        enableTelescope = true;
        settings = {
          package_manager = "yarn";
          hide_up_to_date = true;
          hide_unstable_versions = true;
        };
      };

      just = {
        enable = true;
        settings = {
          open_qf_on_error = true;
          open_qf_on_run = true;
          open_qf_on_any = false;
          autoscroll_qf = true;
          register_commands = true;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      kotlin-vim
      swift-vim
    ];

    keymaps = [
      {
        key = "<leader>ml";
        mode = ["n"];
        action = "<cmd>MobileLogcat<CR>";
        options.desc = "Android Logcat";
      }

      {
        key = "<leader>jr";
        mode = ["n"];
        action = "<cmd>JustSelect<CR>";
        options.desc = "Run just recipe";
      }
      {
        key = "<leader>js";
        mode = ["n"];
        action = "<cmd>JustStop<CR>";
        options.desc = "Stop just recipe";
      }

      {
        key = "<leader>ps";
        mode = ["n"];
        action = "<cmd>lua require('package-info').show()<CR>";
        options.desc = "Show package info";
      }
      {
        key = "<leader>ph";
        mode = ["n"];
        action = "<cmd>lua require('package-info').hide()<CR>";
        options.desc = "Hide package info";
      }
      {
        key = "<leader>pu";
        mode = ["n"];
        action = "<cmd>lua require('package-info').update()<CR>";
        options.desc = "Update package";
      }
      {
        key = "<leader>pd";
        mode = ["n"];
        action = "<cmd>lua require('package-info').delete()<CR>";
        options.desc = "Delete package";
      }
      {
        key = "<leader>pi";
        mode = ["n"];
        action = "<cmd>lua require('package-info').install()<CR>";
        options.desc = "Install package";
      }
    ];

    extraConfigLua = lib.mkAfter ''
      local ok_wk_mobile, wk_mobile = pcall(require, "which-key")
      if ok_wk_mobile then
        wk_mobile.add({
          { "<leader>j", group = "Just" },
          { "<leader>m", group = "Mobile" },
          { "<leader>p", group = "Packages" },
        })
      end

      vim.api.nvim_create_user_command("MobileLogcat", function()
        local command = "adb logcat '*:S' ReactNative:V ReactNativeJS:V"
        local ok_toggleterm, terminal = pcall(require, "toggleterm.terminal")
        if ok_toggleterm then
          terminal.Terminal:new({
            cmd = command,
            direction = "float",
            close_on_exit = false,
            hidden = true,
            display_name = "Android Logcat",
          }):toggle()
          return
        end
        vim.cmd("terminal " .. command)
      end, {})
    '';
  };
}
