# Accessibility & theming

## Accessibility

Treat these as requirements, not polish. Check them with TalkBack/VoiceOver, the
**Accessibility Scanner** (Android) or **Accessibility Inspector** (iOS), and
`SemanticsDebugger` / `showSemanticsDebugger: true` while developing.

### Screen readers

- Icon-only buttons: `IconButton(tooltip: strings.close, ...)` (tooltip doubles as the label) or
  `Semantics(label:, button: true)`.
- Decorative images: `excludeFromSemantics: true` / `ExcludeSemantics`. Meaningful images:
  `semanticLabel`.
- Group a card's parts into one announcement with `MergeSemantics`, so it doesn't read as
  five separate fragments.
- Custom tappables (`GestureDetector`/`InkWell` around a `Row`) need `Semantics(button: true,
  label: …)`, or use a real button.
- Announce async results that aren't visible as focus changes: `SemanticsService.announce(...)`
  or a `liveRegion`.
- Reading order follows the tree. Use `OrdinalSortKey` only when the visual order really
  differs.

### Size and touch

- Tap targets of at least **48×48 dp**, even when the icon is 24. Keep the default
  `materialTapTargetSize` or pad the target.
- Support **text scaling to 2.0×** without clipping: no fixed heights on text containers, use
  `Flexible`/`Expanded` + `maxLines`/`overflow` where truncation is fine, and wrap rows that
  can't fit. Don't clamp `textScaler` globally to hide layout bugs.
- Layouts should still work in landscape and on split screens.

### Colour and contrast

- Text contrast **≥ 4.5:1** (≥ 3:1 for text ≥ 18 pt or bold ≥ 14 pt, and for icons and
  focus rings). Check token pairs once, in the token file, not one screen at a time.
- Never use **colour alone** for meaning. Pair error red with an icon and text, and status colours
  with labels.
- Disabled states must still be readable and announced as disabled.

### Motion, focus, input

- Respect `MediaQuery.disableAnimationsOf(context)`: skip or shorten non-essential animation.
- Keyboard/web: everything reachable by Tab, visible focus states, `FocusTraversalGroup` for
  logical order, Enter/Space activate.
- Forms: each field has a visible label (not just a placeholder), and errors are announced
  (see `forms.md`).

### Test it

```dart
testWidgets('meets a11y guidelines', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(harness(const ProfileScreen()));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
});
```

## Theming

### Tokens → ThemeData → ThemeExtension

Raw tokens (`design-tokens.md`) feed a `ThemeData` for each brightness. Material components then
pick up the right colours automatically, and custom tokens go through a `ThemeExtension` so
they switch with the theme:

```dart
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({required this.surfaceInfo, required this.surfaceWarning, required this.textMuted});
  final Color surfaceInfo, surfaceWarning, textMuted;

  static const light = AppPalette(surfaceInfo: Color(0xFFEEF1FF), surfaceWarning: Color(0xFFFFF7D6), textMuted: Color(0xFF5F5F5F));
  static const dark  = AppPalette(surfaceInfo: Color(0xFF1E2340), surfaceWarning: Color(0xFF3A3420), textMuted: Color(0xFFB0B0B0));

  @override
  AppPalette copyWith({Color? surfaceInfo, Color? surfaceWarning, Color? textMuted}) => AppPalette(
        surfaceInfo: surfaceInfo ?? this.surfaceInfo,
        surfaceWarning: surfaceWarning ?? this.surfaceWarning,
        textMuted: textMuted ?? this.textMuted,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) => other == null
      ? this
      : AppPalette(
          surfaceInfo: Color.lerp(surfaceInfo, other.surfaceInfo, t)!,
          surfaceWarning: Color.lerp(surfaceWarning, other.surfaceWarning, t)!,
          textMuted: Color.lerp(textMuted, other.textMuted, t)!,
        );
}

extension ThemeX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
```

```dart
ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: b);
  return ThemeData(
    colorScheme: scheme,
    fontFamily: AppText.fontFamily,
    extensions: [b == Brightness.light ? AppPalette.light : AppPalette.dark],
    // component themes: filledButtonTheme, inputDecorationTheme, cardTheme, …
  );
}

MaterialApp(theme: buildTheme(Brightness.light), darkTheme: buildTheme(Brightness.dark), themeMode: settings.themeMode)
```

Rules:

- Widgets read **semantic** colours (`context.colors.surface`, `context.palette.surfaceInfo`), not
  raw brand constants. That's what makes dark mode free.
- Style components once in **component themes** (`filledButtonTheme`, `inputDecorationTheme`)
  instead of passing styles at every call site.
- If the project only has static light-mode tokens (`AppColors.x`) and no dark mode, keep using
  them. Bring in a `ThemeExtension` only when dark mode or white-labelling is actually needed,
  and migrate one feature at a time.
- Check every screen in **both** brightnesses, and contrast for both palettes.

### Directionality and locale

- Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end` instead of left/right so
  RTL locales mirror correctly.
- Icons with direction (back arrows, chevrons) should flip in RTL. Material icons that need it
  do this automatically. Check custom SVGs.
- Format dates, numbers and currency with `intl` using the current locale. Never concatenate
  translated fragments; use ICU placeholders/plurals.

## Checklist

- [ ] Screen reader pass: every control labelled, groups merged, no decorative noise.
- [ ] 48 dp targets; layout holds at 2.0× text scale.
- [ ] Contrast checked for token pairs in light **and** dark.
- [ ] Meaning never shown by colour alone; reduced motion respected.
- [ ] Semantic colours from the theme; RTL-safe paddings and alignment.
