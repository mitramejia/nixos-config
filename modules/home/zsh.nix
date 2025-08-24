{
  username,
  host,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["node" "git" "aws" "z" "vi-mode" "aliases" "yarn" "nvm" "jenv" "tmux"];
      theme = "";
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
