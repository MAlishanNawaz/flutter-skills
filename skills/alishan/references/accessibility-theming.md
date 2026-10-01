# Accessibility & theming

## Accessibility requirements

- **Labels**: icon-only buttons use `tooltip:`. Custom tappables use `Semantics(button: true, label:)`, or better, a real button. Use `MergeSemantics` for cards that should read as one sentence, and `ExcludeSemantics` for decorative images.
- **Targets**: at least 48×48 dp, even when the icon is 24.
- **Text scale**: the layout holds at **2.0×**. Never clamp `textScaler` globally to hide a layout bug.
- **Contrast**: text needs ≥ 4.5:1, or ≥ 3:1 for large text, icons and focus rings. Check token pairs once, in the token file.
- **Meaning**: never shown by colour alone.
- **Motion**: if `MediaQuery.disableAnimationsOf(context)` is set, skip non-essential animation.
- **Web/keyboard**: Tab order is logical (`FocusTraversalGroup`), focus is visible, and Enter/Space activate controls.

## Guideline test

Use this in every new screen's widget test:

```dart
final handle = tester.ensureSemantics();
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
await expectLater(tester, meetsGuideline(textContrastGuideline));
handle.dispose();
```

## Theming

- **Static light-only tokens** (`AppColors.x`) and no dark-mode requirement: keep using them, and don't introduce a theme layer unasked.
- **Dark mode or white-label needed**: put semantic colours in a `ThemeExtension` with a `light` and a `dark` instance, register both via `ThemeData(extensions: [...])`, and read them through a `context.palette` extension. Widgets then use semantic names only, and migrate one feature at a time.
- Style Material components once in the component themes (`filledButtonTheme`, `inputDecorationTheme`), not at each call site.
- Check contrast for both palettes.

## RTL & locale

- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, and `start`/`end`, never left/right.
- Custom directional SVGs (arrows, chevrons) need flipping in RTL.
- Format numbers, dates and currency with `intl` using the current locale, if it's in the pubspec. Never build sentences by concatenating translated fragments; use ICU placeholders and plurals.
