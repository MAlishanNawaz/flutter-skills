# Building screens and widgets

## 1. Reuse before you build

Most apps past their first release already have the button, card, dialog, input or tip box
you're about to write. Look before you build:

```bash
ls lib/common/components lib/shared/widgets lib/widgets lib/components 2>/dev/null
grep -rlE "class \w*(Button|Card|Dialog|Sheet|Input|Field|Tile|Badge|Tip)\w* extends" lib | head -40
```

Match on **appearance and behaviour**, not names. `InfoTipsBox` and `HintBanner` might be the
same thing. If something is close, prefer adding a parameter to it over making a near-copy.

A widget goes into the shared folder only when **two or more** screens use it. A one-off widget
stays private (`_ProfileHeader`) in its screen file, or in a sibling file in that screen's folder.

## 2. Tokens everywhere

See `design-tokens.md`. Short version: colour, text, radius, spacing and icons all come from
named tokens, never literals.

```dart
Container(
  padding: const EdgeInsets.all(Spacing.lg),
  decoration: BoxDecoration(
    color: AppColors.warningSurface,
    borderRadius: BorderRadius.circular(Radii.card),
  ),
  child: Text(
    strings.uploadHint,
    style: AppText.base.copyWith(fontSize: 14, color: AppColors.textPrimary),
  ),
)
```

## 3. Copy

No user-facing string literals in a widget tree. Put copy wherever the project keeps it: ARB
files via `AppLocalizations.of(context)`, or a central strings class. Check which one is
**actually in use** before adding keys. Some repos have an ARB setup that nothing reads any more.

## 4. Layout: design for the narrowest column

- **No fixed widths** for content. Use `Expanded`, `Flexible`, `double.infinity`, or
  `ConstrainedBox(maxWidth: …)`.
- **Web/desktop**: many mobile-first apps clamp web content to a narrow column (often 400–600 px).
  Find the project's wrapper (search for `maxWidth`, `LayoutBuilder`, `DesktopLayout`) and wrap new
  full screens in it.
- **Overflow**: a `Column` that can grow goes inside a `SingleChildScrollView` (or use a
  `ListView`/`CustomScrollView`). Long text in a `Row` gets `Expanded` + `overflow`/`maxLines`.
- **Edges**: use `SafeArea` for anything that touches the top or bottom of the screen. Bottom CTAs sit
  outside the scroll view so they stay visible.
- **Text scaling**: check the screen at 1.3× text scale. Labels that only fit at 1.0× will break.
- **Keyboard**: forms need to scroll when the keyboard opens. Don't set
  `resizeToAvoidBottomInset: false` unless you handle it another way.

## 5. State: follow the project

Use the state management the project already has (bloc, provider, Riverpod, etc.). Keep widgets
dumb: read state in, send events/callbacks out, and keep business logic out of `build()`.
Split a large `build()` into small widgets (classes, not helper methods returning `Widget`) so
rebuilds stay local and the tree is readable.

## 6. Null safety in the tree

Generated models (Amplify, OpenAPI, GraphQL codegen) are nullable almost everywhere. Avoid `!` chains:

```dart
// ✅
final name = profile?.firstName ?? '';
final course = state.course;
if (course != null) { /* course is promoted to non-null here */ }

// ❌
profile!.firstName!.toUpperCase()
```

## 7. Interaction details that get missed

- **Double taps**: guard buttons that submit (disable while in flight, or a tap-guard wrapper).
  A loading overlay is not a guard unless it really blocks pointer events.
- **Loading states**: use a skeleton/shimmer shaped like the real content, not a centred spinner,
  for anything that loads inside a screen.
- **Disabled state**: show it (greyed token colour) *and* make it non-interactive.
- **Semantics**: icon-only buttons need a `tooltip` or `Semantics(label:)`.
- **Tap targets**: at least 48×48.

## 8. Before you call it done

```bash
dart format .
flutter analyze
flutter test
```

Use `fvm flutter …` if the project pins its Flutter version. Then go through the checklist in
`SKILL.md`, and add a changelog entry if the project keeps one.
