# Testing gotchas

Contents: fonts · harness · fakes · E2E · performance

The references are [../examples/profile_feature/test/](../examples/profile_feature/test/): fakes, `bloc_test`, widget tests, and `support/harness.dart`.

## Fonts: the Ahem trap

`flutter test` renders text in Ahem, which draws every glyph as a full square. Text measures wider than on a device, so overflow results mislead.

- If the app bundles a font, load it in `setUpAll` with `FontLoader('<family exactly as in pubspec>')`.
- If it doesn't, say so in a comment. A pass is still strict horizontally, but a failure may be a false alarm.

## Harness

- Pump the widget under the same parents it has in the app: the theme and its extensions, its providers, and its scroll and padding context. A card tested in a fixed-height box reports vertical overflows that can't happen inside a `ListView`.
- Set the size with `tester.view.physicalSize` and the text scale with `TextScaler.linear(2)`, then assert `tester.takeException()` is null. `pumpAt` in the harness does this.
- After writing a guard or overflow test, break the code once and watch the test fail. A test that has never failed proves little.
- Generate and compare goldens on one pinned platform (Linux CI); they differ by OS and font.

## Fakes

- A fake is a small in-memory implementation of your interface, with switches (`failWith`) and counters (`updateCalls`). Use a mock (`mocktail`) only when the interaction itself is what you're asserting.
- Wrap types you don't own (`Dio`, Firebase) in an interface and fake that, rather than mocking them.
- A `Completer` in a fake holds a request in flight, which is how you test double taps and closing a screen mid-request. Use `fake_async` for timers and debounce.

## E2E

- Patrol, not `integration_test`, when the flow touches native UI: permission dialogs, notifications, share sheets, WebViews, or going to the background and back.
- Find widgets by stable `Key`s, not by copy. Credentials come from CI secrets, not the test file.

## Performance

Measure in profile mode on a real, ideally low-end, device (`flutter run --profile` with DevTools). Debug-mode timings mean nothing. If you fix jank without a device, say it still needs confirming that way.

| In the code | Fix |
|---|---|
| `SingleChildScrollView` + `Column` + `.map()` over a long list | `ListView.builder`; `itemExtent`, or `prototypeItem` if row height scales with text |
| `Image.network` with no decode size | `cacheWidth: (logicalWidth * devicePixelRatio).round()`; set one dimension only, so the aspect ratio holds |
| Large blur or spread `BoxShadow` on list rows | A small shadow token (blur ≤ 4) |
| Filtering or lower-casing in `build()` | Compute when the inputs change; debounce search |
| JSON over ~100 KB on the UI isolate | `Isolate.run` |
