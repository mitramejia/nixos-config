# nix-config

One flake configures the two active machines. The former macOS repository at
`/home/mitra/WebstormProjects/macos-nix-config` is retained as an archive; its
snapshot at commit `5b255acfb221938ac7d86525cfc5ec1d2311183a` supplied the
Darwin configuration imported here.

| Configuration key | System | Hostname | User | System state | Home Manager state |
| --- | --- | --- | --- | --- | --- |
| `nixos` | `x86_64-linux` | `nixos` | `mitra` | `24.11` | `23.11` |
| `macbook` | `aarch64-darwin` | `MitraMacBook` | `mitramejia` | `Determinate Nix 3.17.1` | `23.11` |

The configuration key is how the flake and `nh` select a host. It is not
necessarily the machine hostname: use `macbook` for the Darwin configuration,
while macOS itself remains named `MitraMacBook`.

## Deploy

From the repository root, switch the matching local machine:

```sh
nh os switch . -H nixos
nh darwin switch . -H macbook
```

## Validate before activation

From the repository root, on either `x86_64-linux` or `aarch64-darwin`:

```sh
nix run --no-update-lock-file .#validate
```

The locked stable Nixpkgs supplies Alejandra, Bash, coreutils, findutils, and the wrapper's
Nix CLI (the initial `nix run` still uses your installed Nix). `formatter` exposes
the same Alejandra on both platforms. Validation checks all repository `.nix`
files without modifying them, excluding `.git`, `.scratch`, `.codegraph`,
`generated`, `vendor`, and `node_modules` directories. Directory symlinks (including
build result symlinks) are not followed. File enumeration failure aborts validation
before later checks. Pre-existing
formatting differences fail the check too; this is not an automatic reformat.
It explicitly evaluates both
`nixosConfigurations.nixos.config.system.build.toplevel.drvPath` and
`darwinConfigurations.macbook.system.drvPath`, then runs native `nix flake check`.
After successful enumeration, every check is attempted and any failure produces
a nonzero exit. Locks may not
be implicitly updated; no stage uses `--impure` or activates a configuration.

Evaluation is not a full host closure build or a boot/activation test. It can
fetch inputs or build import-from-derivation dependencies. Native checks build
only the current platform's check derivations; run validation on both machines
for both sets. Full closure builds, when needed, require compatible local or
remote builders and are separate from validation:

```sh
# Linux builder
nix build --no-link --no-update-lock-file .#nixosConfigurations.nixos.config.system.build.toplevel
# Darwin builder
nix build --no-link --no-update-lock-file .#darwinConfigurations.macbook.system
```

`nix.enable = false` is intentional on the Mac: Determinate Nix (3.17.1,
bundling Nix 2.33.3) continues to
own the Nix installation and daemon. Homebrew is declarative only for the
pinned taps and retained casks; activation cleanup is disabled.

## Cleanup and recovery (NixOS)

`ncg` removes user and sudo/root profile generations older than 15 days,
preserving each profile's current generation, then collects unreferenced store
paths. This is a retention window, not a guarantee of a previous generation:
an old non-current generation can be deleted even if it is your only rollback.
After both collections succeed, it runs the current system's
`switch-to-configuration boot` to synchronize boot entries without switching the
live session. `fu` still updates and prepares a boot-only deployment.

For recovery, reboot and select a retained older NixOS generation in the boot
menu. To make the previous system profile generation the next boot default,
the installed `nixos-rebuild` supports:

```sh
sudo nixos-rebuild boot --rollback
```

This changes the boot default, not the running session; reboot to use it.
Rollback needs a retained generation and does not restore mutable application
data. Git revert restores configuration source, **not** an installed generation;
validate and rebuild/deploy separately if recovering by reverting source.
