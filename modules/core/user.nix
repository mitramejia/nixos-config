{
  pkgs,
  inputs,
  hyprlandPkgs,
  username,
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
      inherit username; # Makes the username available to user modules
      inherit inputs; # Passes all flake inputs to home-manager modules
      inherit host; # Lets modules perform host-specific customization
      inherit hyprlandPkgs; # Keeps Hyprland package and portal versions aligned in Home Manager
    };
    users.${username} = {
      imports = [../home];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };

  nix.settings.allowed-users = ["${username}"];

  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
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
