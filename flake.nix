{
  description = "Mitra's NixOS and macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Linux-only pin for the MediaTek btmtk Bluetooth fix.
    nixpkgs-kernel.url = "github:nixos/nixpkgs/c67afa6adaf99e9b3af8f3432e6c084ffdfc252d";

    # Keep Hyprland's nixpkgs independent: its master package set provides the
    # guiutils override used by the NixOS desktop configuration.
    hyprland.url = "github:hyprwm/Hyprland";

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep Noctalia's nixpkgs independent because it needs recent Quickshell.
    noctalia.url = "github:noctalia-dev/noctalia-shell";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    cursor-plugins = {
      url = "github:cursor/plugins";
      flake = false;
    };
    expo-skills = {
      url = "github:expo/skills";
      flake = false;
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = inputs @ {
    darwin,
    nixpkgs,
    ...
  }: let
    hosts = {
      nixos = {
        key = "nixos";
        platform = "nixos";
        system = "x86_64-linux";
        hostname = "nixos";
        username = "mitra";
        homeDirectory = "/home/mitra";
        systemStateVersion = "24.11";
        homeStateVersion = "23.11";
      };
      macbook = {
        key = "macbook";
        platform = "darwin";
        system = "aarch64-darwin";
        hostname = "MitraMacBook";
        username = "mitramejia";
        homeDirectory = "/Users/mitramejia";
        systemStateVersion = 4;
        homeStateVersion = "23.11";
      };
    };

    mkNixos = host: let
      pkgs = import nixpkgs {
        inherit (host) system;
        config.allowUnfree = true;
      };
      kernelPkgs = import inputs.nixpkgs-kernel {
        inherit (host) system;
        config.allowUnfree = true;
      };
      hyprlandInputPkgs = inputs.hyprland.packages.${host.system};
      patchedHyprlandGuiutils =
        inputs.hyprland.inputs.hyprland-guiutils.packages.${host.system}.hyprland-guiutils.overrideAttrs
        (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.pkg-config];
          buildInputs = (old.buildInputs or []) ++ [pkgs.pango];
          preConfigure =
            (old.preConfigure or "")
            + ''
              export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags pango)"
            '';
        });
      hyprlandPkgs =
        hyprlandInputPkgs
        // {
          hyprland = hyprlandInputPkgs.hyprland.override {
            hyprland-guiutils = patchedHyprlandGuiutils;
          };
        };
    in
      nixpkgs.lib.nixosSystem {
        inherit (host) system;
        specialArgs = {
          inherit inputs host kernelPkgs hyprlandPkgs;
        };
        modules = [
          ./hosts/nixos
          ./modules/nixos
        ];
      };
  in {
    packages.${hosts.nixos.system} = let
      pkgs = import nixpkgs {
        system = hosts.nixos.system;
        config.allowUnfree = true;
      };
      headroomAi = pkgs.callPackage ./packages/headroom-ai.nix {};
    in {
      headroom-ai = headroomAi;
      default = headroomAi;
    };

    nixosConfigurations.nixos = mkNixos hosts.nixos;

    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = hosts.macbook.system;
      specialArgs = {
        host = hosts.macbook;
        inherit inputs;
      };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        ./hosts/macos
        ./modules/darwin
      ];
    };
  };
}
