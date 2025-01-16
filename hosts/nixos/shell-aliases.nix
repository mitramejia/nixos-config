{
  username,
  host,
  ...
}: {
  sv = "sudo nvim";
  fr = "nh os switch --hostname ${host} /home/${username}/nix-config";
  fu = "nh os switch --hostname ${host} --update /home/${username}/nix-config";
  ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
  v = "lvim";
  cat = "bat";
  ls = "eza --icons";
  ll = "eza -lh --icons --grid --group-directories-first";
  la = "eza -lah --icons --grid --group-directories-first";
  ".." = "cd ..";
  top = "btop";
  gp = "git push origin";
  gash = "git stash";
  gasha = "git stash apply";
  gplo = "git pull origin";
  open-pr = "gh pr create";
  p = "pnpm";
  vim = "lvim";
}
