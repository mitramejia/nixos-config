{host, ...}: {
  sv = "sudo nvim";
  fr = "nh os switch --hostname ${host.key} ${host.nixConfig}";
  # A full flake update can replace systemd and re-exec the user manager.
  # Activate it at the next boot instead of interrupting Hyprland live.
  fu = "nh os boot --ask --hostname ${host.key} --update ${host.nixConfig}";
  ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
  cat = "bat";
  man = "batman";
  ".." = "cd ..";
  top = "btop";
  gp = "git push origin";
  gash = "git stash";
  gasha = "git stash apply";
  gplo = "git pull origin";
  open-pr = "gh pr create";
  copy = "wl-copy";
  p = "pnpm";
  headroom-update = ''uv tool update --python 3.13 "headroom-ai[all]"'';
  codex = "headroom wrap codex";
  claude = "headroom wrap claude";
}
