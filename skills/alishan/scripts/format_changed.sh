#!/usr/bin/env bash
# Formats only the Dart files changed on this branch, so formatting never touches unrelated files.
# Usage: format_changed.sh [--check] [files...]
#   --check   report files that need formatting without rewriting them (exit 1 if any)
# Line length, first found: `formatter: page_width` in analysis_options.yaml, $LINE_LENGTH,
# a `-l N` / `--line-length N` in CI workflows, CLAUDE.md, CONTRIBUTING.md, Makefile or melos.yaml, else 80.
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
width="${width:-80}"
echo "format_changed: line length $width" >&2

dart=(dart)
if [ -f .fvmrc ] || [ -f .fvm/fvm_config.json ]; then dart=(fvm dart); fi

# shellcheck disable=SC2086
"${dart[@]}" format -l "$width" ${mode[@]+"${mode[@]}"} $files
