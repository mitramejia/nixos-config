# nix-config

One flake configures the two active machines. The former macOS repository at
`/home/mitra/WebstormProjects/macos-nix-config` is retained as an archive; its
snapshot at commit `5b255acfb221938ac7d86525cfc5ec1d2311183a` supplied the
Darwin configuration imported here.

| Configuration key | System | Hostname | User | System state | Home Manager state |
| --- | --- | --- | --- | --- | --- |
| `nixos` | `x86_64-linux` | `nixos` | `mitra` | `24.11` | `23.11` |
| `macbook` | `aarch64-darwin` | `MitraMacBook` | `mitramejia` | `4` | `23.11` |

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
intentional there: Determinate Nix continues to own the Nix installation and
daemon. Homebrew is declarative only for the pinned taps and retained casks;
activation cleanup is disabled.
