{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./neovim/plugins.nix
    ./neovim/languages.nix
    ./neovim/keymaps.nix
    ./neovim/lua.nix
    ./neovim/mobile.nix
  ];

  programs.nixvim = {
    enable = true;
    # Keep nixvim on the same nixpkgs as the rest of the system while making
    # the choice explicit, so nixvim does not warn about its followed input.
    nixpkgs.source = inputs.nixpkgs;
    wrapRc = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 200;
      cursorline = true;
      spell = true;
      spelllang = ["en"];
      clipboard = "unnamedplus";
      timeoutlen = 500;
      scrolloff = 10;
      smartcase = true;
      incsearch = true;
      hlsearch = true;
      autoread = true;
      showmode = true;
      showcmd = true;
      guifont = lib.mkForce "JetBrainsMono Nerd Font Mono:h14";
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
      };
    };
  };
}
