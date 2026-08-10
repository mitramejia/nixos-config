{
  programs.zsh.shellAliases = {
    cat = "bat";
    man = "batman";
    ".." = "cd ..";
    gp = "git push origin";
    gash = "git stash";
    gasha = "git stash apply";
    gplo = "git pull origin";
    open-pr = "gh pr create";
    p = "pnpm";
    headroom-update = ''uv tool update --python 3.13 "headroom-ai[all]"'';
    codex = "headroom wrap codex";
    claude = "headroom wrap claude";
  };
}
