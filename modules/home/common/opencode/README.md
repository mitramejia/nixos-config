# Mutable OpenCode V2 configuration

Home Manager reconciles global `opencode.json` and `cli.json`; it does not create
project CLI settings. The internal `private.openCodeMutableConfigPlatform.tui`
alias now supplies CLI defaults, including Darwin's Ctrl+X leader.

The reconciler converts singular V1 `plugin` arrays and `[package, options]`
tuples to V2 `plugins` entries. It retains user settings, plugin options and MCP
overrides, upgrades legacy VimCode git pins to v0.19.1, and preserves disable
directives. Existing CLI keybindings win over migrated `tui.json` keybindings;
the pinned upstream command map supplies V1-to-V2 names. File-backed theme,
mouse, cursor, attention, leader timing, scroll and stacked-diff preferences
are migrated without overwriting CLI preferences. `tui.json` is left as a
migration backup; `state/kv.json` is not migrated by this reconciler.
Other legacy server settings remain intact for upstream's
V1 compatibility normalizer. User-managed symlinks are never rewritten;
previous Nix-store links are replaced with mutable files, retaining their data.

The Bun resolution patch is intentionally gated to the two verified OpenCode
commits `d21b0790a6c146815f28fea604e41e922f009590` and
`23e3493ab2efb6b8c00725cfd652b7f946af5343`. It normalizes only Bun's exact
missing-module/package `ResolveMessage` diagnostic into the missing-module
Error that `Host.resolve` already handles. It does not catch plugin evaluation
errors or unrelated resolver errors. The existing Darwin dependency hash
correction remains separate and unchanged. The latter revision has its own
verified Darwin dependency-hash correction and a build-only restoration of
the pinned `script/native-arch.ts` omitted from upstream's filtered source.

## Local V2 plugins

Home Manager supplies the three focused ports under `plugins/`:

- `rtk.ts`: registers `ctx.tool.hook("execute.before")` and delegates shell
  command rewriting to RTK >= 0.23. It accepts rewrite exit codes 0 and 3
  (ask + rewrite), without bypassing OpenCode permission evaluation. Missing
  RTK, no-match, deny, timeout and other failures leave the command unchanged.
- `browserstack-env.ts`: registers a replayable `ctx.mcp.transform` that sets
  only BrowserStack's `disabled` flag when either process credential is absent.
  Both credentials leave the server's existing settings untouched.
- `herdr-agent-state/tui.ts`: a terminal-local CLI plugin, not a server plugin.
  It captures that terminal's Herdr socket/pane environment, observes the selected
  route and its root-session family, and uses V2 `event.data` execution,
  permission and form events. Child requests project blocked/working state onto
  the root; unrelated roots cannot report to the pane. Cleanup unsubscribes,
  unregisters the app observer and destroys in-flight sockets.

Do not reinstall Herdr's V1 integration as a fix. Herdr v0.8.0 owns
`plugins/herdr-agent-state.js` and may recreate it on integration reinstall.
The V2 directory is separately owned by nix-config and is not overwritten by
that installer. Archive any regenerated V1 file outside plugin discovery; do
not run both integrations. The authorized live port archived the original V1
file in its timestamped backup before removing it from discovery.

No plugin SDK dependency is installed into the user's config. OpenCode resolves
`@opencode/plugin` and `/tui` at runtime. The unrelated V1 image plugin and its
`@opencode-ai/plugin` dependency are intentionally left untouched.

## Checks (no activation)

```sh
nix build --no-link --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.private.openCodeMutableConfigCheck'
# Available on the patched, pinned package only:
nix build --no-link --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.programs.opencode.package.loaderCheck'
nix build --no-link --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.programs.opencode.package.localPluginsCheck'
```

The loader check requires the TUI-only fixture to fail before patching, then
passes it, unrelated-error propagation tests, and upstream Host tests through
the real Bun resolver. No dependency install is needed for this check.

The local-plugin check uses the pinned public API types, real RTK subprocesses
and a fixture Unix socket, with mocked hook/transform/TUI registration hosts.
For real RTK/BrowserStack V2 setup and MCP transform acceptance, run:

```sh
node modules/home/common/opencode/plugins.acceptance.mjs /path/to/patched/opencode /path/to/temp-parent
```

This owns isolated `serve --stdio` child processes with fake credentials and
separate config/data/state. It never contacts or restarts a shared service.
It does not instantiate the TUI; the parent performed the separate pane checks
recorded below.

### Validation recorded 2026-10-13

- The parent reran headless acceptance, `loaderCheck`, `localPluginsCheck`,
  `openCodeMutableConfigCheck`, and `nix flake check` successfully. Regression
  coverage includes real RTK subprocesses, the pinned public API type check,
  root/child isolation and in-flight socket cleanup with a mocked TUI host.
- In a fresh Herdr pane using the patched current binary with `--standalone`,
  no plugin-failure indicator appeared. `/plugins` showed VimCode and
  `local.herdr-agent-state` active; `/vim` and `hello`, Escape, `dd` worked.
  Herdr received the root session and working-to-done transitions
  (`state_change_seq` 1592 to 1596), with full lifecycle-hook authority and
  screen detection skipped.
- Two real, read-only model shell turns (`git status --short` and `git status`)
  succeeded. Stored tool input retained the original pre-hook command, so these
  runs prove successful tool execution, **not** the rewritten command actually
  executed. RTK rewrite behavior remains directly proven by subprocess-backed
  regression tests.
- `/mcps` showed BrowserStack disabled without credentials. Statsig's remaining
  “Sign in required” state is an authentication issue, not a plugin failure.

Ordinary Git-backed flake evaluation requires the new implementation files to
be Git-visible; intent-to-add (`git add -N`) is sufficient during review and
does not stage their contents. Verify without activation:

```sh
nix eval --raw .#darwinConfigurations.macbook.config.home-manager.users.mitramejia.programs.opencode.package.outPath
nix flake check --no-update-lock-file
git diff --check
```

These checks do not replace the default `/etc/profiles` OpenCode, which still
runs 2.0.26, or change shared services. Linux builds and legacy `state/kv.json`
migration remain outside this validation.

## Apply only the reconciler (explicit approval required)

This changes live configuration without a system switch. Back up the files
first; do not execute it as part of a validation task.

```sh
reconciler=$(nix build --no-link --print-out-paths --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.private.openCodeMutableConfigCheck.reconciler')
intent=$(nix build --no-link --print-out-paths --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.private.openCodeMutableConfigCheck.intentFile')
"$reconciler/bin/opencode-reconcile-mutable-config" "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" "$intent"
```

This does not install the patched executable or deploy plugin sources. Those
are separate deployment steps; a full system switch is not required for a
backed-up, explicitly approved live plugin copy.
