"""Check generated Claude definitions without launching Claude or activating a home."""

import json
from pathlib import Path
import re
import sys
import tomllib

import yaml


manifest = json.load(open(sys.argv[1]))
expected = {
    "planner", "worker", "scout", "triage", "mobile-reviewer",
    "mobile-release-safety", "appium-test-engineer", "pr-reviewer", "commit-staged",
}
read_only = expected - {"worker", "appium-test-engineer"}
assert set(manifest["agents"]) == expected
assert set(manifest["readOnlyNames"]) == read_only
for name, text in manifest["agents"].items():
    _, frontmatter, body = text.split("---\n", 2)
    meta = yaml.safe_load(frontmatter)
    assert set(meta) == {"name", "description", "model", "permissionMode"} | (
        {"disallowedTools"} if name in read_only else set()
    ), name
    assert meta["name"] == name and re.fullmatch(r"[a-z][a-z0-9-]*", name)
    assert meta["description"] == manifest["sources"][name]["description"]
    assert isinstance(meta["description"], str) and meta["description"]
    assert meta["model"] == "inherit" and meta["permissionMode"] == "default"
    if name in read_only:
        assert meta["disallowedTools"] == ["Edit", "Write", "NotebookEdit"]
    original = manifest["sources"][name]
    if original["format"] == "toml":
        parsed = tomllib.loads(original["original"])
        source = parsed["developer_instructions"]
    else:
        _, header, source = original["original"].replace("\r\n", "\n").split("---\n", 2)
        parsed = yaml.safe_load(header)
    assert meta["description"] == parsed["description"], name
    adapted = source.replace("$pr-review-style", "/pr-review-style").replace(
        "~/.codex/skills/pr-review-style/SKILL.md",
        "~/.claude/skills/pr-review-style/SKILL.md",
    )
    assert body == adapted, name
    assert "openai/" not in frontmatter
reviewer = manifest["agents"]["pr-reviewer"]
assert "/pr-review-style" in reviewer
assert "~/.claude/skills/pr-review-style/SKILL.md" in reviewer
assert "~/.codex/" not in reviewer
skill_ids = manifest["skillIds"]
flat_names = manifest["flatNames"]
assert len(skill_ids) == len(set(flat_names))
assert flat_names == [skill_id.rsplit("/", 1)[-1] for skill_id in skill_ids]
assert {"pr-review-style", "check-compiler-errors", "expo-upgrade"} <= set(flat_names)
assert any(skill_id.startswith("e2e/") for skill_id in skill_ids)
bundles = manifest["skillBundles"]
assert bundles["codex"] == bundles["opencode"] == manifest["originalBundle"]
claude_bundle = Path(bundles["claude"])
assert {entry.name for entry in claude_bundle.iterdir()} == set(flat_names)
for skill_id, flat_name in zip(skill_ids, flat_names):
    deployed = (claude_bundle / flat_name / "SKILL.md").read_bytes()
    source = (Path(manifest["originalBundle"]) / skill_id / "SKILL.md").read_bytes()
    assert deployed == source, skill_id
print("Validated all nine Claude agents, source prompts, and permissions.")
print(f"Validated flat Claude coverage for all {len(skill_ids)} selected skills.")
