# Herdr desktop preferences

`default.nix` ports the supported TUI preferences to the desktop app: the
Catppuccin Mocha palette and Ctrl+Space sequences for settings, detach (close
the window, keeping terminals alive), new tab, splits, and pane navigation.
Ctrl+Space then `:` opens the command palette. Desktop defaults remain available.

The TUI's plugins, context-aware Ctrl+h/j/k/l navigation, copy/resize modes,
scrollback byte limit, agent resume, mouse/copy options and tab-bar placement
are not translated: the desktop app does not expose equivalent preferences.
Shell selection belongs to herdr-core, not `settings.json`; it is unchanged.

Home Manager merges defaults into ordinary writable JSON files, not symlinks:

- On the first activation, declared fields win; unrelated app settings stay.
- On a fresh install, platform-specific shipped keybindings are seeded first.
- On subsequent activations, app edits (including deleted fields) survive if
  that field's Nix default has not changed.
- Deleting an entire config file restores its defaults on the next activation.
- Changing a Nix default applies that new value, even over an app edit.
- Removing a Nix default removes the old value only if it was not edited locally.
- Invalid JSON or symlinked config files stop activation instead of being replaced.

The previous declaration is recorded under
`$XDG_STATE_HOME/herdr-app/home-manager-defaults.json`. App edits are local:
copy anything you want reproduced on other machines into `default.nix`.
Activation does not touch runtime state or shipped layouts/mods. App theme
picks stored in layout state can override `settings.json`'s theme.

Apply with the app closed to avoid racing its own settings writes. Reopen it
after activation. No running app or core is stopped by activation.
