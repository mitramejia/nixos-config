_: {
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
      settings = {
        model = "gpt-5.4";
      };
    };
  };
}
