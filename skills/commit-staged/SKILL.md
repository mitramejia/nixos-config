---
name: commit-staged
description: Generate commit messages from the current git branch and staged diff using the Agents.md convention `[ISSUE-123] Message`, then commit staged files. Use when asked to commit staged changes, craft a commit message from the branch name, or enforce the repo's commit prefix format.
---

# Commit Staged

## Overview

Generate a commit message that follows the repo convention and commit all currently staged files in the active git repository.

## Workflow

1. Read branch name and staged context
- Run `git rev-parse --abbrev-ref HEAD` to get the branch name.
- Run `git diff --cached --name-only` and `git diff --cached --stat` to understand the staged changes.
- Optional: run `scripts/commit_context.py` for a JSON summary.

2. Resolve the issue key
- Extract an issue key from the branch name using the pattern `ABC-123` (uppercase letters/digits + dash + digits).
- If no issue key is present in the branch name, ask the user for the issue key before committing.
- Fallback prompt: `I couldn't find an issue key in the branch name. What issue key should I use (e.g., ISSUE-123)?`

3. Generate the commit message
- Follow the convention in `references/commit-conventions.md`.
- Format: `[ISSUE-123] <summary>`.
- Keep the summary short, action-oriented, and based on the staged diff.
- If the summary would be vague (example: "Updates"), ask the user for a clearer summary.
- Fallback prompt: `What is a concise, action-oriented summary for this change?`

4. Commit staged files
- Ensure there are staged files. If none, stop and report that there is nothing to commit.
- Commit with `git commit -m "[ISSUE-123] Summary"`.

## Notes

- Do not include extra prefixes or suffixes beyond the bracketed issue key.
- If the user already provided a commit message, validate it matches the convention; otherwise, correct it.
