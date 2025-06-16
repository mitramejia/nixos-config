{pkgs, ...}: {
  programs. tmux = {
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
}
