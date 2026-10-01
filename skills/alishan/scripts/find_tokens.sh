#!/usr/bin/env bash
# Prints the project's design-token / theme files, one per line. The single source of truth for
# "where are the tokens": check_tokens.sh skips exactly these files, and the guides point here.
# Usage: find_tokens.sh [dir]   (default: lib)
set -euo pipefail
grep -rlE 'class \w*(Colors|Palette|Spacing|Sizes|Radii|Tokens|Typography|TextStyles)\b|abstract( final)? class \w*Text\b|extends ThemeExtension<' "${1:-lib}" 2>/dev/null || true
