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
      # Newer revisions require ffmpeg_8/ffmpeg_9, which NixOS 26.05 does not provide.
      url = "github:0xc000022070/zen-browser-flake/8c5b06ac3d7157ed46ed770cc1afead935d99c1e";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    inputs@{
      darwin,
      nixpkgs,
      ...
    }:
    let
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

      mkUnstablePkgs =
        system:
        import inputs.nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

      mkNixos =
        host:
        let
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
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
                buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.pango ];
                preConfigure = (old.preConfigure or "") + ''
                  export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags pango)"
                '';
              });
          hyprlandPkgs = hyprlandInputPkgs // {
            hyprland = hyprlandInputPkgs.hyprland.override {
              hyprland-guiutils = patchedHyprlandGuiutils;
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
      hyprlandWorkspaceConfig =
        nixosHost.config.home-manager.users.${hosts.nixos.username}.wayland.windowManager.hyprland;
      hyprlandWorkspaceSettings = hyprlandWorkspaceConfig.settings;
      hyprlandWorkspaceIntentCheck =
        let
          inherit (nixpkgs.lib) assertMsg drop;

          monitorDefinitions = hyprlandWorkspaceSettings.monitor;
          workspaceRules = hyprlandWorkspaceSettings.workspace_rule;
          windowRules = hyprlandWorkspaceSettings.window_rule;
          startupLua = (builtins.elemAt hyprlandWorkspaceSettings.on._args 1).expr;
          startupLuaLines = nixpkgs.lib.strings.splitString "\n" startupLua;
          generatedWorkspaceStartup = builtins.filter (command: command != null) (
            map (
              line:
              let
                matched = builtins.match ''.*hl\.exec_cmd\("([^\"]+)", \{ workspace = "([^\"]+)" \}\)'' line;
              in
              if matched == null then
                null
              else
                {
                  command = builtins.elemAt matched 0;
                  workspace = builtins.elemAt matched 1;
                }
            ) startupLuaLines
          );

          expectedMonitors = [
            {
              mode = "preferred";
              output = "DP-1";
              position = "auto";
              scale = 1.33;
            }
            {
              mode = "preferred";
              output = "DP-2";
              position = "auto";
              scale = 1.33;
              transform = 3;
            }
          ];

          expectedWorkspaceRules = [
            {
              workspace = "1";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "2";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "3";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "4";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "5";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "6";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "7";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "8";
              monitor = "DP-1";
              default = true;
            }
            {
              workspace = "9";
              monitor = "DP-2";
              default = true;
            }
            {
              workspace = "10";
              monitor = "DP-2";
              default = true;
            }
          ];

          expectedRoutingRules = [
            {
              match = {
                tag = "browser*";
              };
              workspace = "1";
            }
            {
              match = {
                tag = "im*";
              };
              workspace = "5";
            }
            {
              match = {
                tag = "games*";
              };
              workspace = "8";
            }
            {
              match = {
                class = "^(obsidian)$";
              };
              workspace = "6";
            }
            {
              match = {
                class = "^(Cider)$";
              };
              workspace = "7";
            }
          ];

          expectedWorkspaceStartupCommands = [
            {
              workspace = "1";
              command = "zen-beta";
            }
            {
              workspace = "2";
              command = "kitty -e herdr --session 2";
            }
            {
              workspace = "3";
              command = "kitty -e herdr --session 3";
            }
            {
              workspace = "5";
              command = "slack";
            }
            {
              workspace = "5";
              command = "zapzap";
            }
            {
              workspace = "6";
              command = "obsidian";
            }
            {
              workspace = "7";
              command = "cider-appimage";
            }
            {
              workspace = "9";
              command = "kitty";
            }
          ];

          routingRuleSuffix =
            if builtins.length windowRules >= builtins.length expectedRoutingRules then
              drop (builtins.length windowRules - builtins.length expectedRoutingRules) windowRules
            else
              [ ];
        in
        assert (
          assertMsg (
            builtins.length monitorDefinitions == 2
          ) "Expected two monitor definitions in generated Hyprland settings."
        );
        assert (
          assertMsg (
            monitorDefinitions == expectedMonitors
          ) "Generated monitor definitions no longer match workspace-intent."
        );
        assert (
          assertMsg (
            builtins.length workspaceRules == 10
          ) "Expected 10 workspace rules/mappings from workspace intent."
        );
        assert (
          assertMsg (
            workspaceRules == expectedWorkspaceRules
          ) "Generated workspace rules no longer match workspace intent."
        );
        assert (
          assertMsg (
            builtins.length windowRules >= builtins.length expectedRoutingRules
          ) "Expected at least workspace-targeted routing rules to exist."
        );
        assert (
          assertMsg (
            routingRuleSuffix == expectedRoutingRules
          ) "Workspace-targeted routing rules must remain last and in current order."
        );
        assert (
          assertMsg (
            generatedWorkspaceStartup == expectedWorkspaceStartupCommands
          ) "Workspace-targeted startup commands are not rendered in the expected order."
        );
        nixpkgs.legacyPackages.${hosts.nixos.system}.runCommand
          "hyprland-workspace-intent-generated-settings"
          { }
          ''
            mkdir -p "$out"
          '';
    in
    {
      nixosConfigurations.nixos = nixosHost;

      checks.${hosts.nixos.system} = {
        hyprland-workspace-intent-generated-settings = hyprlandWorkspaceIntentCheck;
      };

      darwinConfigurations.macbook = darwin.lib.darwinSystem {
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
    };
}
