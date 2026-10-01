# UI gotchas

Contents: tokens · Figma · layout · forms · accessibility and theming · motion

## Tokens

- Before adding a colour, grep the token file for its hex. Most "new" colours already exist, under another name or a hex step or two away. Use the token and mention the difference.
- When two token names share a hex (`error` and `redDark`), pick the one that matches the meaning.
- Spacing that's off the scale (18, 22, 30) gets rounded to the nearest step and flagged for design. Line height and font size are carried exactly with `copyWith`, for example `heading.copyWith(height: 24 / 18)`.
- `height` is a multiplier: `lineHeightPx / fontSize`.
- A bare `TextStyle(` drops the project's font family and defaults.
- A one-widget style override is a private `static final` in that widget's file, not a new global style.
- Literals that are fine to keep: `circular(999)` for pills, `BoxShape.circle`, `0` and `double.infinity`.
- No token file yet? Start from [../templates/tokens_template.dart](../templates/tokens_template.dart).

## Figma

- Dev Mode output and the Figma MCP's generated code are specs to translate, not code to paste. Fetch the screenshot, the node tree and the variables. If a whole-file fetch is too large, ask for a per-frame "Copy link to selection".
- Map colours by hex, not by Figma style name; the names often differ from the token names.
- Letter spacing of 2 % means `fontSize * 0.02`. Weights map Regular/Medium/Semibold/Bold to `w400`/`w500`/`w600`/`w700`.
- Ignore the frame width (375 or 390). Absolute positioning (`Stack` + `PositionedDirectional`) is only for true overlays.
- An absolutely positioned badge overlaps long titles. Reserve trailing space for it and test with a long title.
- Mockups show the happy path. Call out the loading, empty, error and disabled states you had to assume.
- When the prompt and the design disagree (the text says "yellow" but the hex is blue), follow the more specific value and point out the conflict.

## Layout

- Mobile-first apps that also ship on web often clamp content to 400–600 px. If the project has that wrapper (search for `maxWidth`, `DesktopLayout` or `LayoutBuilder`), use it on new screens.
- Put primary CTAs outside the scroll view so they stay visible. Turning off `resizeToAvoidBottomInset` hides the focused field behind the keyboard.
- Helper methods that return `Widget` can't be `const` and rebuild with their parent. Use small widget classes instead.
- Generated models (Amplify, OpenAPI, GraphQL) are nullable everywhere. Promote to a local or pattern-match instead of chaining `!`.
- Some repos have both ARB files and a strings class. Check which one is actually wired up before adding keys.

## Forms

The reference is [../examples/profile_feature/lib/features/profile/presentation/widgets/rename_form.dart](../examples/profile_feature/lib/features/profile/presentation/widgets/rename_form.dart), with its test.

- **Double submit.** Disabling the button doesn't stop two taps in the same frame. What stops them is a flag checked and set before the first `await`, or the state holder dropping the intent (`if (saving) return;`, bloc's `droppable()`). An `IgnorePointer` or translucent overlay is no guard at all. Route the keyboard "done" action through the same path.
- **Error timing.** `AutovalidateMode.always` shows errors from the first keystroke. Start with validation disabled and switch to `onUserInteraction` after the first submit. `AutovalidateMode.onUnfocus` doesn't exist in Flutter 3.24.
- **Naming.** A validator named `required` clashes with `@required` from package:meta, which `material.dart` re-exports.
- **Labels.** Fields need visible labels; a hint disappears once the user types. Keep the entered values when a request fails.

## Accessibility and theming

- Icon-only buttons: `tooltip:` doubles as the screen-reader label. Cards read as separate fragments unless wrapped in `MergeSemantics`.
- Check layouts at 2× text. Clamping `textScaler` app-wide hides layout bugs instead of fixing them.
- Pair status colours with an icon or text.
- Check contrast once per token pair, not screen by screen.
- `meetsGuideline(androidTapTargetGuideline / labeledTapTargetGuideline / textContrastGuideline)` is cheap to add to a screen's widget test.
- RTL: use `EdgeInsetsDirectional`, `AlignmentDirectional` and `PositionedDirectional`. Directional SVGs need flipping.
- Dark mode or white-labelling: put semantic colours in a `ThemeExtension` with `light` and `dark` instances, and read them through a `context.palette` extension. If the app has neither requirement, keep the existing static tokens.

## Motion

- Endless animations (shimmer, spinners) make `pumpAndSettle` time out. Use `pump(duration)` in those tests.
- `AnimatedSwitcher` children of the same type need distinct `key`s, or they don't animate.
- Use `FadeTransition` rather than `Opacity` over large subtrees.
- `Hero` between different shapes needs a `flightShuttleBuilder`.
- When `MediaQuery.disableAnimationsOf(context)` is true, use `Duration.zero` or a plain fade.
