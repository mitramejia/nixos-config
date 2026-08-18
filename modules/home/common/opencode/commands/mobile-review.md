---
description: Review the current mobile diff for bugs and CI failures
agent: mobile-reviewer
---

Review the current diff for: $ARGUMENTS

Current status:
!`git status --short`

Diff summary:
!`git diff --stat`

Use the repository guidance and report only actionable findings with severity,
location, evidence, and a smallest safe fix. Do not modify files.
