# UI tests

## Harness

Pump the widget under the **same parents it has in the app**: the real theme (with its extensions), the providers or blocs it reads, localization delegates, and the real scroll and padding context. A card tested in a bare, fixed-height box reports vertical overflows that can't happen in a `ListView`. A bare `MaterialApp` hides missing-theme crashes.

## Fonts: the Ahem trap

`flutter test` renders text in Ahem, which draws every glyph as a full square. That makes text wider than any real font, so tests report false overflows and the layout differs from the device.

- **The project bundles a brand font**: load it in `setUpAll`, using the family name exactly as it appears in `pubspec.yaml`:
  ```dart
  setUpAll(() async {
    final loader = FontLoader('BrandFont')..addFont(rootBundle.load('assets/fonts/BrandFont-Regular.ttf'));
    await loader.load();
  });
  ```
- **No bundled font**: say so in the test file's comment. Ahem is stricter horizontally, so a pass is meaningful, but a failure may be false.

## Sizes and text scale

```dart
for (final size in const [Size(320, 568), Size(390, 844), Size(400, 900)]) {
  for (final scale in const [1.0, 2.0]) {
    testWidgets('fits at $size, ${scale}x', (tester) async {
      tester.view..physicalSize = size..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(harness(const MyScreen(), textScale: scale));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);          // RenderFlex overflows surface here
    });
  }
}
```

Cover the smallest supported phone, a common phone and the web content width, each at 2× text.

## Make tests prove something

- After writing an overflow or guard test, **break the code on purpose once** (remove the wrap or the guard) and confirm the test fails. Then restore it.
- Find widgets by `Key` or semantics, not by index.
- Add the accessibility guideline checks from [accessibility-theming.md](accessibility-theming.md).

## Goldens

Pin goldens to one platform (Linux CI) with real fonts loaded, and update them in their own commit. Don't commit goldens generated on a laptop.
