{
  config,
  lib,
  pkgs,
  ...
}: let
  json = pkgs.formats.json {};

  # The vim plugin is configured in tui.json, per its documentation, so that is
  # the only place Nix declares it.
  tuiPlugins = [
    [
      "@leohenon/opencode-vim-plugin"
      {enabled = true;}
    ]
  ];

  opencodePlugins = ["opencode-claude-auth@latest"];

  opencodeMcpServers = let
    servers =
      (import ../common/mcp-servers.nix {
        inherit config;
        androidHome = null;
      }).opencode;
  in
    lib.mapAttrs (_: server:
      if server ? url
      then server
      else
        (builtins.removeAttrs server ["args"])
        // {
          type = "local";
          command = [server.command] ++ server.args;
        })
    servers;

  # OpenCode rewrites both files at runtime: Headroom edits opencode.json, and
  # the vim mode toggle persists to tui.json. Nix seeds a missing file, then
  # only ever adds absent plugins and MCP servers. It never reconciles options
  # or reclaims ownership, so anything edited or disabled by hand stays
  # untouched.
  mutableConfigs = [
    {
      name = "opencode.json";
      plugins = opencodePlugins;
      seed = {
        "$schema" = "https://opencode.ai/config.json";
        model = "gpt-5.4";
        permission = "allow";
        plugin = opencodePlugins;
        mcp = opencodeMcpServers;
      };
    }
    {
      name = "tui.json";
      plugins = tuiPlugins;
      seed = {plugin = tuiPlugins;};
    }
  ];

  ensureCall = entry: ''
    ensure_mutable_config ${lib.escapeShellArg entry.name} ${json.generate "opencode-seed-${entry.name}" entry.seed} ${json.generate "opencode-plugins-${entry.name}" entry.plugins}
  '';
in {
  home.activation.ensureMutableOpenCodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config_dir="${config.xdg.configHome}/opencode"

    ensure_mutable_config() {
      local name="$1" seed="$2" plugins="$3"
      local config_file="$config_dir/$name"
      local link_target

      if [ -L "$config_file" ]; then
        link_target="$(${pkgs.coreutils}/bin/readlink -f "$config_file" || true)"
        case "$link_target" in
          /nix/store/*)
            verboseEcho "Replacing previous Home Manager symlink at $config_file with a mutable file"
            run rm "$config_file"
            ;;
          *)
            verboseEcho "Leaving user-managed OpenCode config symlink $config_file unchanged"
            return
            ;;
        esac
      fi

      if [ ! -e "$config_file" ]; then
        verboseEcho "Creating mutable OpenCode config $config_file"
        run mkdir -p "$config_dir"
        run install -m 0644 "$seed" "$config_file"
      else
        run ${pkgs.nodejs}/bin/node -e '
          const fs = require("fs");
          const [configPath, seedPath, pluginsPath] = process.argv.slice(1);
          const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
          const seed = JSON.parse(fs.readFileSync(seedPath, "utf8"));
          const desired = JSON.parse(fs.readFileSync(pluginsPath, "utf8"));
          const current = Array.isArray(config.plugin) ? config.plugin : [];
          const nameOf = (entry) => (Array.isArray(entry) ? entry[0] : entry);
          const present = new Set(current.map(nameOf));
          const currentMcp = config.mcp ?? {};
          const desiredMcp = seed.mcp ?? {};

          config.plugin = [...current, ...desired.filter((entry) => !present.has(nameOf(entry)))];
          config.mcp = {...desiredMcp, ...currentMcp};
          for (const [name, server] of Object.entries(desiredMcp)) {
            if (server.type === "local" && currentMcp[name]?.type == null) {
              config.mcp[name] = server;
            }
          }
          fs.writeFileSync(configPath, JSON.stringify(config, null, 2) + "\n");
        ' "$config_file" "$seed" "$plugins"
      fi
    }

    ${lib.concatMapStrings ensureCall mutableConfigs}
  '';
}
