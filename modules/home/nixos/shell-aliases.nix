{host, ...}: {
  sv = "sudo nvim";
  fr = "nh os switch --hostname ${host.key} ${host.nixConfig}";
  # A full flake update can replace systemd and re-exec the user manager.
  # Activate it at the next boot instead of interrupting Hyprland live.
  fu = "nh os boot --ask --hostname ${host.key} --update ${host.nixConfig}";
  ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
  top = "btop";
  copy = "wl-copy";
}
