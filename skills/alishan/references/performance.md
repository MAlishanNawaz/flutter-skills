# Performance

Target: build plus raster under **16 ms per frame** (60 Hz), or 8 ms on 120 Hz screens. Measure
before optimising: **profile mode on a real device** (`flutter run --profile`), DevTools
Performance and CPU profiler, and "Track widget rebuilds". Debug mode numbers mean nothing.

## Rebuild less

- Make everything `const` that can be (`prefer_const_constructors` lint). A `const` subtree is
  skipped on rebuild.
- **Push state down.** Put the changing part in its own small widget, so `setState` /
  `select` rebuilds that leaf rather than the screen.
- Use **widget classes, not helper methods** returning `Widget`. Classes get their own element
  and can be `const`.
- Narrow subscriptions: `context.select`, `buildWhen`, `Selector`, `ref.watch(p.select(...))`.
- Pass a `child:` into `AnimatedBuilder` / `ValueListenableBuilder` / `Consumer` for the static
  part, so it isn't rebuilt on every tick.
- Give models value equality (`freezed`/`==`) so "same" state doesn't trigger a rebuild.

## Lists and scrolling

- Use `ListView.builder` / `.separated` / `SliverList` for anything longer than a screen. Never
  `Column` + `.map()` inside a `SingleChildScrollView` for long data.
- Set `itemExtent` or `prototypeItem` when rows have a fixed height, which makes layout much
  cheaper.
- Use `CustomScrollView` + slivers to mix headers, grids and lists. Avoid nested scroll views
  with `shrinkWrap: true` (it lays out every child).
- Use stable `Key`s (`ValueKey(item.id)`) when items can be reordered, inserted or removed.
- Paginate with a scroll-position trigger and a "loading more" sliver. Don't load everything.

## Images

- Decode at display size: `Image.network(url, cacheWidth: (w * dpr).round())` or
  `ResizeImage`. A 4000 px photo in an 80 px avatar uses a lot of memory.
- Use `cached_network_image` (or equivalent) for remote images, with a placeholder that has
  the same dimensions so nothing shifts.
- `precacheImage` for hero images on the next screen.
- Prefer SVG/vector or the icon font for icons; use compressed WebP for photos and illustrations.

## Expensive painting

- Avoid `Opacity`, `ClipPath` and `saveLayer` effects on large or animating subtrees. Use
  `FadeTransition`/`AnimatedOpacity`, `ClipRRect`, or bake the effect into an asset.
- `BackdropFilter` and large blurred shadows are expensive. Use them sparingly and never in list
  rows.
- Wrap independently animating regions in a `RepaintBoundary` (check in DevTools that it helps).
- `RepaintBoundary` around list items is already added by `ListView`; don't double-wrap.

## Keep the UI isolate free

- JSON over ~100 KB, image processing, crypto, large sorting/filtering: use `compute()` /
  `Isolate.run()`.
- Don't do synchronous file I/O or `SharedPreferences` reads in `build`.
- Debounce search/filter input (≈300 ms) before hitting the network.

## Startup

- Do the least possible before `runApp`: only what the first frame needs. Initialise analytics,
  remote config and so on in parallel or after the first frame.
- Defer heavy screens and packages (`deferred as` on web).
- Use the native splash only as long as the real first screen needs.

## Memory and lifecycle

- Dispose every controller, `StreamSubscription`, `AnimationController`, `FocusNode`, `Timer`.
- Cancel in-flight work when a screen closes (check `mounted`/`isClosed` after awaits).
- Watch DevTools Memory for growth when you open and close a screen repeatedly.

## Web specifics

- Large lists and long text get expensive on web. Test with real data volumes.
- Check the bundle size (`flutter build web --analyze-size`) and tree-shake icons (default
  in release).

## Checklist

- [ ] Profiled on a real device in profile mode; no frames over budget on key flows.
- [ ] Long lists are lazy, with stable keys.
- [ ] Images decoded near display size, cached, with fixed-size placeholders.
- [ ] No heavy work on the UI isolate; search debounced.
- [ ] Everything disposed; no growth after open/close cycles.
