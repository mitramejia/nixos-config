{lib}: let
  # Stop at the first closing delimiter, not a later Markdown horizontal rule.
  fromMarkdown = path: let
    lines = lib.splitString "\n" (lib.replaceStrings ["\r\n"] ["\n"] (builtins.readFile path));
    rest = builtins.tail lines;
    end = lib.lists.findFirstIndex (line: builtins.elem line ["---" "..."]) null rest;
    header = lib.take end rest;
    descriptions = builtins.filter (lib.hasPrefix "description: ") header;
  in
    assert builtins.head lines == "---" && end != null;
    assert builtins.length descriptions == 1; {
      original = builtins.readFile path;
      format = "markdown";
      description = lib.removePrefix "description: " (builtins.head descriptions);
      body = lib.concatStringsSep "\n" (lib.drop (end + 1) rest);
    };
  fromToml = path: let
    agent = builtins.fromTOML (builtins.readFile path);
  in {
    original = builtins.readFile path;
    format = "toml";
    inherit (agent) description;
    body = agent.developer_instructions;
  };
  markdownNames = ["planner" "worker" "scout" "triage" "mobile-reviewer" "mobile-release-safety" "appium-test-engineer"];
  tomlNames = ["pr-reviewer" "commit-staged"];
  readOnlyNames = ["planner" "scout" "triage" "mobile-reviewer" "mobile-release-safety" "pr-reviewer" "commit-staged"];
  sources =
    lib.genAttrs markdownNames (name: fromMarkdown (../opencode/agents + "/${name}.md"))
    // lib.genAttrs tomlNames (name: fromToml (../codex/agents + "/${name}.toml"));
  adaptBody =
    lib.replaceStrings
    ["$pr-review-style" "~/.codex/skills/pr-review-style/SKILL.md"]
    ["/pr-review-style" "~/.claude/skills/pr-review-style/SKILL.md"];
  render = name: agent: ''
    ---
    name: ${builtins.toJSON name}
    description: ${builtins.toJSON agent.description}
    model: inherit
    permissionMode: default
    ${lib.optionalString (builtins.elem name readOnlyNames) "disallowedTools: [Edit, Write, NotebookEdit]"}
    ---
    ${adaptBody agent.body}'';
in {
  inherit sources readOnlyNames;
  agents = lib.mapAttrs render sources;
}
