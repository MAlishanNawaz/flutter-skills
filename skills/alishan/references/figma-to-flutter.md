# Figma → Flutter

Figma's code export and the Figma MCP tools (`get_design_context`, `get_screenshot`,
`get_variable_defs`) give you generic code full of **hardcoded hex, px values and font
families**. Treat that output as a spec to translate, never as code to paste.

## Workflow

1. **Pull the design.**
   - `get_screenshot`: the visual target.
   - `get_design_context`: node tree, auto-layout, sizes.
   - `get_variable_defs`: the Figma variables the frame uses. These often map one-to-one onto
     code tokens.
   If the MCP isn't available, ask for a screenshot plus the inspect panel values. A
   per-frame "Copy link to selection" link works better than a whole-file link, which can be
   too big to fetch.
2. **Build a mapping table** from the project's token file (see `design-tokens.md`):
   Figma hex → colour token, spacing values → spacing steps, text layers → base style + overrides,
   radius → radius token. Write it down before writing any widgets.
3. **Find the existing widgets.** Most Figma components (buttons, inputs, cards, tip boxes)
   already exist in the codebase. Match by appearance, not by Figma layer name
   (see `ui-components.md` §1).
4. **Build the screen** using only mapped tokens and existing widgets.
5. **Verify** against the screenshot at phone width and at the web content width, then analyze.

## Mapping rules

### Fills

Every Figma hex goes through the token file:

```bash
grep -rin "3D5AFE" lib/path/to/tokens.dart
```

No match: check for a near-duplicate (designers drift by one or two hex steps), then add a
**named** constant. Never inline it.

### Text

The base style already sets the font family. Carry over only **size, weight, line height,
letter spacing and colour**:

```dart
style: AppText.base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary)
```

- Line height: `height = lineHeightPx / fontSize`.
- Letter spacing: Figma `%` → Flutter logical px: `letterSpacing = fontSize * percent / 100`.
- Figma weight names → `FontWeight`: Regular w400, Medium w500, Semibold w600, Bold w700.

### Auto-layout

| Figma | Flutter |
|---|---|
| Vertical auto-layout | `Column` |
| Horizontal auto-layout | `Row` |
| Gap | `SizedBox(height/width: Spacing.x)` between children (or `spacing:` on newer Flutter) |
| Padding | `Padding` / container `padding` with spacing tokens |
| Fill container | `Expanded` / `double.infinity` |
| Hug contents | default (`mainAxisSize: MainAxisSize.min` where needed) |
| Wrap | `Wrap` with `spacing` / `runSpacing` |
| Space between | `MainAxisAlignment.spaceBetween` |

Round off-scale values to the nearest spacing token and mention it in the PR.

### Radius, icons, images

- Radius → the radius token; pill → `circular(999)`; circle → `BoxShape.circle`.
- Icons → the project's icon font if the glyph is there; otherwise export SVG to `assets/`,
  regenerate asset accessors (`flutter_gen`/`fluttergen`), and use the generated accessor.
  Never put asset paths in string literals.
- Images → export at 2× and 3× (or SVG), and use generated accessors.

## What Figma output gets wrong

- **Fixed frame widths** (375/390 px). Convert to flexible layout. The app also runs at
  other widths (big phones, clamped web columns).
- **Absolute positioning.** `Stack` + `Positioned` everywhere should become `Column`/`Row`, unless
  the design really is an overlay (badge on avatar, floating CTA).
- **Hardcoded copy.** Every string becomes a localized/strings-class entry.
- **`TextStyle(fontFamily: …)`.** Use the base style.
- **Lookalike components.** If a Figma component matches an existing widget, use that widget,
  even when the layer name differs.
- **Missing states.** Mockups often show only the happy path. Ask for, or build sensibly,
  loading, empty, error and disabled states, plus long-text and large-font cases.

## Definition of done

- [ ] Mapping table drafted; no raw hex, bare `TextStyle(`, or magic numbers in the diff.
- [ ] Existing widgets reused where Figma components match.
- [ ] Compared to the screenshot at phone width and at the web content width.
- [ ] Copy externalised; assets generated, not referenced as string paths.
- [ ] Off-scale values and missing states mentioned in the PR description.
