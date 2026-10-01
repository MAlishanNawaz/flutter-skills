# Screens and widgets

## Reuse first

```bash
grep -rlE "class \w*(Button|Card|Dialog|Sheet|Input|Field|Tile|Badge|Chip|Tip|Banner)\w* extends" lib | head -40
```

- Match on appearance and behaviour, not name. If a widget is close, add a parameter to it rather than making a near-copy.
- A widget goes into the shared folder only once **two or more** features use it. Until then, keep it in the feature folder or private (`_Header`).

## Layout rules

- Design for the narrowest column. Many mobile-first apps clamp web content to 400–600 px, so find the project's wrapper (`maxWidth`, `DesktopLayout`, `LayoutBuilder`) and use it on new screens. If there's none, use `ConstrainedBox(maxWidth:)` from a token.
- No fixed content widths. Use `Expanded`/`Flexible`, and add `maxLines` + `overflow` for text in a `Row`.
- Content that can grow goes in a scroll view. Primary CTAs sit **outside** it so they stay visible. Use `SafeArea` at the edges.
- Forms must still scroll when the keyboard is open. Don't set `resizeToAvoidBottomInset: false`.

## Behaviour that gets missed

- **Async CTA**: disable it while the action is in flight and drop repeat taps in the handler. A translucent overlay is not a guard unless it absorbs pointer events.
- **Loading inside a screen**: a skeleton shaped like the content, not a centred spinner.
- **Disabled state**: show it visually *and* make the control non-interactive (`onPressed: null`).
- **Icon-only buttons**: `tooltip:` (it doubles as the semantics label). Tap targets ≥ 48 dp.
- **Status by colour**: pair it with an icon or text.

## Structure

- Use small widget classes, not helper methods that return `Widget`. Classes can be `const` and rebuild on their own.
- Widgets render state and send intents. Logic, I/O and navigation decisions live in the state holder.
- Copy goes wherever the project keeps it (ARB, strings class). Check which one is actually wired up before adding keys.
- Generated models are nullable almost everywhere. Promote to a local or pattern-match; never write a `!` chain.

## Done

Run `scripts/check_tokens.sh` until it's clean. Then add a widget test (see [ui-testing.md](ui-testing.md)), run `scripts/format_changed.sh`, `flutter analyze` and `flutter test`.
