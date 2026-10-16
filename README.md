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

Validate before activation when changing host configuration:

```sh
nix flake check
nix build --no-link .#nixosConfigurations.nixos.config.system.build.toplevel
nix eval .#darwinConfigurations.macbook.system.drvPath
```

Run the Darwin evaluation or build on the Mac. `nix.enable = false` is
intentional there: Determinate Nix (3.17.1, bundling Nix 2.33.3) continues to
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
