{inputs, ...}: let
  cursorTeamKitSkills = [
    "cursor-team-kit/check-compiler-errors"
    "cursor-team-kit/control-cli"
    "cursor-team-kit/control-ui"
    "cursor-team-kit/deslop"
    "cursor-team-kit/fix-ci"
    "cursor-team-kit/fix-merge-conflicts"
    "cursor-team-kit/get-pr-comments"
    "cursor-team-kit/loop-on-ci"
    "cursor-team-kit/make-pr-easy-to-review"
    "cursor-team-kit/new-branch-and-pr"
    "cursor-team-kit/pr-review-canvas"
    "cursor-team-kit/review-and-ship"
    "cursor-team-kit/run-smoke-tests"
    "cursor-team-kit/thermo-nuclear-code-quality-review"
    "cursor-team-kit/verify-this"
    "cursor-team-kit/weekly-review"
    "cursor-team-kit/what-did-i-get-done"
  ];

  expoSkills = [
    "expo/upgrading-expo"
    "expo/expo-deployment"
  ];
in {
  imports = [inputs.agent-skills.homeManagerModules.default];

  programs.agent-skills = {
    enable = true;

    sources = {
      mattpocock-productivity = {
        input = "mattpocock-skills";
        subdir = "skills/productivity";
        filter.maxDepth = 1;
      };

      mattpocock-engineering = {
        input = "mattpocock-skills";
        subdir = "skills/engineering";
        filter.maxDepth = 1;
      };

      cursor-team-kit = {
        input = "cursor-plugins";
        subdir = "cursor-team-kit/skills";
        idPrefix = "cursor-team-kit";
        filter.maxDepth = 1;
      };

      expo = {
        input = "expo-skills";
        subdir = "plugins/expo/skills";
        idPrefix = "expo";
        filter.maxDepth = 1;
      };

      gh-open-pr-template = {
        path = ../../skills;
        subdir = "gh-open-pr-template";
        filter.maxDepth = 1;
      };

      draft-mobile-platform-update = {
        path = ../../skills;
        subdir = "draft-mobile-platform-update";
        filter.maxDepth = 1;
      };
    };

    skills.enable = cursorTeamKitSkills ++ expoSkills;

    skills.enableAll = [
      "mattpocock-productivity"
      "mattpocock-engineering"
      "gh-open-pr-template"
      "draft-mobile-platform-update"
    ];

    targets = {
      codex.enable = true;
      opencode.enable = true;
      claude.enable = true;
    };
  };
}
