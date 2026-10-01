# Figma → Flutter

Figma output (Dev Mode, or the Figma MCP's generated code) is a **spec to translate**, never code to paste. It is full of hex values, px sizes, font families and absolute positions.

## Workflow

```
- [ ] 1. Pull: Figma:get_screenshot (visual), Figma:get_design_context (tree), Figma:get_variable_defs (variables)
- [ ] 2. Write the mapping table: every hex, gap, padding, radius, text style → token (see design-tokens.md)
- [ ] 3. Match Figma components to existing widgets by appearance, not layer name
- [ ] 4. Build; run scripts/check_tokens.sh until clean
- [ ] 5. Compare with the screenshot at phone width and web content width; widget-test both
- [ ] 6. In the summary, list rounded off-scale values, assumptions and missing states
```

If the Figma tools aren't available, ask for a screenshot plus the inspect values. If a whole-file fetch is too large, ask for a per-frame "Copy link to selection".

## Conversions

| Figma | Flutter |
|---|---|
| Line height 24 px on 18 px text | `height: 24 / 18` |
| Letter spacing 2 % | `letterSpacing: fontSize * 0.02` |
| Regular / Medium / Semibold / Bold | `w400` / `w500` / `w600` / `w700` |
| Vertical / horizontal auto-layout | `Column` / `Row`; gaps are `SizedBox(Spacing.x)`, or `spacing:` on Flutter 3.27+ |
| Fill container / hug | `Expanded` or `double.infinity` / the default size (`MainAxisSize.min`) |
| Space between | `MainAxisAlignment.spaceBetween` |
| Wrap | `Wrap(spacing:, runSpacing:)` |
| Absolute child | `Stack` + `PositionedDirectional`, **only** for true overlays (badges, floating CTAs) |
| Frame width 375/390 | Ignore it; the layout must flex |

## Traps

- Figma text colours often duplicate a token with a different name. Map by hex, not by Figma's style name.
- A badge at an absolute position can overlap a long title. Reserve trailing space or flag it.
- Mockups show the happy path only. Build loading, empty, error and disabled states, and say which ones you assumed.
- Prompt and design disagree (for example the text says "yellow" but the hex is blue): follow the more specific value and surface the conflict.
