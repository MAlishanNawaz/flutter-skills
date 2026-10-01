# Testing Flutter UI

## Pump with the real theme

Screens often read theme extensions, custom app-bar themes, or providers/notifiers from
above them. If you pump them in a bare `MaterialApp`, they crash on a null check, or they render
with default styles and the test proves nothing.

Build a test harness that matches the app's root:

```dart
Widget harness(Widget child) => MultiProvider(        // or ProviderScope / BlocProvider, as the app uses
      providers: [/* the notifiers the screen reads from context */],
      child: MaterialApp(
        theme: AppTheme.light(),                      // the real theme, extensions included
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
```

## Load real fonts for layout tests

`flutter test` renders text in a placeholder font (Ahem) where every glyph is a full square.
Text comes out much wider than in the real font, so you get **fake overflows**, and you can miss
real ones. For any test that checks layout or overflow, load the brand font:

```dart
Future<void> loadAppFonts() async {
  final loader = FontLoader('MyBrandFont')            // must match the family name in pubspec.yaml
    ..addFont(rootBundle.load('assets/fonts/MyBrandFont-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/MyBrandFont-Bold.ttf'));
  await loader.load();
}

setUpAll(() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
});
```

## Test at real sizes

```dart
Future<void> pumpAt(WidgetTester tester, Widget w, Size size, {double textScale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
    child: harness(w),
  ));
  await tester.pumpAndSettle();
}

for (final size in const [Size(320, 640), Size(390, 844), Size(400, 900)]) {
  testWidgets('no overflow at $size', (tester) async {
    await pumpAt(tester, const MyScreen(), size, textScale: 1.3);
    expect(tester.takeException(), isNull);           // RenderFlex overflows surface here
  });
}
```

Cover the smallest supported phone, a common phone, the web content width, and a larger text
scale.

## What to assert

- **States**: loading (skeleton visible), empty, error, populated, disabled CTA.
- **Behaviour**: tapping the CTA fires the callback/event once, even with a fast double tap.
- **Content**: find by text or `Key`, not by widget index.
- **Semantics**: `expect(tester.getSemantics(find.byTooltip('Close')), …)` for icon-only buttons.

## Platform branches

`kIsWeb` is always `false` under `flutter test` on the VM, so code inside `if (kIsWeb)` never
runs there. Put web-only layout choices behind an injectable flag or parameter so tests can
cover both paths, or run `flutter test --platform chrome` for those cases.

## Goldens

Goldens are pixel-exact and break across OS/font rendering. Generate and compare them on one
pinned environment (usually CI). Don't commit goldens made on a laptop unless the team does that
on purpose.
