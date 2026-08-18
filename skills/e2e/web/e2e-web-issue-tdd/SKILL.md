---
name: e2e-web-issue-tdd
description:
  "Deliver or resume a web issue with red-green-refactor Playwright E2E tests and
  Playwright MCP-assisted local acceptance. Use for browser journeys requiring
  deterministic fixtures, focused runner proof, and live DOM evidence."
---

# Web E2E Issue TDD

## Establish the seam

1. Read root guidance, `package.json`, `playwright.config.ts`, the target spec,
   and its fixtures/helpers before editing. Treat them as the source of truth for
   scripts, browsers, projects, base URL, web server, retries, and artifacts.
2. Read the issue and existing evidence. Record the customer outcome, acceptance
   criteria, affected route, fixture reset, and the smallest browser journey that
   proves it. The current app may use `/pay` and `e2e/.artifacts`; confirm both
   in the checked-out configuration rather than assuming them.
3. Inspect nearby specs for locator, helper, mock, and state-seeding patterns.
   State the first vertical test seam; ask only if the issue and code cannot
   establish it safely.

## Red, green, refactor

1. **Red:** add the smallest focused Playwright test and capture its expected
   failure before changing product code.
2. Use role, label, or stable test-ID locators; reuse existing helpers. Install
   deterministic `page.route` mocks and seed browser state before navigation
   when the journey needs controlled API or session state.
3. **Green:** make the minimal product or test-support change and rerun that
   exact test.
4. **Refactor:** improve only after green and rerun the focused test after each
   behavior-preserving change. Preserve prior red evidence during a validation
   resume; report its absence rather than undoing implementation to recreate it.

## Accept the journey

1. Start or reuse only the local server specified by the current Playwright
   configuration. Preserve servers owned by other work and report configuration,
   port, credential, or environment blockers.
2. When Playwright MCP is exposed for the running local app, inspect the live
   DOM and visual state before acting, then replay the acceptance path manually.
   This acceptance evidence supplements and never replaces Playwright runner
   proof.
3. Reset seeded state, routes, and task-created resources after every replay.
   Record the tested browser/project, visible outcome, and any unexecuted
   acceptance criterion with its exact blocker.

## Validate and complete

1. Run the focused Playwright test through the repository's current script and
   capture its runner result. Run relevant repository checks for touched code.
2. Inspect configured artifacts for any failed or retried run before concluding.
3. Complete only when the focused runner proof passes, manual acceptance is
   recorded when available, task-created state/resources are cleaned up, and
   every acceptance criterion is passed or has an explicit blocker.

Report the issue, seam, red/green evidence, files changed, commands and results,
MCP acceptance result, cleanup, and residual risk.
