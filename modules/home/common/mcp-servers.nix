{
  config,
  androidHome,
}: let
  codex = {
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
    context7 = {
      url = "https://mcp.context7.com/mcp";
      env_http_headers.CONTEXT7_API_KEY = "CONTEXT7_API_KEY";
    };

    appium-mcp = {
      # Use the Home Manager profile because Codex launched from the macOS GUI
      # does not inherit the interactive shell's PATH.
      command = "${config.home.profileDirectory}/bin/npx";
      args = [
        "-y"
        "appium-mcp@1.92.2"
      ];
      startup_timeout_sec = 60.0;
      env = {
        ANDROID_HOME = androidHome;
        PATH = "${androidHome}/platform-tools:${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
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

    sequential-thinking = {
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-sequential-thinking"
      ];
    };
  };

  # OpenCode's Home Manager integration uses a distinct MCP schema. Keep its
  # equivalent server definitions here so Codex and OpenCode stay in sync.
  opencode = {
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
      headers.Authorization = "Bearer {env:GITHUB_PAT_TOKEN}";
    };
    figma = {
      type = "remote";
      url = "https://mcp.figma.com/mcp";
      enabled = true;
    };
    notion = {
      type = "remote";
      url = "https://mcp.notion.com/mcp";
      enabled = true;
    };
    datadog = {
      type = "remote";
      url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp";
      enabled = true;
    };
    expo = {
      type = "remote";
      url = "https://mcp.expo.dev/mcp";
      enabled = true;
    };
    openaiDeveloperDocs = {
      type = "remote";
      url = "https://developers.openai.com/mcp";
      enabled = true;
    };
    statsig = {
      type = "remote";
      url = "https://api.statsig.com/v1/mcp";
      enabled = true;
    };
    context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
      enabled = true;
      headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
    };
    sequential-thinking = {
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-sequential-thinking"
      ];
      enabled = true;
    };
  };
in {
  inherit codex opencode;
}
