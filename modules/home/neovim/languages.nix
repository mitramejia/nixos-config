{
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
          eslint.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          clangd.enable = true;
          zls.enable = true;
          marksman.enable = true;
        };
        keymaps = {
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = ["alejandra"];
            lua = ["stylua"];
            javascript = ["prettierd"];
            typescript = ["prettierd"];
            javascriptreact = ["prettierd"];
            typescriptreact = ["prettierd"];
            css = ["prettierd"];
            html = ["prettierd"];
            markdown = ["prettier"];
            "markdown.mdx" = ["prettier"];
            sh = ["shfmt"];
          };
          format_on_save = {
            lsp_fallback = true;
          };
        };
      };
    };

    extraPackages =
      (with pkgs; [
        ripgrep
        fd
        bat
        lazygit
        nil
        typescript-language-server
        typescript
        vscode-langservers-extracted
        pyright
        lua-language-server
        zls
        marksman
        multimarkdown
        clang-tools
        prettierd
        prettier
        stylua
        shfmt
        alejandra
        figlet
        toilet
      ])
      ++ lib.optionals pkgs.stdenv.isLinux [
        pkgs."wl-clipboard"
        pkgs.hyprls
      ];
  };
}
