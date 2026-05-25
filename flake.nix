{
  # Meta description for this Nix flake, appears in tooling and documentation
  description = "Mitra's NixOS configuration";

  # Inputs defines all external dependencies and optional modules.
  inputs = {
    # Main NixOS package sources (stable and unstable channels)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Kernel-only pin for Linux 7.0.10, which includes the MediaTek btmtk Bluetooth fix.
    nixpkgs-kernel.url = "github:nixos/nixpkgs/c67afa6adaf99e9b3af8f3432e6c084ffdfc252d";

    # Visual theming via Stylix module
    stylix.url = "github:danth/stylix/release-25.11";

    # Advanced shell for Wayland compositors (for custom widgets and scripting)
    ags.url = "github:Aylur/ags";

    nvf.url = "github:notashelf/nvf";

    # Home Manager as a flake input, for user-level package and dotfile configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # Ensures Home Manager uses the same nixpkgs as the rest of the system to avoid version mismatches.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs expose the 'nixosConfigurations' for deployment
  outputs = {
    nixpkgs,
    ags,
    ...
  } @ inputs: let
    # System architecture to target (e.g., 'x86_64-linux', 'aarch64-linux', etc.)
    system = "x86_64-linux";
    # Name of this host, used for per-host configurations and imports
    host = "nixos";
    # Current user's username, used for user-level configuration imports
    username = "mitra";
    kernelPkgs = import inputs.nixpkgs-kernel {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      # Define a NixOS system configuration for the specified host
      "${host}" = nixpkgs.lib.nixosSystem {
        # Pass arguments to all loaded modules for easier customization and DRY configurations
        specialArgs = {
          inherit system; # Target system architecture
          inherit inputs; # All flake inputs (dependencies)
          inherit username; # Current user
          inherit host; # Hostname
          inherit ags; # AGS module for custom shell widgets
          inherit kernelPkgs; # Kernel packages pinned separately from the system channel
        };

        # List of modules to configure the system
        modules = [
          ./modules/core # Host-specific system settings
        ];
      };
    };
  };
}
