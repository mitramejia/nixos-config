#!/usr/bin/env python3
"""
Print JSON context for committing staged changes.

Outputs:
{
  "branch": "feature/ISSUE-123-add-foo",
  "issue_key": "ISSUE-123",
  "staged_files": ["src/foo.ts"],
  "diffstat": "..."
}
"""

import json
import re
import subprocess
import sys

ISSUE_KEY_RE = re.compile(r"\b([A-Z][A-Z0-9]+-\d+)\b")


def run_git(args):
    try:
        return subprocess.check_output(["git", *args], stderr=subprocess.STDOUT).decode().strip()
    except subprocess.CalledProcessError as exc:
        output = exc.output.decode().strip()
        raise RuntimeError(output or "git command failed")


def main():
    try:
        branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"])
    except RuntimeError as exc:
        print(f"[commit-context] error: {exc}", file=sys.stderr)
        sys.exit(1)

    issue_key = None
    match = ISSUE_KEY_RE.search(branch)
    if match:
        issue_key = match.group(1)

    staged_files_raw = run_git(["diff", "--cached", "--name-only"])
    staged_files = [line for line in staged_files_raw.splitlines() if line.strip()]

    diffstat = run_git(["diff", "--cached", "--stat"])

    print(
        json.dumps(
            {
                "branch": branch,
                "issue_key": issue_key,
                "staged_files": staged_files,
                "diffstat": diffstat,
            },
            indent=2,
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
