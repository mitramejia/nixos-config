{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 1000000;
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    focusEvents = true;
    disableConfirmationPrompt = true;
    prefix = "C-Space";
    extraConfig = ''
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

         # reload tmux configuration
         bind r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config reloaded"

      # renumber when window is closed
      set -g renumber-window on
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
      # set left and right status bar
      set -g allow-rename off
      set -g status-position top
      set -g status-interval 5
      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left '#{E:@catppuccin_status_session} '
      set -gF status-right '#{E:@catppuccin_status_primary_ip}'
      set -agF status-right '#{E:@catppuccin_status_ctp_cpu}'
      set -agF status-right '#{E:@catppuccin_status_ctp_memory}'
      set -ag status-right '#{E:@catppuccin_status_date_time}'


      set -g @continuum-restore 'on'
      set -g @continuum-boot 'on'
      set -g @continuum-save-interval '10'
    '';

    plugins = with pkgs; [
      tmuxPlugins.catppuccin
      tmuxPlugins.continuum
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
      tmuxPlugins.open
      tmuxPlugins.copycat
    ];
  };

  home.sessionVariables.HM_TMUX_PROBE = "yes";
}
