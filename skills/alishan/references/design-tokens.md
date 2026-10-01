# Design tokens

Tokens are the named values a design system is built from. In Flutter they normally live in one
file (`design_info.dart`, `app_colors.dart`, `tokens.dart`, a `ThemeExtension`) as static
constants. Every visual value in a widget should resolve to one.

## Find them first

```bash
grep -rlE "class \w*(Colors|Palette)\b" lib
grep -rlE "class \w*(Spacing|Sizes|Gaps|Insets)\b" lib
grep -rlE "class \w*(TextStyles|Typography|Style)\b|TextTheme\(" lib
grep -rl "ThemeExtension<" lib
```

Read the file(s) end to end once. Write down the colour names, the spacing scale and the base
text style. Everything below assumes you know them.

## Colours

Before writing any hex, **grep the token file for it**. The colour usually already exists
under a name.

```bash
grep -rin "fff7b1" lib/path/to/tokens.dart
```

```dart
// ✅
color: AppColors.surface
color: AppColors.grey[700]

// ❌
color: const Color(0xffF6F6F6)
color: Colors.grey.shade600       // a Material palette colour is still a raw value here
```

If the colour really isn't there, **add a named constant** to the token file, named for what
it does (`warningSurface`), not what it looks like (`lightYellow2`). Then use it. Never inline
the hex "just this once".

Watch for **aliases**. Two names for the same hex (e.g. `error` and `redDark`) happen a lot.
Use the name that fits the meaning (`error` for an error state).

## Text styles

Use the project's **base style plus `copyWith`**, or its named text-theme slots. A bare
`TextStyle()` drops the project font family, letter spacing and default colour.

```dart
// ✅
style: AppText.base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary)
style: Theme.of(context).textTheme.titleMedium

// ❌
style: const TextStyle(fontSize: 16, fontFamily: 'MyBrandFont')
```

A typical type ramp. Confirm the real one against the project or the Figma file:

| Role | fontSize | fontWeight |
|---|---|---|
| Screen title | 24 | w700 |
| Section heading | 18 | w700 |
| Body / label | 16 | w400 |
| Small body | 14 | w400 |
| Caption | 12 | w400 |

`height` in Flutter **multiplies** fontSize. It is not a pixel value:
`height = lineHeightPx / fontSize` (24 px line on 16 px text → `height: 1.5`).

## Spacing

Most design systems use a 4-point scale. Map gaps and padding onto the project's named steps:

```dart
// a common scale
Spacing.xs   // 4
Spacing.sm   // 8
Spacing.md   // 12
Spacing.lg   // 16
Spacing.xl   // 24
Spacing.xxl  // 40
```

```dart
// ✅
const SizedBox(height: Spacing.lg)
padding: const EdgeInsets.symmetric(horizontal: Spacing.xl)

// ❌
const SizedBox(height: 16)
```

An off-scale value (18, 22, 30) is nearly always a design slip. Round it to the nearest token
and mention it in the PR. Don't invent `Spacing.lgPlus`.

## Radius, elevation, icons

- **Radius**: use the named radius (`Radii.card`, `AppSize.borderRadius`). Literals are fine only
  for a pill (`BorderRadius.circular(999)`) or a `BoxShape.circle`.
- **Shadows/elevation**: reuse the project's shadow constants. Don't paste new `BoxShadow` values
  into each widget.
- **Icons**: use the project's icon font class or generated asset accessors (`flutter_gen`'s
  `Assets.svg.foo`). Never a raw `IconData(0x…)`, and never asset paths as string literals.

## No token file yet?

Start from `tokens_template.dart`. Fill it from the Figma file's variables
(`get_variable_defs` if the Figma MCP is available) or by collecting the hex values already used
in the codebase:

```bash
grep -rhoE "Color\(0x[0-9a-fA-F]{8}\)" lib | sort | uniq -c | sort -rn
```

Then move call sites over one at a time, the most-used values first.

## Review grep

Run this on your diff before you push:

```bash
git diff --unified=0 origin/HEAD -- '*.dart' | grep -E "^\+" | grep -nE "Color\(0x|TextStyle\(|SizedBox\((height|width): [0-9]|circular\([0-9]"
```

Every hit needs a token or a good reason.
