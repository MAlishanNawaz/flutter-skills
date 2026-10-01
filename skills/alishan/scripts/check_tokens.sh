#!/usr/bin/env bash
# Flags raw design values (hex colours, bare TextStyle, Material palette colours, numeric gaps,
# paddings, radii and fixed content widths of 100+) in Dart files, so they can be replaced with the project's tokens.
#
# Usage:
#   check_tokens.sh                 # checks .dart files changed on this branch (needs git)
#   check_tokens.sh lib/a.dart ...  # checks the given files
# Env:
#   TOKENS_PATH  path fragment of the token/theme file(s) to skip (default: auto-detected)
#
# Exit: 0 = clean, 1 = findings (printed as file:line: rule | code), 2 = usage error.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

if [ "$#" -gt 0 ]; then
  files=$(printf '%s\n' "$@")
else
  files=$("$here/changed_dart_files.sh") || exit 2
fi
files=$(printf '%s\n' "$files" | grep -E '^lib/.*\.dart$' || true)
if [ -z "$files" ]; then echo "check_tokens: no changed lib/ Dart files"; exit 0; fi

# The token file is the one place raw values belong. Auto-detect it unless TOKENS_PATH is set.
skip="${TOKENS_PATH:-}"
if [ -z "$skip" ]; then
  skip=$(grep -rlE "abstract( final)? class \w*(Colors|Palette|Spacing|Tokens)\b|class \w*(Colors|Palette)\b|extends ThemeExtension<" lib 2>/dev/null | tr '\n' '|' | sed 's/|$//')
fi

rules=(
  'raw hex colour|Color\(0x[0-9A-Fa-f]{6,8}\)'
  'Material palette colour|Colors\.(red|pink|purple|deepPurple|indigo|blue|lightBlue|cyan|teal|green|lightGreen|lime|yellow|amber|orange|deepOrange|brown|grey|blueGrey|black[0-9]*|white[0-9]*)\b'
  'bare TextStyle|[^.A-Za-z]TextStyle\('
  'numeric gap|SizedBox\((height|width): *[0-9]'
  'numeric padding|EdgeInsets(Directional)?\.(all|symmetric|only|fromLTRB|fromSTEB)\([^)]*[0-9]'
  'fixed content width (use Expanded/Flexible or a max-width token)|[^A-Za-z](width|minWidth): *[1-9][0-9]{2,}(\.[0-9]+)?[,) ]'
  'numeric radius|(BorderRadius|Radius)\.circular\( *([0-9]|[1-9][0-9]?)(\.[0-9]+)? *\)'
)

found=0
while read -r f; do
  [ -f "$f" ] || continue
  if [ -n "$skip" ] && printf '%s' "$f" | grep -qE "$skip"; then continue; fi
  for r in "${rules[@]}"; do
    name="${r%%|*}"; pattern="${r#*|}"
    # Ignore comment lines; a value inside a comment is documentation, not styling.
    hits=$(grep -nE "$pattern" "$f" | grep -vE '^[0-9]+: *//' || true)
    if [ -n "$hits" ]; then
      found=1
      printf '%s\n' "$hits" | while IFS= read -r h; do
        printf '%s:%s: %s | %s\n' "$f" "${h%%:*}" "$name" "$(printf '%s' "${h#*:}" | sed 's/^ *//')"
      done
    fi
  done
done <<< "$files"

if [ "$found" -eq 0 ]; then echo "check_tokens: clean"; fi
exit "$found"
