---
name: e2e-mobile-issue-tdd
description:
  "Deliver or resume a Comun mobile Linear issue with red-green-refactor TDD,
  focused WDIO/Appium proof, and Appium MCP-assisted iOS or Android Debug-app
  acceptance. Use for ticket-driven device journeys, permission coverage, and
  Linear evidence."
---

# Mobile E2E Issue TDD

Implement one Linear issue at a time. Use the issue as product intent, a focused
automated test as behavior proof, and the Comun Debug app as the final
acceptance surface.

## Offer optional Herdr automation

Before establishing the issue phase, check whether `herdr` is installed with
`command -v herdr >/dev/null 2>&1`.

- If Herdr is absent, skip this section silently. Do not install it, mention its
  absence, or make it a blocker.
- If Herdr is present, run `herdr --skill` and treat its output as the current
  CLI contract. Then ask the user once: "Herdr is installed. Would you like me
  to use it as the agent automation layer for this issue?" Do not create or
  control Herdr workspaces, tabs, panes, or agents before the user explicitly
  agrees.
- If the user declines, continue the complete workflow directly without Herdr.
- If the user agrees, follow `herdr --skill` and the official
  [agent-automation guidance](https://herdr.dev/docs/agent-automation/#agent-identity-and-launch).
  Verify the runtime preconditions reported by `herdr --skill` before issuing
  control commands. Capture returned workspace, tab, pane, and agent identities
  instead of predicting them. Use pane commands for ordinary shells, Metro,
  builds, and test processes; use agent commands only for recognized coding
  agents. Use bounded waits and read the reported lifecycle state rather than
  treating a submitted prompt as completion.
- If Herdr is installed but its runtime preconditions are unavailable, continue
  without it and report the exact reason. Do not turn optional automation into
  an issue-delivery blocker.
- Record every Herdr workspace, tab, pane, process, and agent created for the
  task in the cleanup ledger. Restore or remove only task-created Herdr state.

Herdr is an automation layer, not acceptance evidence. Never substitute Herdr
command success for a red/green test result, an Appium-observed customer
outcome, device provenance, or Linear evidence.

## Establish phase and coverage

1. Use the issue ID supplied by the user. Otherwise extract one key such as
   `MPLT-123` from `git branch --show-current`. Treat the user key as
   authoritative and flag a branch mismatch. If neither source yields exactly
   one key, ask which Linear issue to use and stop.
2. Read the issue, existing comments, and attachments before editing or posting
   evidence. Record the customer outcome, acceptance criteria, safe fixture
   reset, and requested platform/device surface.
3. Classify the run:
   - **Pre-fix:** production code has not changed and the reported state can be
     reproduced safely.
   - **Implementation:** red-green-refactor is still in progress.
   - **Validation resume:** implementation already exists or prior validation
     evidence is available. Continue from current evidence without recreating a
     historical before state.
4. Create an acceptance matrix with columns `Platform`, `Required surface`,
   `Requested surface`, `Permission states`, and `Status`. Preserve the
   difference between physical-device requirements and supplemental simulator or
   emulator coverage.
5. State the public test seam for the first vertical slice. Ask the user only
   when the issue and code cannot establish it safely.

Read `e2e/AGENTS.md` and `e2e/README.md` before changing E2E code. Use the `tdd`
skill for test design. Route a pre-existing WDIO/Appium failure through
`e2e-mobile-test-troubleshooter` before changing selectors, waits, or
capabilities.

## Red, green, refactor

Work in narrow vertical slices:

1. **Red:** add the smallest focused test at the confirmed seam and capture the
   expected failure before changing production code.
2. **Green:** make the minimal implementation and rerun the same test.
3. **Refactor:** improve code only after green, rerunning the focused test after
   every behavior-preserving change.

During validation resume, inspect existing test and commit evidence, then run
the current focused test. Preserve a prior red result when available; document
its absence instead of undoing the implementation to manufacture one.

Prefer focused Jest tests for app behavior. Add or change WDIO/Appium specs only
when the requirement is a device journey. Keep assertions independent of the
implementation and preserve their behavioral demand.

For a required device journey, capture a focused WDIO/Appium runner result.
Appium MCP manual acceptance supplements that automated proof; it never replaces
it.

## Prepare device validation

1. Confirm any existing Metro server belongs to this checkout. Otherwise start
   `just start` in a managed long-running terminal and wait for readiness.
   Preserve servers owned by other tasks and report a port conflict.
2. Read [device-validation.md](references/device-validation.md) before every
   Appium run. For contact or permission behavior, also read
   [permissions.md](references/permissions.md).
3. Resolve the debug app identity/profile from `app.config.ts` and `eas.json`.
   If the app is absent or its native content is stale, follow
   `.agents/skills/build-mobile-non-production/SKILL.md`, rebuild/reinstall, and
   repeat the install check.
4. Run `scripts/device-preflight.sh` for each Android target and iOS simulator,
   retaining its output with the validation notes. For a physical iOS device,
   record the equivalent fields from Appium and build/install artifacts. Record
   the exact app artifact or mark it as reused.
5. Start a cleanup ledger containing Appium sessions, temporary fixtures,
   original permission grants and flags, devices created for the task, and Metro
   ownership. A snapshot is complete only when every mutation has a precise
   restore action.

## Validate the customer outcome

1. Normalize the development client into the product surface, then inspect a
   screenshot and hierarchy before acting. When Appium MCP is exposed for an
   active native session, use it as the preferred live evidence and manual
   acceptance path; otherwise use a matching Appium session.
2. Prefer accessibility IDs, app IDs, and native selectors in that order; use
   the documented screenshot fallback only for system-owned UI absent from the
   hierarchy.
3. Reset the fixture account and app session to the recorded preconditions.
   Replay every applicable row in the acceptance matrix and confirm both the
   control state and visible result. Appium command success is supporting
   evidence, not the customer outcome.
4. On failure, capture screenshot, page source, and server/device logs. Classify
   app, environment, or harness failure. Allow one bounded Appium reattach after
   restoring transport; route a repeated failure to
   `e2e-mobile-test-troubleshooter`.
5. Record the actual surface tested and provenance. Mark unexecuted required
   rows pending with a concrete blocker; mark platform-inapplicable states
   `N/A`.
6. Restore every cleanup-ledger entry to its original state and verify the
   restoration. Delete only sessions and devices created by this task.

Use test-only data for financial activity, identity changes, or outbound
messages. Stop for direction when the available account cannot exercise the path
safely.

## Publish Linear evidence

Read [linear-evidence.md](references/linear-evidence.md) before recording or
uploading. Post one top-level comment per missing evidence phase and reuse
existing valid attachments:

- Capture **Before fix** only during the pre-fix phase. During validation
  resume, preserve existing before evidence or state plainly that historical
  before video is unavailable.
- Capture **After fix** only after focused checks and the final device replay.
- Prepare, upload, finalize, and comment in one uninterrupted sequence because
  signed upload URLs are short-lived.

Keep credentials, OTPs, tokens, and customer data out of recordings, logs, and
comments.

## Completion criteria

The issue is complete only when:

- focused behavioral proof passes; new implementation work has observable red
  and green results, while validation-resume work records any unavailable
  historical red result without recreating it;
- relevant repository compile/lint checks pass, plus
  `yarn workspace e2e compile` and `yarn workspace e2e lint-all` for E2E code;
- every acceptance-matrix row is `Passed`, `N/A` with reason, or `Pending` with
  an exact blocker and required next surface;
- device provenance, focused-check results, and applicable Linear evidence links
  are recorded;
- the cleanup ledger is empty because every task-created mutation was restored
  and verified.

Report the issue, seam, phase, checks, provenance, matrix, evidence links, Metro
state, cleanup result, and residual risk.
