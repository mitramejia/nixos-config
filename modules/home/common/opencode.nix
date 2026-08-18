{
  lib,
  unstablePkgs,
  ...
}: {
  # The opencode vim plugin requires opencode >= 1.17.10, which stable does
  # not provide yet, so this one program tracks the pinned unstable set.
  programs.opencode = {
    enable = true;
    package = unstablePkgs.opencode;
    enableMcpIntegration = true;
  };

  xdg.configFile = lib.mapAttrs' (name: source:
    lib.nameValuePair "opencode/${name}" {inherit source;}) {
    "agents/pocock-planner.md" = ./opencode/agents/pocock-planner.md;
    "agents/pocock-worker.md" = ./opencode/agents/pocock-worker.md;
    "agents/pocock-scout.md" = ./opencode/agents/pocock-scout.md;
    "agents/pocock-triage.md" = ./opencode/agents/pocock-triage.md;
    "agents/mobile-reviewer.md" = ./opencode/agents/mobile-reviewer.md;
    "agents/mobile-release-safety.md" = ./opencode/agents/mobile-release-safety.md;
    "commands/mobile-implement.md" = ./opencode/commands/mobile-implement.md;
    "commands/mobile-plan.md" = ./opencode/commands/mobile-plan.md;
    "commands/mobile-review.md" = ./opencode/commands/mobile-review.md;
    "commands/mobile-check.md" = ./opencode/commands/mobile-check.md;
    "commands/mobile-test.md" = ./opencode/commands/mobile-test.md;
    "commands/mobile-release-audit.md" = ./opencode/commands/mobile-release-audit.md;
  };
}
