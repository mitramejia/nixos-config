{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  toml = pkgs.formats.toml {};
  home = config.home.homeDirectory;
  codexPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  profiles = import ./profiles.nix;
  codexConfig = toml.generate "codex-config.toml" (
    (import ./settings.nix)
    // {
      model_providers = import ./model-providers.nix;
      projects = import ./trusted-projects.nix {inherit home;};
      mcp_servers = import ./mcp-servers.nix {
        inherit config;
        androidHome = config.home.sessionVariables.ANDROID_HOME;
      };
      desktop = import ./desktop-theme.nix;
    }
  );
in {
  home = {
    packages = [
      codexPackage
      pkgs.nodejs
    ];

    file = {
      ".codex/agents/commit-staged.toml".source = ./agents/commit-staged.toml;
      ".codex/ollama-launch.config.toml".source = toml.generate "codex-ollama-launch-config.toml" profiles.ollamaLaunch;
      ".codex/gpt-oss.config.toml".source = toml.generate "codex-gpt-oss-config.toml" profiles.gptOss;
    };

    # Keep the main Codex config mutable so external tools can inject
    # provider and MCP blocks. The generated TOML is used only to seed the file.
    activation.ensureMutableCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      config_dir="${home}/.codex"
      config_file="$config_dir/config.toml"
      generated_config="${codexConfig}"

      run mkdir -p "$config_dir"

      if [ -L "$config_file" ]; then
        link_target="$(${pkgs.coreutils}/bin/readlink -f "$config_file" || true)"
        case "$link_target" in
          /nix/store/*)
            verboseEcho "Replacing the previous Home Manager symlink at $config_file with a mutable file"
            run rm "$config_file"
            ;;
          *)
            verboseEcho "Leaving user-managed Codex config symlink at $config_file unchanged"
            ;;
        esac
      fi

      if [ ! -e "$config_file" ] && [ ! -L "$config_file" ]; then
        verboseEcho "Creating mutable Codex config at $config_file"
        run install -m 0644 "$generated_config" "$config_file"
      elif [ ! -L "$config_file" ] && [ ! -w "$config_file" ]; then
        verboseEcho "Making Codex config writable at $config_file"
        run chmod u+w "$config_file"
      fi
    '';
  };
}
