# Performance

**Measure first.** Use profile mode on a real, ideally low-end, device (`flutter run --profile`) with DevTools Performance and "Track widget rebuilds". Debug-mode numbers mean nothing. Whenever you fix jank without a device, tell the user to confirm it this way.

## Usual causes, in order of how often they show up

| Symptom in code | Fix |
|---|---|
| `SingleChildScrollView` + `Column` + `.map()` over a long list | `ListView.builder` / `SliverList`; add `itemExtent`, or `prototypeItem` if row height scales with text |
| `Image.network` with no decode size | `cacheWidth: (logicalWidth * dpr).round()` (or `cacheHeight`; set one, so the aspect ratio holds); a fixed-size placeholder and `errorBuilder` |
| Big `BoxShadow` blur/spread, `BackdropFilter` or `Opacity` on list rows | A small shadow token (blur ≤ 4); `FadeTransition` instead of `Opacity`; no blur in rows |
| Filtering, sorting or lower-casing in `build()` | Compute once when the inputs change, and debounce search by about 300 ms |
| `setState` high in the tree | Push state down into a small widget, or `select` / `buildWhen` |
| Helper methods returning widgets | Widget classes with `const` constructors |
| `shrinkWrap: true` nested scroll views | One `CustomScrollView` with slivers |
| JSON over ~100 KB, crypto or image work on the UI isolate | `Isolate.run` / `compute` |

Use stable keys (`ValueKey(item.id)`) whenever items can be reordered or removed.

## Startup & memory

- Before `runApp`, do only what the first frame needs. Initialise analytics and remote config after it.
- Dispose every controller, subscription, `FocusNode` and `Timer`. Watch DevTools Memory over repeated open/close cycles of a screen.

## Web

Long lists and text are expensive on web. Check with `flutter build web --analyze-size`, and use deferred imports for heavy screens.
