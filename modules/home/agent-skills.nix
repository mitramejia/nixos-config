{inputs, ...}: {
  imports = [inputs.agent-skills.homeManagerModules.default];

  programs.agent-skills = {
    enable = true;

    sources.mattpocock-productivity = {
      input = "mattpocock-skills";
      subdir = "skills/productivity";
      filter.maxDepth = 1;
    };

    sources.mattpocock-engineering = {
      input = "mattpocock-skills";
      subdir = "skills/engineering";
      filter.maxDepth = 1;
    };

    skills.enableAll = [
      "mattpocock-productivity"
      "mattpocock-engineering"
    ];

    targets = {
      codex.enable = true;
      opencode.enable = true;
      claude.enable = true;
    };
  };
}
