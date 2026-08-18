---
name: e2e-test-troubleshooter
description:
  "Diagnose and fix Comun Appium E2E failures in e2e/specs, including
  UiAutomator2 instrumentation death, Expo dev-client or Android Metro transport
  state, local simulator failures, BrowserStack RCA/logs, native permission
  prompts, selector misses, timeout flakes, app upload or capability drift, and
  platform share sheet behavior. Use when a failing WDIO/Appium test needs
  evidence-based root cause analysis and a narrow repo fix. Do not use for
  Jest/unit tests or app logic debugging unless E2E artifacts prove an app bug."
---

# E2E Test Troubleshooter

Use this skill to debug Appium failures without guessing. Treat stack traces,
BrowserStack RCA labels, and timeout messages as leads, not conclusions.

When E2E evidence establishes an application bug instead of a harness failure,
use Matt Pocock's `diagnose` skill for the app-level feedback loop before
changing production code.

## First principles

- Prove the current app/device state from artifacts, logs, RCA, video, or a live
  Appium session before changing selectors or waits.
- Prefer narrow fixes in `e2e/helpers`, `e2e/screen-objects`, specs, or WDIO
  config. Change app code only when artifacts prove the app is wrong.
- Do not add `browser.pause`, implicit waits, committed `browser.debug`,
  `.only`, `.skip`, broad helper rewrites, or blind timeout inflation.
- Do not revert dirty worktree changes you did not make.
- When app source or `testIds.ts` changed, require a rebuilt local binary or a
  newly uploaded BrowserStack app before trusting an E2E rerun.

## Required context

1. Read `e2e/README.md`, especially "Adding an Appium spec" and "Failure
   artifacts".
2. Inspect the failing spec, related Screen Objects, helper functions, WDIO
   config, and any imported app `testIds.ts` modules.
3. If `appium-mcp` is available and a session exists, use it to inspect the
   current hierarchy and element availability. Otherwise rely on captured
   artifacts and logs.
4. Record whether the visible surface is the Expo development client, product
   UI, native system UI, or a load/auth error. For Android, record Metro host
   status and `adb reverse --list` separately.

## Evidence workflow

1. Identify the exact spec, test name, platform, device/OS, failing command,
   selector, wait timeout, and whether this is local or BrowserStack.
2. For local failures, inspect `e2e/.artifacts/<describe>/<it>.png`, `.xml`, and
   `.server.log` in that order. The screenshot shows the user-visible state, XML
   shows what Appium can select, and the server log shows command timing.
3. For BrowserStack failures, fetch RCA, video, Appium logs, device logs,
   network logs when enabled, capabilities, and app build metadata. Compare RCA
   with Appium logs; do not trust the RCA label by itself.
4. Classify the failure:
   - Expo onboarding, launcher, developer menu, Metro load error, or account
     login is visible: normalize the development client before treating a
     missing product selector as an app failure.
   - Host Metro is healthy but Android cannot load: inspect and restore the
     device-specific `adb reverse` mapping, especially after session creation,
     force-stop, relaunch, or permission mutation.
   - `DeadObjectException`, instrumentation loss, or dead UiAutomation binder:
     capture Appium server log and logcat, throttle the MJPEG screenshot stream,
     set `waitForIdleTimeout` to `0`, and allow one reattach. A repeated death
     is a harness failure.
   - A permission command killed or reloaded the app: verify the OS permission
     and flags, restore transport, relaunch, and return to the path before
     judging the product result.
   - Native alert, OS prompt, dev menu, share sheet, or other overlay blocks the
     app: clear or handle that state before checking app selectors.
   - Selector absent from XML and no overlay: inspect navigation state, rebuild
     status, testID availability, and whether the test is on a valid screen.
   - Selector present but not interactable: re-query inside waits and check
     visibility/focus/platform input behavior.
   - BrowserStack-only: check app upload freshness, permissions, device
     language, location capabilities, unsupported Appium commands, and service
     config drift.
   - Appium reports command success but the screenshot or hierarchy contradicts
     the expected outcome: trust the visible state and continue diagnosis.

## Fix rules

- Use typed app-owned test ID constants when available; avoid raw selectors in
  specs unless the UI is system-owned or an existing local pattern requires it.
- Put platform mechanics in helpers and product-state decisions in specs.
- For waits, use `browser.waitUntil` with repo timeouts/intervals, re-query
  elements inside the callback, and handle known native prompts inside the poll
  before app selector checks.
- For native prompts, inspect the live alert text/buttons or current repo helper
  behavior before acting. Prefer exact allow actions from the current device
  state; do not blindly tap a fallback that could deny a permission.
- For share sheets, first prove the native sheet is open in XML before looking
  for system actions such as `Copy`.
- For system-owned UI visible in a screenshot but absent from the hierarchy,
  permit a coordinate action only from the current screenshot/window size and
  require a post-action screenshot. Never reuse the coordinate across devices or
  screens.
- Bound environment recovery to one transport restore and Appium reattach.
  Preserve the second failure as evidence and fix the classified layer instead
  of entering an open-ended retry loop.
- Keep BrowserStack capability types and objects in sync; compile failures in
  config are real test-harness failures, not noise.

## Validation

- For helper/spec/config changes, run focused ESLint on touched files, then
  `yarn workspace e2e compile` and `yarn workspace e2e lint-all`.
- For app source or testID changes, also run `yarn compile` and
  `yarn lint-all --fix`.
- Re-run local or BrowserStack E2E only when the required app binary,
  credentials, device access, and time budget are available.
- If validation is blocked by unrelated worktree changes, report the exact file
  and error instead of fixing unrelated code.

## Output

Return a concise report with:

- Evidence: artifact/log/RCA facts that prove the device state.
- Root cause: one specific cause, or a ranked list when evidence is incomplete.
- Fix: exact files changed and why the change is narrow.
- Validation: commands run and results, plus any rerun that still needs a fresh
  app build or BrowserStack access.
- Residual risk: only real, artifact-backed risks. Do not invent speculative
  edge cases.
