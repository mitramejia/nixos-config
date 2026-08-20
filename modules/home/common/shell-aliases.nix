{
  programs.zsh.shellAliases = {
    cat = "bat";
    v = "vim";
    open = "xdg-open";
    man = "batman";
    ".." = "cd ..";
    gp = "git push origin";
    gash = "git stash";
    gasha = "git stash apply";
    gplo = "git pull origin";
    open-pr = "gh pr create";
    p = "pnpm";
    headroom-update = ''uv tool update --python 3.13 "headroom-ai[all]"'';
    codex = "HERDR_AGENT=codex headroom wrap codex";
    claude = "headroom wrap claude";
    oc = "opencode --auto";
    h = "herdr";
    ha = "herdr agent";
    hp = "herdr pane";
    hs = "herdr --session";
    ht = "herdr tab";
  };
}
