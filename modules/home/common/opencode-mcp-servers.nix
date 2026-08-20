{lib}: let
  mcp = import ./mcp-servers.nix;
  catalog = mcp.catalog;
  servers = lib.genAttrs mcp.membership.opencode (
    name:
      if name == "sequential-thinking"
      then {
        command = "npx";
        args = ["-y" catalog.${name}.package];
        enabled = true;
      }
      else {
        type = "remote";
        url = catalog.${name}.url;
        enabled = true;
      }
  );
in rec {
  homeManager =
    servers
    // {
      github =
        servers.github
        // {
          oauth = false;
          headers.Authorization = "Bearer {env:GITHUB_PAT_TOKEN}";
        };
      context7 =
        servers.context7
        // {
          headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };
    };

  opencode =
    lib.mapAttrs (
      _: server:
        if server ? url
        then server
        else
          (builtins.removeAttrs server ["args"])
          // {
            type = "local";
            command = [server.command] ++ server.args;
          }
    )
    homeManager;
}
