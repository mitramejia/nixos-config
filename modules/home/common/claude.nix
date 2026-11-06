{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  rendered = import ./claude/agents.nix {inherit lib;};
  cfg = config.programs.agent-skills;
  agentLib = import (inputs.agent-skills + "/lib") {inherit inputs lib;};
  selection = agentLib.selectSkills {
    catalog = cfg.catalog;
    sources = cfg.sources;
    skills = cfg.skills.explicit;
    allowlist = agentLib.allowlistFor {
      catalog = cfg.catalog;
      sources = cfg.sources;
      enableAll = cfg.skills.enableAll;
      enable = cfg.skills.enable;
    };
  };
  originalBundle = agentLib.mkBundle {inherit pkgs selection;};
  claudeSelection = lib.filterAttrs (_: skill: (skill.agents or null) == null || builtins.elem "claude" skill.agents) selection;
  flatNames = map builtins.baseNameOf (builtins.attrNames claudeSelection);
  flatSelection = lib.mapAttrs' (id: skill: lib.nameValuePair (builtins.baseNameOf id) (skill // {id = builtins.baseNameOf id;})) claudeSelection;
  # Claude 2.1.310 discovers only immediate skill children. Keep source IDs and
  # the other targets unchanged; flatten only Claude's deployment view.
  claudeBundle = assert lib.assertMsg (builtins.length flatNames == builtins.length (lib.unique flatNames)) "Claude skill basenames must be unique.";
    agentLib.mkBundle {
      inherit pkgs;
      selection = flatSelection;
    };
  bundle = originalBundle.overrideAttrs (old: {
    passthru =
      old.passthru
      // {
        forTarget = name:
          if name == "claude"
          then claudeBundle
          else originalBundle.forTarget name;
      };
  });
  manifest = pkgs.writeText "claude-agents.json" (builtins.toJSON {
    inherit (rendered) agents sources readOnlyNames;
    skillIds = builtins.attrNames claudeSelection;
    inherit flatNames;
    skillBundles = {
      claude = toString cfg.targetBundlePaths.claude;
      codex = toString cfg.targetBundlePaths.codex;
      opencode = toString cfg.targetBundlePaths.opencode;
    };
    originalBundle = toString originalBundle;
  });
in {
  options.private.claudeAgentsCheck = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    description = "Focused Claude agent rendering regression check.";
  };

  config = {
    programs.agent-skills.bundlePath = lib.mkForce bundle;
    home.file = lib.mapAttrs' (name: text: lib.nameValuePair ".claude/agents/${name}.md" {inherit text;}) rendered.agents;
    private.claudeAgentsCheck =
      pkgs.runCommand "claude-agents-check" {
        nativeBuildInputs = [(pkgs.python3.withPackages (p: [p.pyyaml]))];
      } ''
        python ${./claude/check-agents.py} ${manifest}
        touch "$out"
      '';
  };
}
