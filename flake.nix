{
  description = "Mitra's NixOS and macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:herdrdev/herdr/v0.8.0";
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
    opencode = {
      # Bun affects fixed-output dependency hashes; retain upstream's own nixpkgs lock.
      url = "github:anomalyco/opencode";
    };
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      # Use upstream Git transport because GitLab's API returns HTTP 403 to Nix.
      url = "git+https://gitlab.com/rycee/nur-expressions.git?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      # Newer revisions require ffmpeg_8/ffmpeg_9, which NixOS 26.05 does not provide.
      url = "github:0xc000022070/zen-browser-flake/8c5b06ac3d7157ed46ed770cc1afead935d99c1e";
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
        nixConfig = "/home/mitra/nix-config";
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
        nixConfig = "/Users/mitramejia/nix-config";
        systemStateVersion = 4;
        homeStateVersion = "23.11";
      };
    };

    mkUnstablePkgs = system:
      import inputs.nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
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
      unstablePkgs = mkUnstablePkgs host.system;
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
          # Home Manager still overrides hyprland, which the upstream portal
          # no longer takes. Keep Hyprland's pinned portal and its dependencies.
          xdg-desktop-portal-hyprland =
            hyprlandInputPkgs.xdg-desktop-portal-hyprland
            // {
              override = args:
                hyprlandInputPkgs.xdg-desktop-portal-hyprland.override
                (builtins.removeAttrs args ["hyprland"]);
            };
        };
    in
      nixpkgs.lib.nixosSystem {
        inherit (host) system;
        specialArgs = {
          inherit
            inputs
            host
            kernelPkgs
            hyprlandPkgs
            unstablePkgs
            ;
        };
        modules = [
          ./hosts/nixos
          ./modules/nixos
        ];
      };

    nixosHost = mkNixos hosts.nixos;
    nixosHome = nixosHost.config.home-manager.users.${hosts.nixos.username};
    hyprlandWorkspaceIntentCheck = nixosHome.private.hyprlandWorkspaceIntent.check;
    hyprlandKeybindingIntentCheck = nixosHome.private.hyprlandKeybindingIntent.check;
    hyprlandWorkspaceStartupCheck = nixosHome.private.hyprlandExecOnce.workspaceStartupCheck;
    darwinHost = darwin.lib.darwinSystem {
      system = hosts.macbook.system;
      specialArgs = {
        host = hosts.macbook;
        unstablePkgs = mkUnstablePkgs hosts.macbook.system;
        inherit inputs;
      };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        ./hosts/macos
        ./modules/darwin
      ];
    };
    darwinHome = darwinHost.config.home-manager.users.${hosts.macbook.username};

    forSupportedSystems = nixpkgs.lib.genAttrs [hosts.nixos.system hosts.macbook.system];
    validationPkgs = forSupportedSystems (system: import nixpkgs {inherit system;});
    validators = forSupportedSystems (system: let
      pkgs = validationPkgs.${system};
    in
      pkgs.writeShellApplication {
        name = "validate";
        runtimeInputs = [pkgs.alejandra pkgs.coreutils pkgs.findutils pkgs.nix];
        text = ''
          if [[ ! -f flake.nix || ! -f flake.lock ]]; then
            printf 'Run validate from the repository root.\n' >&2
            exit 1
          fi

          status=0
          run_check() {
            local label="$1"
            shift
            printf '\n== %s ==\n' "$label"
            if ! "$@"; then
              printf 'FAILED: %s\n' "$label" >&2
              status=1
            fi
          }

          file_list=$(mktemp)
          trap 'rm -f -- "$file_list"' EXIT
          if ! find . -type d \
            \( -name .git -o -name .scratch -o -name .codegraph \
               -o -name generated -o -name vendor -o -name node_modules \
            \) -prune -o -type f -name '*.nix' -print0 > "$file_list"; then
            printf 'FAILED: Nix file enumeration\n' >&2
            exit 1
          fi
          mapfile -d "" -t files < "$file_list"
          run_check 'Nix formatting (non-mutating)' alejandra --check "''${files[@]}"
          run_check 'NixOS derivation evaluation' nix eval --raw --no-update-lock-file \
            .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
          run_check 'Darwin derivation evaluation' nix eval --raw --no-update-lock-file \
            .#darwinConfigurations.macbook.system.drvPath
          run_check 'Native flake checks' nix flake check --no-update-lock-file
          exit "$status"
        '';
      });
  in {
    formatter = forSupportedSystems (system: validationPkgs.${system}.alejandra);
    packages = forSupportedSystems (system: {validate = validators.${system};});

    nixosConfigurations.nixos = nixosHost;

    checks.${hosts.nixos.system} = {
      hyprland-workspace-intent-generated-settings = hyprlandWorkspaceIntentCheck;
      hyprland-keybinding-intent = hyprlandKeybindingIntentCheck;
      hyprland-workspace-startup-lua = hyprlandWorkspaceStartupCheck;
      mcp-catalog-adapters = nixosHome.private.mcpCatalogAdaptersCheck;
      opencode-mutable-config-nixos = nixosHome.private.openCodeMutableConfigCheck;
    };

    checks.${hosts.macbook.system} = {
      mcp-catalog-adapters = darwinHome.private.mcpCatalogAdaptersCheck;
      opencode-mutable-config-darwin = darwinHome.private.openCodeMutableConfigCheck;
    };

    darwinConfigurations.macbook = darwinHost;
  };
}
