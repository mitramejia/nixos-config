# AGENTS.md

Guidance for automated agents working in this Nix config. Keep changes small, declarative, and aligned with the repo layout.

## Repository map
- `flake.nix`: entry point; defines inputs, `nixosConfigurations`, and `specialArgs` (including `unstable-pkgs`).
- `modules/core`: NixOS system configuration (boot, hardware, services, packages).
- `modules/home`: Home Manager configuration (user programs, dotfiles, scripts).
- `modules/variables.nix`: shared values (username, git, defaults, wallpaper, keyboard).
- `assets/`: static assets (wallpapers, etc).

## Best practices
- Prefer declarative Nix over imperative scripts; if a script is required, add it under `modules/home/scripts`.
- Keep NixOS concerns in `modules/core` and user-level preferences in `modules/home`.
- Reuse `modules/variables.nix` for shared values instead of duplicating literals.
- Avoid changing `system.stateVersion` or Home Manager `home.stateVersion` unless explicitly requested.
- Keep `nixpkgs.config.allowUnfree = true;` consistent; do not add per-package unfree toggles unless required.
- Use `unstable-pkgs` only when a package is missing/too old in stable; document why in the module.
- Preserve module imports ordering unless there is a clear dependency reason to change it.

## Formatting
- Use a Nix formatter before finalizing changes (`alejandra` or `nixfmt-rfc-style` are available). Keep style consistent with nearby files.

## Commit messages
- Use the Conventional Commits specification: https://www.conventionalcommits.org/en/v1.0.0/#specification
- Avoid overly verbose descriptions or unnecessary details.
- Start with a short sentence in imperative form, no more than 50 characters long.
- Then leave an empty line and continue with a more detailed explanation.
- Write only one sentence for the first part, and two or three sentences at most for the detailed explanation.

## Adding software
- System-wide packages: `modules/core/packages.nix` under `environment.systemPackages`.
- User-only packages: `modules/home/*.nix` or `modules/home/default.nix` (prefer specific module when one exists).
- Home Manager program options: add to the relevant file in `modules/home` and import it in `modules/home/default.nix` if new.

## Home Manager integration
- Home Manager is wired in `modules/core/user.nix` with `extraSpecialArgs` and imports `modules/home`.
- If you need new shared args, add them in `flake.nix` `specialArgs` and pass through to Home Manager.

## Deployment and checks
- Local rebuilds are typically done with `nh` (see `modules/core/nh.nix`) or `nixos-rebuild` with the flake.
- For quick validation, at least run `nix flake check` when feasible.

## Safety
- Never delete or rewrite large sections without explicit instruction.
- Keep secrets out of the repo; prefer external secret managers or environment-based injection.
