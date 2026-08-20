{
  catalog = {
    linear.url = "https://mcp.linear.app/mcp";
    github.url = "https://api.githubcopilot.com/mcp/";
    figma.url = "https://mcp.figma.com/mcp";
    notion.url = "https://mcp.notion.com/mcp";
    datadog.url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp";
    expo.url = "https://mcp.expo.dev/mcp";
    openaiDeveloperDocs.url = "https://developers.openai.com/mcp";
    statsig.url = "https://api.statsig.com/v1/mcp";
    context7.url = "https://mcp.context7.com/mcp";
    sequential-thinking.package = "@modelcontextprotocol/server-sequential-thinking";
    appium-mcp.package = "appium-mcp@1.92.2";
    browserstack.package = "@browserstack/mcp-server@1.2.34";
  };

  membership = let
    common = [
      "linear"
      "github"
      "figma"
      "notion"
      "datadog"
      "expo"
      "openaiDeveloperDocs"
      "statsig"
      "context7"
      "sequential-thinking"
    ];
  in {
    codex = common ++ ["appium-mcp" "browserstack"];
    opencode = common;
  };
}
