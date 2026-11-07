{
  lib,
  pkgs,
  inputs,
  unstablePkgs,
  ...
}: let
  herdrPackage = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
  linkHerdrPlugin = pkgs.writeShellApplication {
    name = "link-herdr-plugin";
    runtimeInputs = [pkgs.coreutils pkgs.jq];
    text = builtins.readFile ./scripts/link-herdr-plugin;
  };
  hdl = pkgs.writeShellApplication {
    name = "hdl";
    runtimeInputs = [
      herdrPackage
      pkgs.coreutils
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/hdl;
  };
  vimHerdrNavigation = pkgs.fetchFromGitHub {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "820d48f5d9c9a7dece6a4bebfa3982ec30bbfbb7";
    hash = "sha256-qn69GDH3kCSYm9x/it3EyJqZiwQoK3pnwdfATeSwJ38=";
  };
  autoTitle = pkgs.buildGoModule {
    pname = "herdr-auto-title";
    version = "0.18.0";
    src = pkgs.fetchFromGitHub {
      owner = "kryptamine";
      repo = "herdr-auto-title";
      rev = "v0.18.0";
      hash = "sha256-HhzsksVi8e5hT45ZI8SfoqeYXZ8PSchV/XE4MTVDUfk=";
    };
    vendorHash = "sha256-QxFp1b7pf7bn3Hh0hyaj8ke5Z61N+WwjhHt3pFiapTs=";
    subPackages = ["cmd/herdr-auto-title"];
    # `plugin link` only registers the manifest (unlike `plugin install`,
    # it neither builds nor starts it). Keep its relative commands usable.
    postInstall = ''
      mkdir -p "$out/share/herdr-auto-title"
      cp herdr-plugin.toml "$out/share/herdr-auto-title/"
      ln -s "$out/bin/herdr-auto-title" "$out/share/herdr-auto-title/herdr-auto-title"
    '';
  };
in {
  # Backport upstream module until Home Manager 26.05 contains it.
  imports = [./herdr-module.nix];

  programs.herdr = {
    enable = true;

    # Build the latest stable upstream release from its own flake.
    package = herdrPackage;

    settings = {
      onboarding = false;

      terminal = {
        default_shell = "${pkgs.zsh}/bin/zsh";
        shell_mode = "auto";
        new_cwd = "follow";
      };

      theme.name = "catppuccin";

      ui = {
        mouse_capture = true;
        copy_on_select = true;
        confirm_close = false;
        prompt_new_tab_name = false;
        pane_borders = true;
        pane_scrollbars = false;
        pane_gaps = false;
        hide_tab_bar_when_single_tab = false;
        tab_bar_position = "bottom";
      };

      keys = {
        prefix = "ctrl+space";
        workspace_picker = "prefix+s";
        settings = "prefix+,";
        detach = "prefix+d";
        new_tab = "prefix+c";
        split_horizontal = "prefix+minus";
        split_vertical = "prefix+|";
        focus_pane_left = "prefix+h";
        focus_pane_down = "prefix+j";
        focus_pane_up = "prefix+k";
        focus_pane_right = "prefix+l";
        copy_mode = "prefix+[";
        reload_config = "prefix+shift+r";
        resize_mode = "prefix+r";
        command = [
          {
            key = "ctrl+h";
            type = "plugin_action";
            command = "vim-herdr-navigation.left";
            description = "Navigate left across Vim and Herdr panes";
          }
          {
            key = "ctrl+j";
            type = "plugin_action";
            command = "vim-herdr-navigation.down";
            description = "Navigate down across Vim and Herdr panes";
          }
          {
            key = "ctrl+k";
            type = "plugin_action";
            command = "vim-herdr-navigation.up";
            description = "Navigate up across Vim and Herdr panes";
          }
          {
            key = "ctrl+l";
            type = "plugin_action";
            command = "vim-herdr-navigation.right";
            description = "Navigate right across Vim and Herdr panes";
          }
          {
            key = "prefix+shift+v";
            type = "plugin_action";
            command = "persiyanov.reviewr.toggle";
            description = "Toggle the Reviewr pane";
          }
        ];
      };

      # Herdr limits scrollback by bytes. 100 MB approximates tmux's
      # one-million-line history without reserving memory up front.
      advanced.scrollback_limit_bytes = 100 * 1000 * 1000;

      session.resume_agents_on_restore = true;
    };
  };

  home.packages = [
    # The desktop app is not available in the stable package set yet.
    unstablePkgs.herdr-desktop
    hdl
    pkgs.jq
    autoTitle
    # Herdr's Claude/Codex hook scripts invoke python3 at agent runtime.
    pkgs.python3
  ];
  home.sessionVariables.HERDR_NAV_PASSTHROUGH_RE = "^(lazygit)$";

  home.activation.linkVimHerdrNavigation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${lib.getExe linkHerdrPlugin} ${lib.getExe herdrPackage} ${vimHerdrNavigation}
  '';

  home.activation.linkHerdrAutoTitle = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Do not invoke restart here: first startup renames even existing panes.
    run ${lib.getExe linkHerdrPlugin} ${lib.getExe herdrPackage} ${autoTitle}/share/herdr-auto-title
  '';

  # Use upstream's idempotent mergers rather than owning these mutable files:
  # they retain other Claude hooks and external Codex configuration.
  home.activation.installHerdrAgentIntegrations = lib.hm.dag.entryAfter ["writeBoundary" "ensureMutableCodexConfig"] ''
    run mkdir -p "$HOME/.claude"
    run ${pkgs.coreutils}/bin/env PATH=${lib.makeBinPath [herdrPackage pkgs.coreutils pkgs.python3]}:$PATH \
      ${lib.getExe herdrPackage} integration install claude
    run ${pkgs.coreutils}/bin/env PATH=${lib.makeBinPath [herdrPackage pkgs.coreutils pkgs.python3]}:$PATH \
      ${lib.getExe herdrPackage} integration install codex
  '';

  programs.nixvim.extraConfigLuaPost = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        dofile("${vimHerdrNavigation}/editor/nvim.lua")
      end,
    })
  '';
}
