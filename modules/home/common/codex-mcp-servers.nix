{
  config,
  androidHome,
}: let
  mcp = import ./mcp-servers.nix;
  catalog = mcp.catalog;
  servers = builtins.listToAttrs (
    map (
      name: {
        inherit name;
        value =
          if name == "sequential-thinking"
          then {
            command = "npx";
            args = ["-y" catalog.${name}.package];
          }
          else if name == "appium-mcp"
          then {
            command = "${config.home.profileDirectory}/bin/npx";
            args = ["-y" catalog.${name}.package];
            startup_timeout_sec = 60.0;
            env = {
              ANDROID_HOME = androidHome;
              PATH = "${androidHome}/platform-tools:${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
            };
          }
          else if name == "browserstack"
          then {
            command = "npx";
            args = ["-y" catalog.${name}.package];
            env_vars = ["BROWSERSTACK_USERNAME" "BROWSERSTACK_ACCESS_KEY"];
          }
          else {
            url = catalog.${name}.url;
          };
      }
    )
    mcp.membership.codex
  );
in
  servers
  // {
    linear =
      servers.linear
      // {
        tools = {
          save_comment.approval_mode = "approve";
          save_document.approval_mode = "approve";
          save_issue.approval_mode = "approve";
        };
      };
    github =
      servers.github
      // {
        bearer_token_env_var = "GITHUB_PAT_TOKEN";
      };
    context7 =
      servers.context7
      // {
        env_http_headers.CONTEXT7_API_KEY = "CONTEXT7_API_KEY";
      };
  }
