#!/usr/bin/env bash
# Lists .dart files changed on this branch (committed, staged, unstaged, untracked), one per line.
# Usage: changed_dart_files.sh [base-ref]   (default: merge-base with origin/HEAD, then main, then master)
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "changed_dart_files.sh: not a git repository; pass file paths to the calling script instead" >&2
  exit 2
fi

base="${1:-}"
if [ -z "$base" ]; then
  for candidate in origin/HEAD origin/main origin/master main master; do
    if git rev-parse --verify --quiet "$candidate" >/dev/null; then base="$candidate"; break; fi
  done
fi

{
  if [ -n "$base" ]; then
    git diff --name-only --diff-filter=ACMR "$(git merge-base "$base" HEAD)" -- '*.dart'
  fi
  git diff --name-only --diff-filter=ACMR HEAD -- '*.dart' 2>/dev/null || true
  git ls-files --others --exclude-standard -- '*.dart'
} | grep -vE '\.(g|freezed|gr|mocks)\.dart$|^lib/gen/' | sort -u | while read -r f; do [ -f "$f" ] && echo "$f"; done
