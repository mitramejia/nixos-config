{
  linear = {
    url = "https://mcp.linear.app/mcp";
    tools = {
      save_comment.approval_mode = "approve";
      save_document.approval_mode = "approve";
      save_issue.approval_mode = "approve";
    };
  };

  github = {
    url = "https://api.githubcopilot.com/mcp/";
    bearer_token_env_var = "GITHUB_PAT_TOKEN";
  };

  figma.url = "https://mcp.figma.com/mcp";
  notion.url = "https://mcp.notion.com/mcp";
  datadog.url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp";
  expo.url = "https://mcp.expo.dev/mcp";
  openaiDeveloperDocs.url = "https://developers.openai.com/mcp";
  statsig.url = "https://api.statsig.com/v1/mcp";

  appium-mcp = {
    command = "npx";
    args = [
      "-y"
      "appium-mcp@1.92.0"
    ];
  };

  browserstack = {
    command = "npx";
    args = [
      "-y"
      "@browserstack/mcp-server@1.2.34"
    ];
    env_vars = [
      "BROWSERSTACK_USERNAME"
      "BROWSERSTACK_ACCESS_KEY"
    ];
  };
}
