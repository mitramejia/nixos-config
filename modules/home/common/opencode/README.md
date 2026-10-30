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

The package retains reduced download concurrency for dependency installation.
Historical dependency hashes and the Bun resolution patch for older OpenCode
releases have been removed. Dependency hashes normally come from upstream;
the single current, narrowly gated Darwin correction is documented below.

Keep OpenCode's own locked nixpkgs input rather than forcing it to the system's
package set or a historical revision. For `13a615b`, upstream pins nixpkgs
`3181085bfd08663b6b9e60bc7a8395c2aaa741bd` (Bun 1.4.2). The former forced
`9dd5558` pin used Bun 1.3.13 and produced a different dependency tree despite
the frozen Bun lockfile. Restoring upstream's toolchain passes its original
dependency hash, including with the retained concurrency workaround; no hash
override is needed. A Home Manager assertion guards this relationship on both
hosts. When updating OpenCode, retain its upstream nixpkgs lock as well.

### Darwin dependency metadata mismatch at 0749024 (2026-10-26)

The locked `0749024f0d6f6bb3014850a820d06677b7c37120` source updates its Bun
lockfile, root package manifest and recorded dependency hashes. Its dependency
derivation and normalization scripts are unchanged from the previously passing
`13a615b` release. The upstream toolchain still matches: nixpkgs `3181085` / Bun 1.4.2.

- Recorded Darwin hash: `sha256-TO9ubp4SLWrzWJY1BgDKOy/S8Tcws+Z2k+I6ba/TkWk=`.
- Measured Darwin hash: `sha256-3EGfe+K2yM4atFT70JcwY66i/wFvHPO6/ewiIa2SB5Q=`.
- Two configured builds and a separate **unmodified upstream** build produced
  the same measured hash. Therefore the download-concurrency tweak is not the
  cause. The registered measured output has no absolute or broken symlinks.
- A subsequent `nix build --rebuild` of the corrected dependency passed Nix's
  full output comparison, providing a fresh reproducibility check, not a cache hit.

`dependency-hash.nix` corrects only that exact revision, package version,
upstream hash and `aarch64-darwin` platform. Both the installed package and local
plugin check use the same corrected dependency. Pure regression cases cover all
gates, including future revisions and Linux passthrough. No lockfile update,
toolchain change, resolver patch or global verification bypass is involved.
The reason upstream CI recorded a different hash is not established; do not
generalize this correction to another revision. Remove it when updating beyond
this release and validate the next upstream dependency hash independently.

Validated without activation: the original configured dependency installable,
its forced reproducibility rebuild, the OpenCode package, `localPluginsCheck`
(five tests / 83 assertions plus TypeScript), both full host derivation evaluations,
`nix flake check --no-update-lock-file`, and the full Darwin system build all pass.
An isolated HOME/XDG version smoke test reports `opencode v2.1.4+0749024`.
Linux's configured hash is unchanged from upstream; Linux was evaluated, not built.

Primary sources at the exact locked revision:
- https://github.com/anomalyco/opencode/blob/0749024f0d6f6bb3014850a820d06677b7c37120/nix/hashes.json
- https://github.com/anomalyco/opencode/blob/0749024f0d6f6bb3014850a820d06677b7c37120/nix/node_modules.nix

### Build-only validation recorded 2026-10-24

- The exact configured `package.node_modules` build now passes upstream's hash.
- The configured package and `package.localPluginsCheck` build successfully:
  five plugin tests, 83 assertions and the pinned workspace TypeScript check pass.
- The built binary reports `opencode v2.1.4+13a615b` with isolated HOME/XDG paths.
- Both host derivation evaluations and the full macOS system build pass without
  activation. A temporary old-toolchain override is rejected by the new guard.
- No running agent/service or live configuration was changed. Linux was evaluated,
  not built locally; runtime plugin acceptance is separate from these build checks.

## Agents and routing

Home Manager installs `planner` (primary), `scout`, `worker`, and `triage`
(subagents). `mobile-plan` selects `planner`; `mobile-implement`, `mobile-test`,
and `mobile-check` select `worker`. Planner defaults narrow codebase and external
metrics lookups to the read-only scout, uses triage for unclear requests, and
routes implementation to a bounded worker. PR and branch-diff reviews, comments,
and replies default to `pr-reviewer`; its OpenCode profile is rendered from the
shared Codex prompt in `../codex/agents/pr-reviewer.toml`, adapting only the skill
reference for OpenCode. Requested or complementary mobile-platform reviews and
release-risk audits remain with `mobile-reviewer` and `mobile-release-safety`.

Following the updated upstream `implement-spec` practice, each implementation
ticket and review-fix pass gets a fresh child context. Independent read-only
lookups can run in parallel; discovery-dependent queries stay sequential.

These are source changes, not a deployment. Home Manager activation installs the
new agent files and removes the old managed links. Existing sessions keep their
selected agent until it is reselected or a new session is started. To validate
before staging new files, use `path:.` flake references so evaluation includes
untracked sources.

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
nix build --no-link --impure --expr '(builtins.getFlake (toString ./.)).darwinConfigurations.macbook.config.home-manager.users.mitramejia.programs.opencode.package.localPluginsCheck'
```

The local-plugin check uses the pinned public API types, real RTK subprocesses
and a fixture Unix socket, with mocked hook/transform/TUI registration hosts.
For real RTK/BrowserStack V2 setup and MCP transform acceptance, run:

```sh
node modules/home/common/opencode/plugins.acceptance.mjs /path/to/opencode /path/to/temp-parent
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
