{host, ...}: {
  imports = [
    ./agents.nix
    ./codex.nix
    ./git.nix
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
