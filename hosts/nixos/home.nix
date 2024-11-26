{
  pkgs,
  username,
  host,
  ...
}: let
  inherit (import ./variables.nix) gitUsername gitEmail;
in {
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  # Import Program Configurations
  imports = [
    ../../config/neovim.nix
    ../../config/firefox.nix
  ];
  # Add IdeaVim configuration for JetBrains IDE's
  home.file.".ideavimrc".source = ../../config/ideavim/.ideavimrc;

  programs.fzf = {
    enable = true;
    defaultOptions = ["--color 16"];
    enableZshIntegration = true;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    difftastic = {enable = true;};
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "vim";
    };
  };

  programs.jq.enable = true;

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 1000000;
    terminal = "tmux-256color";
    keyMode = "vi";
    newSession = true;
    mouse = true;
    baseIndex = 1;
    disableConfirmationPrompt = true;
    prefix = "C-Space";
    extraConfig = ''
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1

      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_date_time "%H:%M"
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
    ];
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs.home-manager.enable = true;

  programs = {
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };

    kitty = {
      enable = true;
      package = pkgs.kitty;
      shellIntegration.enableZshIntegration = true;
      settings = {
        scrollback_lines = 2000;
        wheel_scroll_min_lines = 1;
        window_padding_width = 4;
        confirm_os_window_close = 0;
      };
      extraConfig = ''
        tab_bar_style fade
        tab_fade 1
        font_size 12.0
        active_tab_font_style   bold
        inactive_tab_font_style bold
      '';
    };

    starship = {
      enable = true;
      package = pkgs.starship;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = ["node" "git" "aws" "z" "tmux" "vi-mode" "aliases"];
        theme = ""; # disable theme to allow nix/home-manager starship to control prompt
        extraConfig = ''
          ZSH_TMUX_AUTOSTART=true
          export ANDROID_HOME=~/Android/Sdk
          export JIRA_API_TOKEN=ATATT3xFfGF0vN45Q2UVkqgug3ZcOYuUUQGYjfxT9y1sPQRWCCNGyY6byBeEyTM2R5WH0oNcFKU46Wqs03dm-EkMsMb71KiNdNdrOwjaDl_rVu5LExyMC3-cz0PbwrHkTYu9zMy0bxqeGVn3__mvD7IRgPKpoh_yYoSjXuhPsybzbnUKvdj09ho=5BF2709E
        '';
      };
      profileExtra = ''
        #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        #  exec Hyprland
        #fi
      '';
      initExtra = ''
        if command -v scmpuff 2>&1 >/dev/null
        then
          eval "$(scmpuff init -s)"
        fi
      '';
      shellAliases = {
        sv = "sudo nvim";
        fr = "nh os switch --hostname ${host} /home/${username}/zaneyos";
        fu = "nh os switch --hostname ${host} --update /home/${username}/zaneyos";
        zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        v = "nvim";
        cat = "bat";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
        ".." = "cd ..";
        gp = "git push origin";
        gash = "git stash";
        gasha = "git stash apply";
        gplo = "git pull origin";
        open-pr = "gh pr create";
        p = "pnpm";
      };
    };
  };
}
