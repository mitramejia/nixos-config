---
name: linear-issue-from-diff
description: Create a Linear issue from the current git changes (staged and/or unstaged), defaulting to Mobile Platform team, assignee mitra, and state In Progress. Use this when the user asks to open/create a Linear ticket based on the current branch diff.
---

# Linear Issue From Diff

## Overview
Use this skill to create one Linear issue from the current local git changes. It works with staged changes, unstaged changes, or both, and includes manual testing steps derived from the changed files and behavior.

## Defaults
- Team: `Mobile Platform`
- Assignee: `mitra`
- State: `In Progress`

Use these defaults unless the user explicitly overrides them.

## Workflow

### 1) Collect diff context
Run:

```bash
"$CODEX_HOME/skills/linear-issue-from-diff/scripts/collect_git_diff_context.sh"
```

This returns:
- branch name
- staged file list
- unstaged file list
- staged diff block
- unstaged diff block

If there are no staged and no unstaged files, ask the user if they still want a generic issue before creating anything.

### 2) Draft the issue content
Create:
- A concise action-oriented title.
- Description with these sections:
  - `Context / Problem`
  - `Proposed Changes`
  - `Affected Files`
  - `Risks / Edge Cases`
  - `Manual Testing Steps`

For `Affected Files`, include only relevant file paths and why they matter.

For `Manual Testing Steps`, derive concrete checks from the actual diff:
- Preconditions/setup.
- Exact in-app navigation path.
- Numbered steps with explicit expected outcomes.
- Regression checks for nearby behavior.
- Platform-specific notes when needed (Android/iOS).

### 3) Resolve Linear entities
Use Linear tools to resolve defaults:
- Team: find `Mobile Platform` with `linear.list_teams` (or fallback query match).
- Assignee: find `mitra` with `linear.list_users`.
- State: find `In Progress` in team statuses with `linear.list_issue_statuses`.

If any default cannot be resolved, ask for confirmation before using a fallback.

### 4) Create issue
Use `linear.create_issue` with:
- `team`: resolved Mobile Platform team
- `assignee`: resolved mitra user
- `state`: resolved In Progress status
- `title`: generated title
- `description`: generated markdown body

### 5) Report result
Return:
- created issue identifier and URL
- final team/assignee/state used
- final `Manual Testing Steps` section

## Notes
- Include both staged and unstaged work in one issue when both exist.
- Do not silently omit risky changes; call them out in `Risks / Edge Cases`.
- Keep description concise but specific enough for async handoff.
