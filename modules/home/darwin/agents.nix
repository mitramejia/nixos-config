{
  config,
  lib,
  pkgs,
  ...
}:
let
  json = pkgs.formats.json { };

  # vimcode is configured in tui.json, per its documentation, so that is the
  # only place Nix declares it.
  tuiPlugins = [
    "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3"
  ];

  opencodePlugins = [ "opencode-claude-auth@latest" ];

  opencodeMcpServers = import ../common/opencode-mcp-servers.nix {
    inherit config lib;
    androidHome = null;
  };

  # OpenCode rewrites both files at runtime: Headroom edits opencode.json, and
  # the vim mode toggle persists to tui.json. Nix seeds a missing file, then
  # only ever adds absent plugins and MCP servers, except for explicit plugin
  # migrations. It never reconciles options or reclaims ownership, so anything
  # edited or disabled by hand stays untouched.
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
      removePlugins = [ "@leohenon/opencode-vim-plugin" ];
      seed = {
        plugin = tuiPlugins;
        keybinds.leader = "space";
      };
    }
  ];

  ensureCall = entry: ''
    ensure_mutable_config ${lib.escapeShellArg entry.name} ${json.generate "opencode-seed-${entry.name}" entry.seed} ${json.generate "opencode-plugins-${entry.name}" entry.plugins} ${
      json.generate "opencode-removed-plugins-${entry.name}" (entry.removePlugins or [ ])
    }
  '';
in
{
  home.activation.ensureMutableOpenCodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="${config.xdg.configHome}/opencode"

    ensure_mutable_config() {
      local name="$1" seed="$2" plugins="$3" removed_plugins="$4"
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
          const [configPath, seedPath, pluginsPath, removedPluginsPath] = process.argv.slice(1);
          const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
          const seed = JSON.parse(fs.readFileSync(seedPath, "utf8"));
          const desired = JSON.parse(fs.readFileSync(pluginsPath, "utf8"));
          const removed = new Set(JSON.parse(fs.readFileSync(removedPluginsPath, "utf8")));
          const current = Array.isArray(config.plugin) ? config.plugin : [];
          const nameOf = (entry) => (Array.isArray(entry) ? entry[0] : entry);
          const retained = current.filter((entry) => !removed.has(nameOf(entry)));
          const present = new Set(retained.map(nameOf));
          const currentMcp = config.mcp ?? {};
          const desiredMcp = seed.mcp ?? {};

          config.plugin = [...retained, ...desired.filter((entry) => !present.has(nameOf(entry)))];
          config.mcp = {...desiredMcp, ...currentMcp};
          for (const [name, server] of Object.entries(desiredMcp)) {
            if (server.type === "local" && currentMcp[name]?.type == null) {
              config.mcp[name] = server;
            }
          }
          fs.writeFileSync(configPath, JSON.stringify(config, null, 2) + "\n");
        ' "$config_file" "$seed" "$plugins" "$removed_plugins"
      fi
    }

    ${lib.concatMapStrings ensureCall mutableConfigs}
  '';
}
