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
  mcp = import ../mcp-servers.nix;
  codexMcpServers = import ../codex-mcp-servers.nix {
    inherit config;
    androidHome = config.home.sessionVariables.ANDROID_HOME;
  };
  codexMcp = config.private.codexMcpServers;
  openCodeMcp = config.private.openCodeMcpServers;
  mcpCatalogAdaptersCheck = assert lib.assertMsg (lib.intersectLists mcp.membership.opencode mcp.membership.codex == mcp.membership.opencode) "MCP common membership must have one shared identity list.";
  assert lib.assertMsg (lib.subtractLists mcp.membership.opencode mcp.membership.codex == ["appium-mcp" "browserstack"]) "Only Codex may add Appium and BrowserStack.";
  assert lib.assertMsg (mcp.catalog.appium-mcp.package == "appium-mcp@1.92.2" && mcp.catalog.browserstack.package == "@browserstack/mcp-server@1.2.34") "Local MCP package identities belong in the catalog.";
  assert lib.assertMsg (codexMcp.figma.url == mcp.catalog.figma.url && openCodeMcp.figma.type == "remote" && openCodeMcp.figma.url == mcp.catalog.figma.url) "MCP adapters must render representative remote servers.";
  assert lib.assertMsg (codexMcp.linear.tools.save_comment.approval_mode == "approve" && codexMcp.linear.tools.save_document.approval_mode == "approve" && codexMcp.linear.tools.save_issue.approval_mode == "approve") "Codex must retain Linear approval behavior.";
  assert lib.assertMsg (codexMcp.github.bearer_token_env_var == "GITHUB_PAT_TOKEN" && codexMcp.context7.env_http_headers.CONTEXT7_API_KEY == "CONTEXT7_API_KEY" && openCodeMcp.github.oauth == false && openCodeMcp.github.headers.Authorization == "Bearer {env:GITHUB_PAT_TOKEN}" && openCodeMcp.context7.headers.CONTEXT7_API_KEY == "{env:CONTEXT7_API_KEY}") "MCP adapters must retain GitHub and Context7 authentication.";
  assert lib.assertMsg (openCodeMcp.sequential-thinking.type == "local" && openCodeMcp.sequential-thinking.command == ["npx" "-y" mcp.catalog.sequential-thinking.package]) "OpenCode must render sequential thinking as a local command.";
  assert lib.assertMsg (codexMcp.appium-mcp.command == "${config.home.profileDirectory}/bin/npx" && codexMcp.appium-mcp.args == ["-y" mcp.catalog.appium-mcp.package] && codexMcp.appium-mcp.startup_timeout_sec == 60.0 && codexMcp.appium-mcp.env.ANDROID_HOME == config.home.sessionVariables.ANDROID_HOME && codexMcp.appium-mcp.env.PATH == "${config.home.sessionVariables.ANDROID_HOME}/platform-tools:${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin" && codexMcp.browserstack.env_vars == ["BROWSERSTACK_USERNAME" "BROWSERSTACK_ACCESS_KEY"]) "Codex must retain Appium package, environment, and profile launcher behavior.";
    pkgs.runCommand "mcp-catalog-adapters" {} "mkdir -p $out";

  profiles = import ./profiles.nix;
  codexConfig = toml.generate "codex-config.toml" (
    (import ./settings.nix)
    // {
      model_providers = import ./model-providers.nix;
      projects = import ./trusted-projects.nix {inherit home;};
      mcp_servers = codexMcpServers;
      desktop = import ./desktop-theme.nix;
    }
  );
in {
  options.private.mcpCatalogAdaptersCheck = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    description = "Focused MCP catalog and adapter check.";
  };

  options.private.codexMcpServers = lib.mkOption {
    type = lib.types.attrs;
    internal = true;
    readOnly = true;
    description = "Codex MCP servers rendered from the shared catalog.";
  };

  config = {
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

    private.codexMcpServers = codexMcpServers;
    private.mcpCatalogAdaptersCheck = mcpCatalogAdaptersCheck;
  };
}
