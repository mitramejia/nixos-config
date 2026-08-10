---
name: commit-staged
description: Commit staged files through the dedicated commit-staged custom agent, following the active repository's documented convention.
---

# Commit Staged

1. Spawn exactly one `commit-staged` custom agent to handle this task.
2. Tell it to commit only the files currently staged in the active repository and to follow that repository's documented commit convention.
3. If the user requested a push, authorize it to push the resulting current branch after a successful commit.
4. Wait for its result, then report its commit hash, message, committed file list, and push result when applicable.

The main agent must not run `git commit` itself, stage or unstage files, amend,
push, or spawn additional agents for this task. The custom agent asks for an
issue key only when the active repository's documented convention requires one.
