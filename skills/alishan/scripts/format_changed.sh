#!/usr/bin/env bash
# Formats only the Dart files changed on this branch, so formatting never touches unrelated files.
# Usage: format_changed.sh [--check] [files...]
#   --check   report files that need formatting without rewriting them (exit 1 if any)
# Line length, first found: `formatter: page_width` in analysis_options.yaml, $LINE_LENGTH,
# a `-l N` / `--line-length N` in CI workflows, CLAUDE.md, CONTRIBUTING.md, Makefile or melos.yaml,
# else inferred from the longest line in committed lib/ files, else 80.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

mode=()
if [ "${1:-}" = "--check" ]; then mode=(--output=none --set-exit-if-changed); shift; fi

if [ "$#" -gt 0 ]; then files=$(printf '%s\n' "$@"); else files=$("$here/changed_dart_files.sh") || exit 2; fi
if [ -z "$files" ]; then echo "format_changed: no changed Dart files"; exit 0; fi

width=""
if [ -f analysis_options.yaml ]; then
  width=$(sed -n 's/^ *page_width: *\([0-9][0-9]*\).*/\1/p' analysis_options.yaml | head -1)
fi
width="${width:-${LINE_LENGTH:-}}"
if [ -z "$width" ]; then
  width=$(cat .github/workflows/*.y*ml CLAUDE.md CONTRIBUTING.md Makefile melos.yaml 2>/dev/null \
    | grep -oE 'dart format[^\n]*(-l|--line-length)[ =]?[0-9]+' | grep -oE '[0-9]+$' | head -1 || true)
fi
# Still nothing: infer from the committed code. Pick the smallest common width (80-160) that
# fewer than 1% of lines exceed; a few long string literals or URLs shouldn't move the answer.
if [ -z "$width" ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  width=$(git ls-files 'lib/*.dart' | grep -vE '\.(g|freezed)\.dart$' | head -300 | xargs awk '
    { n++; l = length($0); for (i = 0; i < 5; i++) if (l > 80 + 20 * i) over[i]++ }
    END { if (n == 0) exit; for (i = 0; i < 5; i++) if (over[i] * 100 < n) { print 80 + 20 * i; exit } }
  ' 2>/dev/null || true)
fi
width="${width:-80}"
echo "format_changed: line length $width" >&2

dart=(dart)
if [ -f .fvmrc ] || [ -f .fvm/fvm_config.json ]; then dart=(fvm dart); fi

# shellcheck disable=SC2086
"${dart[@]}" format -l "$width" ${mode[@]+"${mode[@]}"} $files
