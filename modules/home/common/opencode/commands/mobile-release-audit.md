---
description: Audit the current diff for OTA, EAS, native, and release risks
agent: mobile-release-safety
---

Audit the current diff for release safety: $ARGUMENTS

Recent commits:
!`git log --oneline -10`

Diff summary:
!`git diff --stat`

Do not modify files. Separate confirmed release blockers from checks that require
CI, EAS, or a physical device.
