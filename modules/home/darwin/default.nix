{host, ...}: {
  imports = [
    ./agents.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./terminal.nix
    ./tmux.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = host.username;
    homeDirectory = host.homeDirectory;
    stateVersion = host.homeStateVersion;
  };
}
