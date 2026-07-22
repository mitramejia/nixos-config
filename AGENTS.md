# AGENTS.md

Guidance for automated agents working in this Nix config. Keep changes small, declarative, and aligned with the repo layout.

## Repository map
- `flake.nix`: entry point; defines the two host records, outputs, and shared `specialArgs`.
- `hosts/nixos`: NixOS hardware and machine-only state.
- `hosts/macos`: macOS hostname, state, and machine-only application exceptions.
- `modules/nixos`: reusable NixOS system configuration.
- `modules/darwin`: reusable nix-darwin and Homebrew configuration.
- `modules/home/common`, `modules/home/nixos`, and `modules/home/darwin`: portable, Linux, and macOS Home Manager layers.
- `modules/variables.nix`: shared Git, wallpaper, and keyboard values.
- `assets/`: static assets (wallpapers, etc).

## Best practices
- Prefer declarative Nix over imperative scripts; if a script is required, add it under the matching Home Manager platform layer.
- Keep NixOS and Darwin system concerns in their respective platform modules; put user preferences in the appropriate Home Manager layer.
- Reuse `modules/variables.nix` for shared values instead of duplicating literals.
- Avoid changing `system.stateVersion` or Home Manager `home.stateVersion` unless explicitly requested.
- Keep `nixpkgs.config.allowUnfree = true;` consistent; do not add per-package unfree toggles unless required.
- Use a separately pinned package set only when a package is missing or too old in stable; document why in the module.
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
- NixOS system packages: `modules/nixos/packages.nix` under `environment.systemPackages`.
- Portable user packages: `modules/home/common`; platform-specific user packages: `modules/home/nixos` or `modules/home/darwin`.
- Home Manager program options: add a focused module and import it from the matching Home Manager layer.

## Home Manager integration
- Home Manager is wired in `modules/nixos/user.nix` and `modules/darwin/home-manager.nix`; both receive the checked-in host record through `extraSpecialArgs`.
- If you need new shared args, add them in `flake.nix` `specialArgs` and pass through to Home Manager.

## Deployment and checks
- Deploy with `nh os switch . -H nixos` on Linux or `nh darwin switch . -H macbook` on macOS.
- For quick validation, at least run `nix flake check` when feasible.

## Safety
- Never delete or rewrite large sections without explicit instruction.
- Keep secrets out of the repo; prefer external secret managers or environment-based injection.
