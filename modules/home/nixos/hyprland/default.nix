{...}: {
  imports = [
    ./animations.nix
    ./binds.nix
    ./cider.nix
    ./env.nix
    ./exec-once.nix
    ./session.nix
    ./settings.nix
    # Keep workspace-intent before window-rules so generated routing rules stay
    # at the end of merged settings.
    ./workspace-intent.nix
    ./window-rules.nix
  ];
}
