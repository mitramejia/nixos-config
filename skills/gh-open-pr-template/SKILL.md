---
name: gh-open-pr-template
description: Open a GitHub pull request from the current branch using `.github/pull_request_template.md`, generate a short PR title from branch commits with required `[ISSUE-123]` prefix parsed from branch name, apply the `Platform` label, assign `mitramejia` as assignee, and collect/improve user-provided testing steps for the `Testing Notes` section. Use when a user asks to create/open a PR with this repo's template and metadata conventions.
---

# GH Open PR Template

## Overview

Create a PR with consistent metadata and a useful description without asking the user to manually format the template. Build the title and body from branch commits, then enrich the testing section from user input.

## Required Workflow

Follow these steps in order.

1. Gather local and repo context
- Read current branch name with `git rev-parse --abbrev-ref HEAD`.
- Read commits not on base with `git log --oneline origin/main..HEAD` (fallback to `main..HEAD` if needed).
- Read `.github/pull_request_template.md`.
- Ensure there is at least one commit ahead of base; otherwise stop and report no PR content to summarize.

2. Build the issue key and title
- Extract issue key from branch using regex `[A-Z0-9]+-[0-9]+`.
- If no key is found, ask user for issue key before continuing.
- Generate a short, action-oriented PR title from commit subjects.
- Set final title to: `[ISSUE-123] <generated short title>`.
- Example: branch `MPLT-234-new-change` -> title `[MPLT-234] <generated short title>`.

3. Ask for testing instructions
- Ask the user: `How should reviewers test these changes?`
- Take the user response and improve it:
- Normalize grammar and tense.
- Convert vague statements into concrete verification steps.
- Keep only truthful steps grounded in branch changes.
- Format as concise bullets for the template section.

4. Fill the PR template body
- Preserve template checklist lines exactly unless user explicitly requests edits.
- Fill `## Description (as needed):` with:
- Brief summary paragraph.
- Bullet list of key changes derived from commit subjects and touched files.
- Fill `## Testing Notes (as needed):` with improved testing steps from Step 3.
- Leave optional sections empty if no material exists (`Link to #fe-design-demos post`, `Recordings/screenshots`).

5. Create and decorate the PR
- Create PR against `main` unless user specifies another base.
- Use GitHub tools/CLI to create PR with generated title and template body.
- Add label `Platform`.
- Assign `mitramejia` as assignee.

6. Verify and report
- Confirm PR URL.
- Confirm final title, applied label(s), and assignee(s).
- If any metadata operation fails (label missing, assignment permission), report exact failure and provide the fallback action.

## Guardrails

- Keep generated title short, specific, and non-generic. Avoid titles like `Updates` or `Fixes`.
- Do not fabricate testing steps. Improve wording only from user-provided intent and known change scope.
- Do not include unrelated unstaged/uncommitted changes in description.
- If branch has a single commit, summarize that commit directly.
- If branch has many commits, group by theme and deduplicate repeated churn.

## Output Checklist

- PR created from `.github/pull_request_template.md`
- Title format: `[ISSUE-123] <generated short title>`
- Label `Platform` applied
- Assignee `mitramejia` set
- `Testing Notes` included from improved user-provided test instructions
