{
  config,
  inputs,
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
    ".codex/config.toml".source = codexConfig;
    ".codex/ollama-launch.config.toml".source = toml.generate "codex-ollama-launch-config.toml" profiles.ollamaLaunch;
    ".codex/gpt-oss.config.toml".source = toml.generate "codex-gpt-oss-config.toml" profiles.gptOss;
  };
}
