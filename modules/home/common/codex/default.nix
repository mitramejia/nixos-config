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
      mcp_servers = import ./mcp-servers.nix {inherit home;};
      desktop = import ./desktop-theme.nix;
    }
  );
in {
  home.packages = [
    codexPackage
    pkgs.nodejs
    pkgs.maestro
  ];

  home.file = {
    ".codex/ollama-launch.config.toml".source = toml.generate "codex-ollama-launch-config.toml" profiles.ollamaLaunch;
    ".codex/gpt-oss.config.toml".source = toml.generate "codex-gpt-oss-config.toml" profiles.gptOss;
  };

  # Keep the main Codex config mutable so tools like Headroom can inject
  # provider and MCP blocks. The generated TOML is used only to seed the file.
  home.activation.ensureMutableCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config_dir="${home}/.codex"
    config_file="$config_dir/config.toml"
    generated_config="${codexConfig}"

    run mkdir -p "$config_dir"

    if [ -L "$config_file" ]; then
      verboseEcho "Replacing Home Manager symlink at $config_file with a mutable file"
      run rm "$config_file"
    fi

    if [ ! -e "$config_file" ]; then
      verboseEcho "Creating mutable Codex config at $config_file"
      run install -m 0644 "$generated_config" "$config_file"
    elif [ ! -w "$config_file" ]; then
      verboseEcho "Making Codex config writable at $config_file"
      run chmod u+w "$config_file"
    fi
  '';
}
