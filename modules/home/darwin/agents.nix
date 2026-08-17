{
  config,
  lib,
  pkgs,
  ...
}: let
  json = pkgs.formats.json {};
  opencodeConfig = json.generate "opencode.json" {
    "$schema" = "https://opencode.ai/config.json";
    model = "gpt-5.4";
  };
in {
  programs = {
    mcp.servers = {
      linear = {
        type = "remote";
        url = "https://mcp.linear.app/mcp";
        enabled = true;
      };
      github = {
        type = "remote";
        url = "https://api.githubcopilot.com/mcp/";
        enabled = true;
        oauth = false;
        headers = {
          Authorization = "Bearer {env:GITHUB_PAT_TOKEN}";
        };
      };
      "datadog-mcp" = {
        type = "remote";
        url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp";
        enabled = true;
      };
    };

    opencode = {
      enable = true;
      enableMcpIntegration = true;
    };
  };

  # OpenCode and Headroom both update this configuration at runtime. Seed it
  # declaratively, but keep the live file writable after the first activation.
  home.activation.ensureMutableOpenCodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config_dir="${config.xdg.configHome}/opencode"
    config_file="$config_dir/opencode.json"
    generated_config="${opencodeConfig}"

    if [ -L "$config_file" ]; then
      link_target="$(${pkgs.coreutils}/bin/readlink -f "$config_file" || true)"
      case "$link_target" in
        /nix/store/*)
          verboseEcho "Replacing previous Home Manager symlink at $config_file with a mutable file"
          run rm "$config_file"
          ;;
        *)
          verboseEcho "Leaving user-managed OpenCode config symlink $config_file unchanged"
          ;;
      esac
    fi

    if [ ! -e "$config_file" ] && [ ! -L "$config_file" ]; then
      verboseEcho "Creating mutable OpenCode config $config_file"
      run mkdir -p "$config_dir"
      run install -m 0644 "$generated_config" "$config_file"
    fi
  '';
}
