# Design tokens

## Find them

```bash
grep -rlE "class \w*(Colors|Palette|Spacing|Sizes|Radii|Text\w*|Tokens)\b|ThemeExtension<" lib
```

Read the token file once, end to end, and note the colour names, spacing scale, radius names and base text style.

## Mapping a raw value

1. **Grep the token file for the hex** (`grep -in "fff7b1" <tokens>`). Most "new" colours already exist under another name.
2. **Near-duplicates** (one or two hex steps apart) are designer drift. Use the existing token and mention the difference.
3. **Aliases** (`error` and `redDark` with the same hex): pick the name that matches the meaning.
4. **Off-scale spacing** (18, 22, 30): round to the nearest step and flag it for design. Never add `Spacing.cardGap = 18`, because one-off tokens break the scale for everyone.
5. **Text**: start from the closest existing style and carry the design's exact size, weight and line height with `copyWith` (`heading.copyWith(height: 24 / 18)`). Only spacing gets rounded; line height and font size don't. Keep one-widget overrides as a private `static final` in the widget file, not as new global styles in the token file.
6. **A colour that is genuinely new**: add it to the token file, named by role (`warningSurface`), not appearance (`lightYellow2`).

`height` is a multiplier: `lineHeightPx / fontSize`.

## What counts as raw

`Color(0x…)`, `Colors.<material>`, a bare `TextStyle(` (it drops the project font), numeric `SizedBox`/`EdgeInsets`/`circular()`, `IconData(0x…)`, and asset paths as strings. Literals are fine for a pill (`circular(999)`), `BoxShape.circle`, and `0`/`double.infinity`.

## Check

Run `scripts/check_tokens.sh` and fix every hit. Re-run it until it prints `clean`. Leave existing violations in files you didn't touch alone, and mention them instead.

## No token file?

Start from [tokens_template.dart](tokens_template.dart). Fill it from the Figma variables, or from the values the codebase already uses most:

```bash
grep -rhoE "Color\(0x[0-9a-fA-F]{8}\)" lib | sort | uniq -c | sort -rn | head -20
```

Migrate one feature at a time, as its own change.
