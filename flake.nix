{
  # Meta description for this Nix flake, appears in tooling and documentation
  description = "Mitra's NixOS configuration";

  # Inputs defines all external dependencies and optional modules.
  inputs = {
    # Main NixOS package sources (stable and unstable channels)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Unstable Nixpkgs when newer versions of packages are needed
    # Visual theming via Stylix module
    stylix.url = "github:danth/stylix/release-25.05";

    # HyprPanel (Wayland panel for Hyprland window manager)
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    # Advanced shell for Wayland compositors (for custom widgets and scripting)
    ags.url = "github:Aylur/ags";

    # Home Manager as a flake input, for user-level package and dotfile configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # Ensures Home Manager uses the same nixpkgs as the rest of the system to avoid version mismatches.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fine-cmdline Neovim plugin, imported as plain source (not as a flake) for plugin compilation
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  # Outputs expose the 'nixosConfigurations' for deployment
  outputs = {
    nixpkgs,
    home-manager,
    ags,
    ...
  } @ inputs: let
    # System architecture to target (e.g., 'x86_64-linux', 'aarch64-linux', etc.)
    system = "x86_64-linux";
    # Name of this host, used for per-host configurations and imports
    host = "nixos";
    # Current user's username, used for user-level configuration imports
    username = "mitra";
    # Overlay with unstable packages for when the latest versions are required or for specific packages only found on unstable
    unstable-pkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true; # Enable unfree packages (e.g., proprietary software)
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
          inherit unstable-pkgs; # Unstable package set for selective use
        };

        # List of modules to configure the system
        modules = [
          ./hosts/${host}/config.nix # Host-specific system settings
          inputs.stylix.nixosModules.stylix # Theme and appearance customization via Stylix
          {nixpkgs.overlays = [inputs.hyprpanel.overlay];} # Overlay HyprPanel for Wayland panel functionality
          home-manager.nixosModules.home-manager # Enable Home Manager at the system level
          {
            # Home Manager configuration block for this user/host
            # Each definition in this block enhances user workspace, with proper backups & flexibility
            home-manager = {
              extraSpecialArgs = {
                inherit username; # Makes the username available to user modules
                inherit inputs; # Passes all flake inputs to home-manager modules
                inherit host; # Lets modules perform host-specific customization
                inherit ags; # Passes AGS reference for per-user shell widgets
              };

              useGlobalPkgs = true; # Ensures user environment uses global (system) packages for consistency
              useUserPackages = true; # Allows the user to install and manage their own packages
              backupFileExtension = "backup"; # Sets the file extension used for backups, assisting in safe upgrades or rollbacks
              users.${username} = import ./hosts/${host}/home.nix; # Import user-level Home Manager config for this host
            };
          }
        ];
      };
    };
  };
}
