{pkgs, ...}: {
  # Only enable either docker or podman -- Not both
  virtualisation = {
    libvirtd.enable = false;
    docker.enable = true;
    podman.enable = false;
  };

  programs = {
    virt-manager.enable = true;
    dconf.enable = true;
  };
}
