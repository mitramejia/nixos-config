{host, ...}: {
  imports = [
    ./codex.nix
    ./git.nix
    ./opencode.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    inherit (host) username homeDirectory;
    stateVersion = host.homeStateVersion;
  };
}
