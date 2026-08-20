{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}: let
  json = pkgs.formats.json {};
  mcpServers = (import ./opencode-mcp-servers.nix {inherit lib;}).opencode;
  tuiPlugins = ["vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3"];
  platform = config.private.openCodeMutableConfigPlatform;
  mutableConfigIntent = [
    {
      name = "opencode.json";
      plugins = platform.opencode.plugins;
      seed =
        {
          "$schema" = "https://opencode.ai/config.json";
          mcp = mcpServers;
        }
        // {
          permission."*" = "allow";
        }
        // platform.opencode.seed;
    }
    {
      name = "tui.json";
      plugins = tuiPlugins ++ platform.tui.plugins;
      removePlugins = ["@leohenon/opencode-vim-plugin"];
      replacePluginPrefixes = ["vimcode@git+https://github.com/oribarilan/vimcode.git"];
      seed =
        {
          plugin = tuiPlugins ++ platform.tui.plugins;
        }
        // platform.tui.seed;
    }
  ];
  reconcileMutableConfig = pkgs.writeText "opencode-reconcile-mutable-config.js" ''
    const fs = require("fs");
    const path = require("path");
    const [configDir, intentPath] = process.argv.slice(2);
    const intent = JSON.parse(fs.readFileSync(intentPath, "utf8"));
    const write = (configPath, value) => fs.writeFileSync(configPath, JSON.stringify(value, null, 2) + "\n", {mode: 0o644});

    for (const entry of intent) {
      const configPath = path.join(configDir, entry.name);
      let stats;
      try {
        stats = fs.lstatSync(configPath);
      } catch (error) {
        if (error.code !== "ENOENT") throw error;
      }

      if (stats?.isSymbolicLink()) {
        const target = path.resolve(path.dirname(configPath), fs.readlinkSync(configPath));
        if (!target.startsWith("/nix/store/")) {
          console.error("Leaving user-managed OpenCode config symlink " + configPath + " unchanged");
          continue;
        }
        console.error("Replacing previous Home Manager symlink at " + configPath + " with a mutable file");
        fs.unlinkSync(configPath);
        stats = undefined;
      }

      if (!stats) {
        console.error("Creating mutable OpenCode config " + configPath);
        fs.mkdirSync(configDir, {recursive: true});
        write(configPath, entry.seed);
        continue;
      }

      const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
      const current = Array.isArray(config.plugin) ? config.plugin : [];
      const removed = new Set(entry.removePlugins ?? []);
      const replacedPrefixes = entry.replacePluginPrefixes ?? [];
      const nameOf = (plugin) => (Array.isArray(plugin) ? plugin[0] : plugin);
      const isReplaced = (plugin) => replacedPrefixes.some((prefix) => nameOf(plugin).startsWith(prefix));
      const currentMcp = config.mcp ?? {};
      const desiredMcp = entry.seed.mcp ?? {};

      if (entry.plugins.length || removed.size || replacedPrefixes.length) {
        const retained = current.filter((plugin) => !removed.has(nameOf(plugin)) && !isReplaced(plugin));
        const present = new Set(retained.map(nameOf));
        config.plugin = [...retained, ...entry.plugins.filter((plugin) => !present.has(nameOf(plugin)))];
      }
      config.mcp = {...desiredMcp, ...currentMcp};
      for (const [name, server] of Object.entries(desiredMcp)) {
        if (server.type === "local" && currentMcp[name]?.type == null) {
          config.mcp[name] = server;
        }
      }
      write(configPath, config);
    }
  '';
  mutableConfigReconciler = pkgs.writeShellApplication {
    name = "opencode-reconcile-mutable-config";
    runtimeInputs = [pkgs.nodejs];
    text = ''
      exec node ${reconcileMutableConfig} "$@"
    '';
  };
  mutableConfigIntentFile = json.generate "opencode-mutable-config-intent.json" mutableConfigIntent;
  mutableConfigCheck =
    pkgs.runCommand "opencode-mutable-config" {
      nativeBuildInputs = [pkgs.nodejs pkgs.coreutils];
    } ''
      fixture="$PWD/fixture"
      mkdir "$fixture"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      node -e '
        const assert = require("assert");
        const fs = require("fs");
        const intent = JSON.parse(fs.readFileSync("${mutableConfigIntentFile}"));
        const opencode = JSON.parse(fs.readFileSync("fixture/opencode.json"));
        const tui = JSON.parse(fs.readFileSync("fixture/tui.json"));
        assert.deepEqual(opencode, intent[0].seed);
        assert.deepEqual(tui, intent[1].seed);
      '
      node -e '
        const fs = require("fs");
        fs.writeFileSync("fixture/opencode.json", JSON.stringify({
          model: "user-model",
          permission: {"*": "ask"},
          plugin: ["user-plugin@1"],
          mcp: {
            github: {type: "remote", url: "https://user.example/mcp"},
            "sequential-thinking": {command: ["user-command"]},
            "user-server": {type: "remote", url: "https://user.example"}
          }
        }));
        fs.writeFileSync("fixture/tui.json", JSON.stringify({
          keybinds: {leader: "comma"},
          plugin: [
            "@leohenon/opencode-vim-plugin",
            "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.1",
            "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.14.0",
            "user-plugin@1"
          ]
        }));
      '
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      node -e '
        const assert = require("assert");
        const fs = require("fs");
        const intent = JSON.parse(fs.readFileSync("${mutableConfigIntentFile}"));
        const opencode = JSON.parse(fs.readFileSync("fixture/opencode.json"));
        const tui = JSON.parse(fs.readFileSync("fixture/tui.json"));
        assert.equal(opencode.model, "user-model");
        assert.deepEqual(opencode.permission, {"*": "ask"});
        assert(opencode.plugin.includes("user-plugin@1"));
        for (const plugin of intent[0].plugins) assert(opencode.plugin.includes(plugin));
        assert.equal(opencode.mcp.github.url, "https://user.example/mcp");
        assert.deepEqual(opencode.mcp["user-server"], {type: "remote", url: "https://user.example"});
        assert.deepEqual(opencode.mcp["sequential-thinking"], intent[0].seed.mcp["sequential-thinking"]);
        assert.deepEqual(opencode.mcp.figma, intent[0].seed.mcp.figma);
        assert.equal(tui.keybinds.leader, "comma");
        assert(tui.plugin.includes("user-plugin@1"));
        assert(!tui.plugin.includes("@leohenon/opencode-vim-plugin"));
        assert.deepEqual(tui.plugin.filter((plugin) => plugin.startsWith("vimcode@git+https://github.com/oribarilan/vimcode.git")), ["vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3"]);
      '
      rm "$fixture/tui.json"
      ln -s ${json.generate "opencode-home-manager-tui" (builtins.elemAt mutableConfigIntent 1).seed} "$fixture/tui.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      test ! -L "$fixture/tui.json"
      rm "$fixture/opencode.json"
      printf '%s\n' '{"user":"symlink"}' > "$fixture/user-opencode.json"
      ln -s "$fixture/user-opencode.json" "$fixture/opencode.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      test -L "$fixture/opencode.json"
      test "$(cat "$fixture/user-opencode.json")" = '{"user":"symlink"}'
      mkdir -p "$out"
    '';
in {
  options.private.openCodeMcpServers = lib.mkOption {
    type = lib.types.attrs;
    internal = true;
    readOnly = true;
    description = "OpenCode MCP servers rendered from the shared catalog.";
  };

  options.private.openCodeMutableConfigPlatform = {
    opencode = {
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        internal = true;
        description = "Platform OpenCode plugins to reconcile.";
      };
      seed = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        internal = true;
        description = "Platform OpenCode seed additions.";
      };
    };
    tui = {
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        internal = true;
        description = "Platform TUI plugins to reconcile.";
      };
      seed = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        internal = true;
        description = "Platform TUI seed additions.";
      };
    };
  };

  options.private.openCodeMutableConfigCheck = lib.mkOption {
    type = lib.types.package;
    internal = true;
    description = "Focused OpenCode mutable configuration fixture check.";
  };

  options.private.openCodeMutableConfigIntent = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    internal = true;
    readOnly = true;
    description = "Shared mutable OpenCode configuration intent.";
  };

  config = {
    assertions = [
      {
        assertion =
          config.programs.opencode.settings
          == {}
          && config.programs.opencode.tui == {}
          && !(builtins.hasAttr "opencode/opencode.json" config.xdg.configFile)
          && !(builtins.hasAttr "opencode/tui.json" config.xdg.configFile)
          && builtins.hasAttr "ensureMutableOpenCodeConfig" config.home.activation;
        message = "The shared mutable OpenCode reconciler must be the sole configuration owner.";
      }
      {
        assertion =
          (builtins.elemAt mutableConfigIntent 0).seed.mcp
          == mcpServers
          && (builtins.elemAt mutableConfigIntent 1).plugins == tuiPlugins ++ platform.tui.plugins;
        message = "OpenCode must retain shared MCP settings and the VimCode plugin.";
      }
    ];

    # The opencode vim plugin requires opencode >= 1.17.10, which stable does
    # not provide yet, so this one program tracks the pinned unstable set.
    programs.opencode = {
      enable = true;
      package = unstablePkgs.opencode;
      enableMcpIntegration = true;
    };

    xdg.configFile =
      lib.mapAttrs' (name: source: lib.nameValuePair "opencode/${name}" {inherit source;})
      {
        "agents/pocock-planner.md" = ./opencode/agents/pocock-planner.md;
        "agents/pocock-worker.md" = ./opencode/agents/pocock-worker.md;
        "agents/pocock-scout.md" = ./opencode/agents/pocock-scout.md;
        "agents/pocock-triage.md" = ./opencode/agents/pocock-triage.md;
        "agents/mobile-reviewer.md" = ./opencode/agents/mobile-reviewer.md;
        "agents/mobile-release-safety.md" = ./opencode/agents/mobile-release-safety.md;
        "commands/mobile-implement.md" = ./opencode/commands/mobile-implement.md;
        "commands/mobile-plan.md" = ./opencode/commands/mobile-plan.md;
        "commands/mobile-review.md" = ./opencode/commands/mobile-review.md;
        "commands/mobile-check.md" = ./opencode/commands/mobile-check.md;
        "commands/mobile-test.md" = ./opencode/commands/mobile-test.md;
        "commands/mobile-release-audit.md" = ./opencode/commands/mobile-release-audit.md;
      };

    # OpenCode rewrites both files at runtime: Headroom edits opencode.json, and
    # the vim mode toggle persists to tui.json. This reconciler is their sole
    # writer: it seeds missing files, adds absent plugins and MCP servers, and
    # applies explicit plugin migrations while retaining user-managed state.
    home.activation.ensureMutableOpenCodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe mutableConfigReconciler} ${lib.escapeShellArg "${config.xdg.configHome}/opencode"} ${mutableConfigIntentFile}
    '';

    private.openCodeMutableConfigCheck = mutableConfigCheck;
    private.openCodeMutableConfigIntent = mutableConfigIntent;
    private.openCodeMcpServers = mcpServers;
  };
}
