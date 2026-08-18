---
name: e2e-web-test-troubleshooter
description:
  "Diagnose and narrowly fix a failing web Playwright E2E test using runner
  artifacts and Playwright MCP live inspection. Use for browser test failures in
  locators, waits, fixtures, routes, state, servers, or configuration."
---

# Web E2E Test Troubleshooter

## Establish evidence

1. Read root guidance, `package.json`, `playwright.config.ts`, the failing spec,
   and its fixtures/helpers. Treat current configuration as authoritative for
   scripts, browser/project, base URL, server, retry policy, and artifact paths.
   The referenced app may use `/pay` and `e2e/.artifacts`; verify the checkout.
2. Record the exact test, browser/project, command, failing assertion, locator,
   retry status, server state, and relevant dirty worktree context.
3. Inspect Playwright output and configured trace, screenshot, and video
   artifacts before editing. Use the failure's DOM, action timeline, network
   evidence, and visible state to identify the first divergent step.
4. When Playwright MCP is exposed for the running local app, inspect its live
   DOM and visual state, then reproduce the path manually. MCP evidence supports
   diagnosis and acceptance; it never replaces Playwright runner proof.

## Classify and fix

1. Classify the first proven divergence as one of: app defect; locator or wait;
   fixture, route mock, router, or seeded state; server or configuration; or an
   external environment blocker.
2. For app defects, preserve the failing E2E evidence and use the repository's
   normal app feedback loop before changing product code. For harness defects,
   make the smallest change in the spec, fixture, helper, or configuration.
3. Use role, label, or stable test-ID locators and existing helpers. Make mocks
   deterministic with `page.route`, seed required state before navigation, and
   assert the user-visible transition that proves readiness.
4. Keep the configured retry and timeout policy. Use condition-based Playwright
   assertions or waits tied to the proven transition; do not use fixed sleeps,
   blind reruns, arbitrary timeout increases, `.only`, or `.skip`.

## Validate and complete

1. Rerun the exact focused test through the repository's current script. Inspect
   its artifacts if it fails or retries, then run relevant checks for touched
   code.
2. Clean up seeded browser state, route handlers, servers, and other resources
   created by the task. Do not alter unrelated dirty changes.
3. Complete only with a focused runner result, artifact-backed root cause, narrow
   fix, relevant check results, and either restored resources or an explicit
   environment blocker.

Report evidence, classification, root cause, exact files changed, validation,
cleanup, and only artifact-backed residual risk.
