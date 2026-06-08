{
  config,
  inputs,
  pkgs,
  ...
}: let
  toml = pkgs.formats.toml {};
  home = config.home.homeDirectory;
  codexPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  codexConfig = toml.generate "codex-config.toml" {
    personality = "pragmatic";
    sandbox_mode = "danger-full-access";
    approval_policy = "never";
    approvals_reviewer = "user";
    model_reasoning_effort = "xhigh";
    model = "gpt-5.5";
    web_search = "live";
    plan_mode_reasoning_effort = "xhigh";

    model_providers = {
      mlx = {
        name = "MLX LM";
        base_url = "http://localhost:8888/v1";
      };

      ollama-launch = {
        name = "Ollama";
        base_url = "http://127.0.0.1:11434/v1/";
        wire_api = "responses";
      };

      omlx = {
        name = "oMLX";
        base_url = "http://127.0.0.1:8000/v1";
        env_key = "OMLX_API_KEY";
      };
    };

    projects = {
      "${home}/WebstormProjects/mobile".trust_level = "trusted";
      "${home}/PycharmProjects/backend".trust_level = "trusted";
      "${home}/WebstormProjects/comun-web".trust_level = "trusted";
      "${home}".trust_level = "trusted";
      "${home}/Documents/Obsidian Vault/Personal".trust_level = "trusted";
      "${home}/nix-config".trust_level = "trusted";
      "${home}/Documents/Obsidian Vault".trust_level = "trusted";
      "${home}/PycharmProjects/comun-mcp-server".trust_level = "trusted";
      "${home}/WebstormProjects/nixos-config".trust_level = "trusted";
      "${home}/WebstormProjects/macos-nix-config".trust_level = "trusted";
    };

    notice = {
      hide_gpt5_1_migration_prompt = true;
      "hide_gpt-5.1-codex-max_migration_prompt" = true;
      hide_full_access_warning = true;
      fast_default_opt_out = true;

      model_migrations = {
        "gpt-5.2" = "gpt-5.4";
        "gpt-5.3-codex" = "gpt-5.4";
      };
    };

    mcp_servers = {
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
      openaiDeveloperDocs.url = "https://developers.openai.com/mcp";
      statsig.url = "https://api.statsig.com/v1/mcp";

      maestro = {
        command = "maestro";
        args = ["mcp"];
      };

      browserstack = {
        command = "npx";
        args = [
          "-y"
          "@browserstack/mcp-server@latest"
        ];
        env_vars = [
          "BROWSERSTACK_USERNAME"
          "BROWSERSTACK_ACCESS_KEY"
        ];
      };

      appium-mcp = {
        command = "npx";
        args = [
          "-y"
          "appium-mcp@latest"
        ];
        env.ANDROID_HOME = "${home}/Android/Sdk";
      };
    };

    features = {
      apps = true;
      multi_agent = true;
      prevent_idle_sleep = true;
      goals = true;
      terminal_resize_reflow = true;
      mentions_v2 = true;
      js_repl = false;
      memories = true;
    };

    tui = {
      theme = "catppuccin-mocha";
      vim_mode_default = true;
      status_line = [
        "model-with-reasoning"
        "context-remaining"
        "weekly-limit"
        "run-state"
        "project-name"
        "branch-changes"
        "task-progress"
      ];
      status_line_use_colors = true;

      model_availability_nux."gpt-5.5" = 4;
    };

    plugins = {
      "linear@openai-curated".enabled = true;
      "google-calendar@openai-curated".enabled = true;
      "gmail@openai-curated".enabled = true;
      "github@openai-curated".enabled = true;
      "expo@openai-curated".enabled = true;
      "documents@openai-primary-runtime".enabled = true;
      "spreadsheets@openai-primary-runtime".enabled = true;
      "presentations@openai-primary-runtime".enabled = true;
      "computer-use@openai-bundled".enabled = true;
      "slack@openai-curated".enabled = true;
      "browser@openai-bundled".enabled = true;
      "chrome@openai-bundled".enabled = true;
    };

    apps.asdk_app_69a089a326dc8191b32a3f2553f5be2c.tools.linear_save_issue.approval_mode = "approve";

    desktop = {
      appearanceLightCodeThemeId = "catppuccin";
      appearanceDarkCodeThemeId = "catppuccin";
      usePointerCursors = true;
      preventSleepWhileRunning = true;
      keepRemoteControlAwakeWhilePluggedIn = true;
      selected-avatar-id = "fireball";

      appearanceLightChromeTheme = {
        accent = "#8839ef";
        contrast = 45;
        ink = "#4c4f69";
        opaqueWindows = false;
        surface = "#eff1f5";
        fonts = {};
        semanticColors = {
          diffAdded = "#40a02b";
          diffRemoved = "#d20f39";
          skill = "#8839ef";
        };
      };

      appearanceDarkChromeTheme = {
        accent = "#cba6f7";
        contrast = 60;
        ink = "#cdd6f4";
        opaqueWindows = false;
        surface = "#1e1e2e";
        fonts = {};
        semanticColors = {
          diffAdded = "#a6e3a1";
          diffRemoved = "#f38ba8";
          skill = "#cba6f7";
        };
      };
    };
  };

  ollamaLaunchProfile = toml.generate "codex-ollama-launch-config.toml" {
    model_provider = "ollama-launch";
    forced_login_method = "api";

    model_providers.ollama-launch = {
      name = "Ollama";
      base_url = "http://127.0.0.1:11434/v1/";
      wire_api = "responses";
    };
  };

  gptOssProfile = toml.generate "codex-gpt-oss-config.toml" {
    model_provider = "ollama-launch";
    model = "gpt-oss";
  };
in {
  home.packages = [
    codexPackage
    pkgs.nodejs
    pkgs.maestro
  ];

  home.file = {
    ".codex/config.toml".source = codexConfig;
    ".codex/ollama-launch.config.toml".source = ollamaLaunchProfile;
    ".codex/gpt-oss.config.toml".source = gptOssProfile;
  };
}
