{
  pkgs,
  username,
  host,
  ags,
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
    ../../config/emoji.nix
    ../../config/hyprland.nix
    ../../config/neovim.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-emoji.nix
    ../../config/rofi/config-long.nix
    ../../config/firefox.nix
    ../../config/chromium.nix
    ags.homeManagerModules.default
  ];

  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  # Add IdeaVim configuration for JetBrains IDE's
  home.file.".ideavimrc".source = ../../config/ideavim/.ideavimrc;

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

  # Styling Options
  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    firefox.profileNames = ["default"];
  };

  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  # Scripts
  home.packages = [
    (import ../../scripts/emopicker9000.nix {inherit pkgs;})
    (import ../../scripts/web-search.nix {inherit pkgs;})
    (import ../../scripts/rofi-launcher.nix {inherit pkgs;})
    (import ../../scripts/screenshootin.nix {inherit pkgs;})
    ags.packages.${pkgs.system}.default
  ];

  services = {
    hypridle = {
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
    ];
  };

  programs = {
    home-manager.enable = true;

    # Install & Configure Git
    git = {
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
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "vim";
      };
    };

    jq.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = "/home/${username}/nix-config";
    };

    fzf = {
      enable = true;
      defaultOptions = ["--color 16"];
      enableZshIntegration = true;
    };
    btop = {
      enable = true;
      package = pkgs.btop.override {
        rocmSupport = true;
        cudaSupport = true;
      };
      settings = {
        vim_keys = true;
        rounded_corners = true;
        proc_tree = true;
        show_gpu_info = "on";
        show_uptime = true;
        show_coretemp = true;
        cpu_sensor = "auto";
        show_disks = true;
        only_physical = true;
        io_mode = true;
        io_graph_combined = false;
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
      themeFile = "Catppuccin-Mocha";
      extraConfig = ''
        tab_bar_style fade
        tab_fade 1
        font_size 11.5
        active_tab_font_style   bold
        inactive_tab_font_style bold
      '';
    };

    starship = {
      enable = true;
      package = pkgs.starship;
    };

    direnv.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = ["node" "git" "aws" "z" "vi-mode" "aliases" "tmux" "yarn" "nvm" "jenv"];
        theme = ""; # disable theme to allow nix/home-manager starship to control prompt
        extraConfig = ''
          ZSH_TMUX_AUTOSTART=true
          export ANDROID_HOME=~/Android/Sdk
          export PATH="$PATH:/home/mitra/.cache/lm-studio/bin"
        '';
      };
      initExtra = ''
        if command -v scmpuff 2>&1 >/dev/null
        then
          eval "$(scmpuff init -s)"
        fi
      '';
      shellAliases = import ./shell-aliases.nix {
        username = username;
        host = host;
      };
    };

    tmux = {
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
  };
}
