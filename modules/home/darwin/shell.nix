{
  lib,
  host,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    autocd = true;
    cdpath = ["~/.local/share/src"];
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "z" "vi-mode" "aliases" "yarn" "macos"];
      theme = "";
      extraConfig = ''
        DISABLE_AUTO_TITLE=true
      '';
    };
    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.composer/vendor/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH
      export PNPM_HOME=~/.pnpm-packages
      export PATH="$HOME/.local/bin:$HOME/.pyenv/versions/3.12.7/bin/:$PATH"
      export HISTIGNORE="pwd:ls:cd"

      tmux_sock="/private/tmp/tmux-$(id -u)/default"
      if [[ -S "$tmux_sock" ]] && ! pgrep -x tmux >/dev/null 2>&1; then
        rm -f "$tmux_sock"
      fi

      export ALTERNATE_EDITOR=""
      export EDITOR="vim"

      if command -v scmpuff >/dev/null 2>&1; then
        eval "$(scmpuff init -s)"
      fi
    '';
    shellAliases = {
      fr = "nh darwin switch --hostname ${host.key} ${host.nixConfig}";
      fu = "nh darwin switch --hostname ${host.key} --update ${host.nixConfig}";
      v = "nvim";
      cat = "bat";
      ls = lib.mkForce "eza --icons";
      ll = lib.mkForce "eza -lh --icons --grid --group-directories-first";
      la = lib.mkForce "eza -lah --icons --grid --group-directories-first";
      ".." = "cd ..";
      gp = "git push origin";
      gpf = "git push --force-with-lease origin";
      gash = "git stash";
      gasha = "git stash apply";
      gplo = "git pull origin";
      open-pr = "gh pr create";
      p = "pnpm";
      pa = "pnpm add";
      y = "yarn";
      vim = "nvim";
      codex-oss = "codex -p gpt-oss-20b-lmstudio --oss";
      codex = "headroom wrap codex";
    };
  };
}
