{host, ...}: {
  imports = [./hardware.nix];

  networking.hostName = host.hostname;
  system.stateVersion = host.systemStateVersion;
}
