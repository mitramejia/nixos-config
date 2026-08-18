---
description: Run the Comun-style CI check and diagnose failures
agent: pocock-worker
subtask: false
---

Run `just check-ci` from the repository root. Diagnose each failure, identify
whether it is caused by the current change, and fix only failures in scope.
Do not bypass lint, type checking, tests, or dead-code checks. Summarize the
result and any checks that could not complete.
