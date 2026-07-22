{
  pkgs,
  inputs,
  hyprlandPkgs,
  host,
  ...
}: let
  inherit (import ../variables.nix) gitUsername;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    overwriteBackup = true;
    extraSpecialArgs = {
      inherit inputs host hyprlandPkgs;
    };
    users.${host.username} = {
      imports = [
        ../home/common
        ../home/nixos
      ];
      home = {
        inherit (host) username homeDirectory;
        stateVersion = host.homeStateVersion;
      };
    };
  };

  nix.settings.allowed-users = [host.username];

  users.mutableUsers = true;
  users.users.${host.username} = {
    isNormalUser = true;
    description = gitUsername;
    extraGroups = [
      "adbusers"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "wheel"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
}
