# Managed Zen Browser

Both hosts use the community Zen flake's **beta** release, pinned in `flake.lock`.
The browser input follows `nixpkgs-unstable`; the OS and Home Manager stay on
their existing stable inputs. Readwise and Obsidian come from the already-pinned
Firefox-addons input. Readwise uses the host's existing `allowUnfree` policy.

## Updates and build-only validation

From the repository root, review existing lockfile edits before updating:

```sh
nix flake update zen-browser
nix eval --raw --no-update-lock-file .#darwinConfigurations.macbook.system.drvPath
nix eval --raw --no-update-lock-file .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix flake check --no-update-lock-file
nix build --no-link --no-update-lock-file .#darwinConfigurations.macbook.system
# On a Linux machine/builder:
nix build --no-link --no-update-lock-file .#nixosConfigurations.nixos.config.system.build.toplevel
```

Compare the locked beta version against the [official latest release](https://github.com/zen-browser/desktop/releases/latest).
Review only Zen-related lock changes; do not bundle unrelated pending updates.
Community release metadata can lag. These commands do not activate a generation.

## Before activation

Back up existing browser configuration/profile directories. The read-only
preflight refuses an unmanaged `profiles.ini` or a populated target profile
without a Home Manager-owned `user.js`. **Stop and reconcile ownership explicitly**
if blocked; do not delete a profile or its private data to bypass the guard.
The managed profile remains `default` across generations:

- Linux: `~/.config/zen/default`.
- macOS: `~/Library/Application Support/Zen/Profiles/default`.

Existing unmanaged profiles are not imported. Arc, its Dock entry, and PDF
defaults are untouched. Only the declared preferences/extensions are managed.

## macOS integration and manual acceptance

Home Manager 26.05's Firefox final-package adapter expects a wrapper interface.
The small Darwin compatibility adapter instead returns the unchanged signed
app and rejects wrapper-only features. Policies go through the `app.zen-browser.zen`
defaults domain, not a modified application bundle. Keep this adapter until the
pinned Home Manager can handle the signed package directly; do not upgrade all
of Home Manager just to remove it.

On a later, approved activation, Home Manager links the app at
`~/Applications/Home Manager Apps/Zen Browser (Beta).app`, verifies its bundle ID,
registers that stable path and uses `duti` for **only** HTTP, HTTPS, HTML and XHTML.
Dry runs do not register the app or change defaults. If macOS refuses the change,
confirm Zen in **System Settings > Desktop & Dock > Default web browser** and
use **Finder > Get Info > Open with > Change All** for HTML/XHTML as needed.
`duti` command semantics: https://github.com/moretension/duti/blob/master/duti.1

After approved rollout, verify actual OS-launched HTTPS and local HTML/XHTML
files reach Zen (not just a direct Zen launch). Inspect HTML handlers with
`duti -d public.html` / `duti -d public.xhtml`. Confirm version, profile persistence
through two rebuilds, existing extensions/theme and 1Password native integration.
Signature verification alone does not prove 1Password is connected. With the
user present, save a chosen non-sensitive page to Readwise Reader and clip one
to their intended Obsidian vault. No credentials or extension-private data belong
in Nix configuration.

Roll out Mac first, then Linux after its real build passes. Roll back the system/
Home Manager generation and **only** this feature's input/module changes if
needed. Re-select the previous browser in OS settings: generation rollback does
not automatically reverse LaunchServices defaults. Restore profile backups only
after checking for new data and obtaining user approval; never reset all handlers.
