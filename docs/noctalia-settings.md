# Noctalia settings

This setup is intentionally hybrid: Home Manager provides a declarative baseline, while Noctalia still writes settings changed through its UI to mutable state.

## What Nix owns

The Home Manager module is `modules/home/noctalia.nix`.

It enables `programs.noctalia`, uses the Noctalia flake package, and points the declarative baseline at:

```text
modules/home/noctalia-settings.toml
```

Home Manager also owns `~/.config/noctalia/config.toml`. That file is a symlink into the Nix store, so do not edit it directly.

## What Noctalia owns at runtime

Noctalia UI changes are written to:

```text
~/.local/state/noctalia/settings.toml
```

Other files under `~/.local/state/noctalia/` are runtime state such as notification history, recently used items, plugin state, and usage counters. They are not treated as repo source of truth.

## Activation behavior

The Home Manager activation step copies the repo baseline into Noctalia's runtime settings file:

```text
modules/home/noctalia-settings.toml
  -> ~/.local/state/noctalia/settings.toml
```

That means a rebuild or Home Manager activation can overwrite UI changes that have not been copied back into the repo.

## Persisting UI changes

After changing settings through the Noctalia UI, persist them back into the repo before rebuilding:

```bash
persist-noctalia-settings modules/home/noctalia-settings.toml
```

Then review the diff:

```bash
git diff -- modules/home/noctalia-settings.toml
```

If the diff looks right, rebuild or switch as usual. Run the persist command before `fu` or `nh os switch` when you want to keep UI changes.

## Resetting to the repo baseline

To discard UI-only changes, rebuild or activate Home Manager with the current repo baseline. The activation step will copy `modules/home/noctalia-settings.toml` back to `~/.local/state/noctalia/settings.toml`.
