{
  config,
  lib,
  inputs,
  pkgs,
  unstablePkgs,
  ...
}: let
  upstreamPackage = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
  # The locked 2.0.26+d21b079 Darwin bundle completed its frozen-lockfile install
  # and normalization, but its recursive hash differs from nix/hashes.json.
  # Correct only this dependency hash; future revisions use upstream hashes.
  dependencyCorrectedPackage =
    if
      pkgs.stdenv.hostPlatform.system
      == "aarch64-darwin"
      && inputs.opencode.rev == "d21b0790a6c146815f28fea604e41e922f009590"
      && upstreamPackage.version == "2.0.26+d21b079"
      && upstreamPackage.node_modules.outputHash == "sha256-h9An+psN04P9QRfFpkvZByJPdoRrOSJUQIzYu+WJGd0="
    then
      upstreamPackage.override {
        node_modules = upstreamPackage.node_modules.override {
          hash = "sha256-VEHXhC0A8Er0rVADKUOeE8LGQCV1HRPspYYO1WUX4Jc=";
        };
      }
    else if
      pkgs.stdenv.hostPlatform.system
      == "aarch64-darwin"
      && inputs.opencode.rev == "23e3493ab2efb6b8c00725cfd652b7f946af5343"
      && upstreamPackage.version == "2.0.28+23e3493"
      && upstreamPackage.node_modules.outputHash == "sha256-bD2PVCF1nx/+dKKWCd2qC+ka34pNzrA7HNv7U3L+em0="
    then
      # This revision also completed install/normalization with a different
      # Darwin hash. Recorded from the current package's fixed-output build.
      upstreamPackage.override {
        node_modules = upstreamPackage.node_modules.override {
          hash = "sha256-IPIH8NI/DWBWPS9mDPE1cDhVz8QwtSJcOd1u6lQ+wOg=";
        };
      }
    else upstreamPackage;
  # Remove this compatibility patch when moving beyond the verified release.
  opencodePackage =
    if
      builtins.elem inputs.opencode.rev [
        "d21b0790a6c146815f28fea604e41e922f009590"
        "23e3493ab2efb6b8c00725cfd652b7f946af5343"
      ]
    then
      dependencyCorrectedPackage.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./opencode/bun-resolve.patch];
        # 23e3493's filtered src omits this newly imported build helper.
        postPatch =
          (old.postPatch or "")
          + lib.optionalString (inputs.opencode.rev == "23e3493ab2efb6b8c00725cfd652b7f946af5343") ''
            mkdir -p script
            cp ${inputs.opencode}/script/native-arch.ts script/native-arch.ts
          '';
        passthru = (old.passthru or {}) // {inherit loaderCheck localPluginsCheck;};
      })
    else dependencyCorrectedPackage;
  loaderCheck =
    pkgs.runCommand "opencode-bun-resolver" {
      nativeBuildInputs = [inputs.opencode.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.bun pkgs.patch];
    } ''
      cp -R ${inputs.opencode}/packages ./packages
      chmod -R u+w packages
      mkdir -p node_modules/@opencode
      ln -s ../../packages/util node_modules/@opencode/util
      cp ${./opencode/loader.test.ts} loader.test.ts
      if bun test loader.test.ts > red.log 2>&1; then
        cat red.log
        echo "Expected the unpatched TUI-only resolver regression to fail"
        exit 1
      fi
      cat red.log
      patch -p1 < ${./opencode/bun-resolve.patch}
      bun test loader.test.ts
      bun test packages/plugin/test/host.test.ts
      mkdir "$out"
      cp red.log "$out/"
    '';
  localPluginsCheck =
    pkgs.runCommand "opencode-local-plugins" {
      nativeBuildInputs = [inputs.opencode.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.bun unstablePkgs.rtk];
    } ''
          cp -R ${./opencode/plugins} plugins
          cp ${./opencode/plugins.test.ts} plugins.test.ts
        bun test plugins.test.ts
        mkdir upstream
        cp -R ${inputs.opencode}/packages upstream/packages
        chmod -R u+w upstream/packages
        cp -R ${dependencyCorrectedPackage.node_modules}/. upstream/
        cp -R ${./opencode/plugins} upstream/packages/plugin/check-plugins
        cp ${pkgs.writeText "opencode-local-plugin-tsconfig.json" (builtins.toJSON {
        compilerOptions = {
          target = "ESNext";
          module = "ESNext";
          moduleResolution = "Bundler";
          customConditions = ["bun"];
          types = ["bun"];
          strict = true;
          skipLibCheck = true;
          noEmit = true;
        };
        include = ["check-plugins/**/*.ts"];
      })} upstream/packages/plugin/check-tsconfig.json
      bun upstream/node_modules/.bun/typescript@5.8.2/node_modules/typescript/bin/tsc -p upstream/packages/plugin/check-tsconfig.json
          mkdir "$out"
    '';
  json = pkgs.formats.json {};
  mcpServers = (import ./opencode-mcp-servers.nix {inherit lib;}).opencode;
  tuiPlugins = ["vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.1"];
  platform = config.private.openCodeMutableConfigPlatform;
  mutableConfigIntent = [
    {
      name = "opencode.json";
      plugins = platform.opencode.plugins;
      seed =
        {
          "$schema" = "https://opencode.ai/config.json";
          plugins = platform.opencode.plugins;
          mcp = mcpServers;
        }
        // {
          permission."*" = "allow";
        }
        // platform.opencode.seed;
    }
    {
      name = "cli.json";
      plugins = tuiPlugins ++ platform.tui.plugins;
      removePlugins = ["@leohenon/opencode-vim-plugin"];
      replacePluginPrefixes = ["vimcode@git+https://github.com/oribarilan/vimcode.git"];
      seed =
        {
          "$schema" = "https://opencode.ai/v2/cli.json";
          plugins = tuiPlugins ++ platform.tui.plugins;
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
    // Reuse the pinned release's exact V1 command names, not guessed renames.
    const keybindSource = fs.readFileSync("${inputs.opencode}/packages/tui/src/config/v1/keybind.ts", "utf8");
    const commandMap = Object.fromEntries([...keybindSource.split("export const CommandMap = {")[1].split("} satisfies")[0].matchAll(/(\w+): "([^"]+)"/g)].map((match) => [match[1], match[2]]));
    const normalize = (plugin) => Array.isArray(plugin) && typeof plugin[0] === "string" && plugin.length === 2
      ? {package: plugin[0], options: plugin[1]} : plugin;
    const nameOf = (plugin) => typeof plugin === "string" ? plugin : plugin?.package;
    const appendAbsent = (current, plugins) => {
      const present = new Set(current.map((plugin) => nameOf(plugin)?.replace(/^-/, "")));
      for (const plugin of plugins) {
        const name = nameOf(plugin)?.replace(/^-/, "");
        if (name === undefined || !present.has(name)) current.push(plugin);
      }
    };
    const pluginsOf = (config) => {
      const current = (Array.isArray(config.plugins) ? config.plugins : []).map(normalize);
      appendAbsent(current, (Array.isArray(config.plugin) ? config.plugin : []).map(normalize));
      return current;
    };

    for (const entry of intent) {
      const configPath = path.join(configDir, entry.name);
      let stats;
      let previous;
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
        if (fs.existsSync(configPath)) previous = JSON.parse(fs.readFileSync(configPath, "utf8"));
        fs.unlinkSync(configPath);
        stats = undefined;
      }

      const config = stats ? JSON.parse(fs.readFileSync(configPath, "utf8")) : previous ?? {...entry.seed};
      let current = stats || previous ? pluginsOf(config) : [];
      if (entry.name === "cli.json") {
        const legacyPath = path.join(configDir, "tui.json");
        if (fs.existsSync(legacyPath)) {
          const legacy = JSON.parse(fs.readFileSync(legacyPath, "utf8"));
          appendAbsent(current, [...pluginsOf(legacy), ...Object.entries(legacy.plugin_enabled ?? {}).map(([name, enabled]) => enabled ? name : "-" + name)]);
          // These are the file-backed preferences in upstream migrateV1;
          // state/kv.json remains owned by OpenCode, not Home Manager.
          const preferences = {
            ...Object.fromEntries(["mouse", "cursor", "attention"].filter((name) => name in legacy).map((name) => [name, legacy[name]])),
            ...(legacy.theme === undefined ? {} : {theme: typeof legacy.theme === "string" ? {name: legacy.theme} : legacy.theme}),
            ...(legacy.leader_timeout === undefined ? {} : {leader: {timeout: legacy.leader_timeout}}),
            ...(legacy.scroll_speed === undefined && legacy.scroll_acceleration?.enabled === undefined ? {} : {scroll: {
              ...(legacy.scroll_speed === undefined ? {} : {speed: legacy.scroll_speed}),
              ...(legacy.scroll_acceleration?.enabled === undefined ? {} : {acceleration: legacy.scroll_acceleration.enabled})
            }}),
            ...(legacy.diff_style !== "stacked" ? {} : {diffs: {view: "unified"}})
          };
          for (const [name, value] of Object.entries(preferences)) {
            if (config[name] === undefined) config[name] = value;
            else if (value && typeof value === "object" && !Array.isArray(value)) config[name] = {...value, ...config[name]};
          }
          const keybinds = Object.fromEntries(Object.entries(legacy.keybinds ?? {}).map(([name, value]) => [commandMap[name] ?? name, value]));
          config.keybinds = {...entry.seed.keybinds, ...keybinds, ...(stats || previous ? config.keybinds : {})};
          // Keep the legacy file untouched as a backup; CLI preferences win.
        }
      }
      config.$schema = entry.seed.$schema;
      delete config.plugin;
      const removed = new Set(entry.removePlugins ?? []);
      const replacedPrefixes = entry.replacePluginPrefixes ?? [];
      const isReplaced = (plugin) => replacedPrefixes.some((prefix) => nameOf(plugin)?.replace(/^-/, "").startsWith(prefix));
      const currentMcp = config.mcp ?? {};
      const desiredMcp = entry.seed.mcp ?? {};

      const present = new Set();
      const retained = current.map((plugin) => {
        if (!isReplaced(plugin)) return plugin;
        const replacement = entry.plugins.find((desired) => replacedPrefixes.some((prefix) => nameOf(desired).startsWith(prefix)));
        if (!replacement) return plugin;
        const name = (nameOf(plugin).startsWith("-") ? "-" : "") + nameOf(replacement);
        return typeof plugin === "string" ? name : {...plugin, package: name};
      }).filter((plugin) => {
        const name = nameOf(plugin);
        if (removed.has(name?.replace(/^-/, ""))) return false;
        if (name === undefined) return true;
        // Collapse superseded VimCode pins only, not arbitrary user entries.
        if (isReplaced(plugin) && present.has(name.replace(/^-/, ""))) return false;
        present.add(name.replace(/^-/, ""));
        return true;
      });
      config.plugins = [...retained, ...entry.plugins.filter((plugin) => !present.has(nameOf(plugin)))];
      if (entry.seed.mcp) config.mcp = {...desiredMcp, ...currentMcp};
      for (const [name, server] of Object.entries(desiredMcp)) {
        if (server.type === "local" && currentMcp[name]?.type == null) {
          config.mcp[name] = {...server, ...currentMcp[name]};
        }
      }
      fs.mkdirSync(configDir, {recursive: true});
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
      passthru = {
        reconciler = mutableConfigReconciler;
        intentFile = mutableConfigIntentFile;
      };
    } ''
      fixture="$PWD/fixture"
      mkdir "$fixture"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      node -e '
        const assert = require("assert");
        const fs = require("fs");
        const intent = JSON.parse(fs.readFileSync("${mutableConfigIntentFile}"));
        const opencode = JSON.parse(fs.readFileSync("fixture/opencode.json"));
         const tui = JSON.parse(fs.readFileSync("fixture/cli.json"));
        assert.deepEqual(opencode, intent[0].seed);
        assert.deepEqual(tui, intent[1].seed);
      '
      node -e '
        const fs = require("fs");
        fs.writeFileSync("fixture/opencode.json", JSON.stringify({
          model: "user-model",
          permission: {"*": "ask"},
           plugins: [{package: "object-plugin@1", options: {keep: true}}],
           plugin: [["user-plugin@1", {keep: "tuple"}]],
          mcp: {
            github: {type: "remote", url: "https://user.example/mcp"},
            "sequential-thinking": {command: ["user-command"]},
            "user-server": {type: "remote", url: "https://user.example"}
          }
        }));
         fs.writeFileSync("fixture/cli.json", JSON.stringify({
           keybinds: {leader: "comma", "session.new": "ctrl+n"},
           terminal: {copy: "manual"},
           scroll: {speed: 7},
           plugin: [["cli-tuple@1", {keep: true}]],
           plugins: [{package: "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3", options: {keep: "vimcode"}}]
         }));
         fs.writeFileSync("fixture/tui.json", JSON.stringify({
           keybinds: {leader: "space", session_new: "ctrl+t", input_move_left: "ctrl+h"},
           theme: "user-theme",
           mouse: false,
           leader_timeout: 1234,
           scroll_speed: 2,
           scroll_acceleration: {enabled: true},
           diff_style: "stacked",
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
         const tui = JSON.parse(fs.readFileSync("fixture/cli.json"));
        assert.equal(opencode.model, "user-model");
        assert.deepEqual(opencode.permission, {"*": "ask"});
         assert.deepEqual(opencode.plugins.find((p) => p.package === "user-plugin@1"), {package: "user-plugin@1", options: {keep: "tuple"}});
         assert.deepEqual(opencode.plugins.find((p) => p.package === "object-plugin@1"), {package: "object-plugin@1", options: {keep: true}});
         assert(!("plugin" in opencode));
         for (const plugin of intent[0].plugins) assert(opencode.plugins.includes(plugin));
        assert.equal(opencode.mcp.github.url, "https://user.example/mcp");
        assert.deepEqual(opencode.mcp["user-server"], {type: "remote", url: "https://user.example"});
         assert.deepEqual(opencode.mcp["sequential-thinking"], {...intent[0].seed.mcp["sequential-thinking"], command: ["user-command"]});
        assert.deepEqual(opencode.mcp.figma, intent[0].seed.mcp.figma);
         assert.equal(tui.keybinds.leader, "comma");
         assert.equal(tui.keybinds["session.new"], "ctrl+n");
         assert.equal(tui.keybinds["input.move.left"], "ctrl+h");
         assert.deepEqual(tui.terminal, {copy: "manual"});
         assert.deepEqual(tui.theme, {name: "user-theme"});
         assert.equal(tui.mouse, false);
         assert.deepEqual(tui.leader, {timeout: 1234});
         assert.deepEqual(tui.scroll, {speed: 7, acceleration: true});
         assert.deepEqual(tui.diffs, {view: "unified"});
         assert.deepEqual(tui.plugins.find((p) => p.package === "cli-tuple@1"), {package: "cli-tuple@1", options: {keep: true}});
         assert(!("plugin" in tui));
         assert(tui.plugins.includes("user-plugin@1"));
         assert(!tui.plugins.includes("@leohenon/opencode-vim-plugin"));
         assert.deepEqual(tui.plugins.filter((plugin) => (plugin.package ?? plugin).startsWith("vimcode@git+https://github.com/oribarilan/vimcode.git")), [{package: "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.1", options: {keep: "vimcode"}}]);
       '
      cp "$fixture/cli.json" before-cli.json
      cp "$fixture/opencode.json" before-opencode.json
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      cmp before-cli.json "$fixture/cli.json"
      cmp before-opencode.json "$fixture/opencode.json"
      mkdir "$fixture/disabled"
      node -e '
        const fs = require("fs");
        fs.writeFileSync("fixture/disabled/cli.json", JSON.stringify({
          plugins: ["-vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3", {package: "local-plugin", options: {enabled: false}}],
          mouse: false
        }));
      '
      ${lib.getExe mutableConfigReconciler} "$fixture/disabled" ${mutableConfigIntentFile}
      node -e '
        const assert = require("assert");
        const cli = require("./fixture/disabled/cli.json");
        assert.deepEqual(cli.plugins, ["-vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.1", {package: "local-plugin", options: {enabled: false}}]);
        assert.equal(cli.mouse, false);
      '
      rm "$fixture/cli.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      node -e 'const c = require("./fixture/cli.json"); require("assert").equal(c.keybinds["session.new"], "ctrl+t");'
      rm "$fixture/cli.json"
      ln -s ${json.generate "opencode-home-manager-cli" (builtins.elemAt mutableConfigIntent 1).seed} "$fixture/cli.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      test ! -L "$fixture/cli.json"
      rm "$fixture/opencode.json"
      printf '%s\n' '{"user":"symlink"}' > "$fixture/user-opencode.json"
      ln -s "$fixture/user-opencode.json" "$fixture/opencode.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      test -L "$fixture/opencode.json"
      test "$(cat "$fixture/user-opencode.json")" = '{"user":"symlink"}'
      rm "$fixture/cli.json"
      printf '%s\n' '{"plugins":["user-cli"],"keybinds":{"leader":"ctrl+x"}}' > "$fixture/user-cli.json"
      ln -s "$fixture/user-cli.json" "$fixture/cli.json"
      ${lib.getExe mutableConfigReconciler} "$fixture" ${mutableConfigIntentFile}
      test -L "$fixture/cli.json"
      test "$(cat "$fixture/user-cli.json")" = '{"plugins":["user-cli"],"keybinds":{"leader":"ctrl+x"}}'
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
        description = "Platform CLI plugins to reconcile (legacy private.tui alias).";
      };
      seed = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        internal = true;
        description = "Platform CLI seed additions (legacy private.tui alias).";
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
          && !(builtins.hasAttr "opencode/cli.json" config.xdg.configFile)
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

    # Track upstream OpenCode because nixpkgs updates can lag its rapid releases.
    programs.opencode = {
      enable = true;
      package = opencodePackage;
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
        "agents/appium-test-engineer.md" = ./opencode/agents/appium-test-engineer.md;
        "commands/mobile-implement.md" = ./opencode/commands/mobile-implement.md;
        "commands/mobile-plan.md" = ./opencode/commands/mobile-plan.md;
        "commands/mobile-review.md" = ./opencode/commands/mobile-review.md;
        "commands/mobile-check.md" = ./opencode/commands/mobile-check.md;
        "commands/mobile-test.md" = ./opencode/commands/mobile-test.md;
        "commands/mobile-release-audit.md" = ./opencode/commands/mobile-release-audit.md;
        "plugins/rtk.ts" = ./opencode/plugins/rtk.ts;
        "plugins/browserstack-env.ts" = ./opencode/plugins/browserstack-env.ts;
        "plugins/herdr-agent-state/tui.ts" = ./opencode/plugins/herdr-agent-state/tui.ts;
      };

    # OpenCode rewrites both files at runtime: Headroom edits opencode.json, and
    # the vim mode toggle persists to V2 cli.json. This reconciler is their sole
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
