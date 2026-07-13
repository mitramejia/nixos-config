#!/usr/bin/env bash
set -euo pipefail

MAX_LINES="${MAX_LINES:-500}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: current directory is not a git repository" >&2
  exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD)"

staged_files="$(git diff --name-only --cached)"
unstaged_files="$(git diff --name-only)"

has_staged="false"
has_unstaged="false"

if [ -n "$staged_files" ]; then
  has_staged="true"
fi
if [ -n "$unstaged_files" ]; then
  has_unstaged="true"
fi

if [ "$has_staged" = "false" ] && [ "$has_unstaged" = "false" ]; then
  cat <<OUT
BRANCH: $branch
HAS_CHANGES: false
HAS_STAGED: false
HAS_UNSTAGED: false
OUT
  exit 0
fi

cat <<OUT
BRANCH: $branch
HAS_CHANGES: true
HAS_STAGED: $has_staged
HAS_UNSTAGED: $has_unstaged

=== STAGED_FILES_START ===
${staged_files}
=== STAGED_FILES_END ===

=== UNSTAGED_FILES_START ===
${unstaged_files}
=== UNSTAGED_FILES_END ===
OUT

if [ "$has_staged" = "true" ]; then
  echo
  echo "=== STAGED_DIFF_START ==="
  git diff --cached | sed -n "1,${MAX_LINES}p"
  echo "=== STAGED_DIFF_END ==="
fi

if [ "$has_unstaged" = "true" ]; then
  echo
  echo "=== UNSTAGED_DIFF_START ==="
  git diff | sed -n "1,${MAX_LINES}p"
  echo "=== UNSTAGED_DIFF_END ==="
fi
