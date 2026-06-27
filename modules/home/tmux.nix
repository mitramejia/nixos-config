{
  config,
  pkgs,
  ...
}: let
  tdl = pkgs.writeShellApplication {
    name = "tdl";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.tmux
    ];
    text = builtins.readFile ./scripts/tdl;
  };
  colors = config.lib.stylix.colors;
in {
  home.packages = [
    tdl
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 1000000;
    newSession = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    focusEvents = true;
    disableConfirmationPrompt = true;
    prefix = "C-Space";
    aggressiveResize = true;
    escapeTime = 0;
    extraConfig = ''

      set-option -g set-clipboard on
      set-option -g allow-passthrough on
      set-window-option -g pane-base-index 1
      set -ga update-environment " KITTY_LISTEN_ON KITTY_WINDOW_ID"

      # truecolor (RGB) support with tmux-256color
      set -ga terminal-overrides ",tmux-256color:RGB"

      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      bind u run-shell -b "${pkgs.kitty}/bin/kitty @ action open_url_with_hints"

      # reload tmux configuration
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config reloaded"

      # renumber when window is closed
      set -g renumber-windows on
      # set left and right status bar
      set -g allow-rename off
      set -g status-position bottom
      set -g status-interval 5
      set -g status-left-length 100
      set -g status-right-length 100

      # make the focused pane easier to spot
      set -g pane-border-style "fg=#${colors.base03}"
      set -g pane-active-border-style "fg=#${colors.base08},bold"
      set -g pane-border-status top
      set -g pane-border-format " #{?pane_active,#[fg=#${colors.base00},bg=#${colors.base08},bold] active #[default],#[fg=#${colors.base04}]#P#[default]} "
      set -g display-panes-colour "#${colors.base04}"
      set -g display-panes-active-colour "#${colors.base08}"
    '';

    plugins = with pkgs; [
      # Catppuccin with its options grouped here
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g @catppuccin_window_number_position 'right'
          set -g @catppuccin_window_status 'no'
          set -g @catppuccin_window_default_text '#W'
          set -g @catppuccin_window_current_fill 'number'
          set -g @catppuccin_window_current_text '#W'
          set -g @catppuccin_window_current_color '#{E:@thm_surface_2}'
          set -g @catppuccin_date_time_text '%d.%m. %H:%M'
          set -g @catppuccin_status_module_text_bg '#{E:@thm_mantle}'
          set -g status-left '#{E:@catppuccin_status_session} '
          set -gF status-right '#{E:@catppuccin_status_primary_ip}'
          set -agF status-right '#{E:@catppuccin_status_ctp_cpu}'
          set -agF status-right '#{E:@catppuccin_status_ctp_memory}'
          set -ag status-right '#{E:@catppuccin_status_date_time}'
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
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
      tmuxPlugins.open
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.copycat
    ];
  };
}
