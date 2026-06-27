---
name: draft-mobile-platform-update
description: "Draft weekly Comun Mobile Platform project update messages. Use when asked to create a weekly status/project update for the Mobile Platform owner by gathering recently merged PRs from the mobile repository and recent Slack conversations from #engineering-frontend and #app-status, then summarizing ongoing projects, Wins, Next Steps, estimated ship timing, roadmap changes, and larger-project timelines."
---

# Draft Mobile Platform Update

## Overview

Draft a concise weekly owner update for Comun Mobile Platform. Gather evidence from GitHub and Slack, group the work by project or initiative, and produce a polished draft the user can edit before sharing.

Read `references/weekly-update-template.md` before drafting the final update.

## Workflow

1. Set the reporting window.
   - Default to the last 7 calendar days ending today in the user's timezone unless the user gives a date range.
   - State the exact inclusive date range in the draft or source notes.

2. Gather GitHub evidence from the mobile repo.
   - Prefer the current repo when run inside `comun-frontend/mobile`; otherwise identify the mobile repo before searching.
   - Fetch PRs merged during the reporting window.
   - Keep PRs related to Mobile Platform: build/release infrastructure, CI, EAS, iOS/Android native config, shared components/design system, app foundation, navigation, auth/session foundations, observability, performance, e2e/test infrastructure, dependency upgrades, tooling, platform bug fixes, or platform-owned roadmap work.
   - Skip purely product-domain PRs unless they were platform-owned, unblock a platform initiative, touch shared infrastructure, or affect app-wide behavior.
   - Capture PR title, URL, author, merged date, labels, linked issue/project if visible, and a one-line impact summary. Inspect files or PR body when the title is ambiguous.

3. Gather Slack evidence.
   - Use an available Slack connector/search tool when present. Search #engineering-frontend and #app-status within the same date range.
   - Look for mobile platform signals: "mobile platform", "iOS", "Android", "EAS", "release", "build", "OTA", "expo", "CI", "e2e", "Appium", "performance", "crash", "incident", "app status", "dependencies", "design system", "navigation", "auth", "notifications".
   - Capture permalink, channel, date, speaker, decision/status, blockers, deadlines, and any explicit ship or rollout language.
   - If Slack access is unavailable, do not invent Slack context. Draft from GitHub and include a short source gap asking for Slack access/export.

4. Synthesize into project updates.
   - Group evidence by initiative rather than by individual PR or message.
   - For each ongoing project, write:
     - Wins: what changed or got unblocked this week.
     - Next Steps: what needs to happen next and who/what is blocked if known.
     - Estimated Ship Timing: use explicit dates when sourced; otherwise mark as "TBD" or "likely next week" only when strongly supported.
   - Include roadmap updates only when evidence shows a new item, priority change, de-scope, re-scope, launch movement, or newly identified risk.
   - Mention timelines for bigger projects when there are explicit deadlines, target windows, release trains, App Store/TestFlight constraints, dependency dates, or leadership commitments.
   - Separate facts from inference. Use "Source suggests", "likely", or "needs confirmation" for inferred status.

5. Produce a shareable draft.
   - Use the template reference for structure.
   - Keep the voice owner-level, direct, and calm. Prefer crisp bullets over long narrative.
   - Include source links in a compact "Sources reviewed" or per-section notes area when available.
   - End with "Needs confirmation" only for unresolved questions that affect accuracy or commitments.

## Verification

Before finalizing, check that:

- Every ongoing project has Wins, Next Steps, and Estimated Ship Timing.
- Roadmap updates are omitted or explicitly marked "No material roadmap updates" when no evidence supports them.
- Larger timelines are concrete dates/windows, not vague urgency.
- Slack gaps are disclosed if Slack could not be searched.
- The update reads as a draft from the Mobile Platform owner, not as a raw activity report.
