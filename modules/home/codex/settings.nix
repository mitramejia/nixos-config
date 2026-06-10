{
  personality = "pragmatic";
  sandbox_mode = "danger-full-access";
  approval_policy = "never";
  approvals_reviewer = "user";
  model_reasoning_effort = "xhigh";
  model = "gpt-5.5";
  web_search = "live";
  plan_mode_reasoning_effort = "xhigh";

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
}
