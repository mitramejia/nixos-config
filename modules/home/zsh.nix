{
  username,
  host,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["node" "git" "aws" "z" "vi-mode" "aliases" "tmux" "yarn" "nvm" "jenv"];
      theme = ""; # disable theme to allow nix/home-manager starship to control prompt
      extraConfig = ''
        export ANDROID_HOME=~/Android/Sdk
        export PATH="$PATH:/home/mitra/.cache/lm-studio/bin"
      '';
    };
    initContent = ''
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
}
