{pkgs, ...}: {
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
          ruby_lsp = {
            enable = true;
            # Ruby LSP must not inherit Nixvim's immutable GEM_HOME: it creates
            # a composed bundle and installs the Bundler version from Gemfile.lock.
            package = null;
            cmd = [
              "env"
              "-u"
              "GEM_HOME"
              "ruby-lsp"
            ];
          };
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
          formatters.prettier = {
            command = "yarn";
            prepend_args = ["prettier"];
          };

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

    extraPackages = with pkgs; [
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
      (ruby_3_3.withPackages (ps: [ps.ruby-lsp]))
      stdenv.cc
      gnumake
      imagemagick
      prettierd
      stylua
      shfmt
      alejandra
      figlet
      toilet
    ];
  };
}
