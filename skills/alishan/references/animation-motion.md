# Animation & motion

Motion should **explain** something: where an element came from, what changed, what to do next.
Keep it short (150–300 ms for UI, up to ~500 ms for big transitions), use easing, and never
block input.

## Pick the simplest tool that works

| Need | Use |
|---|---|
| A property changes (size, colour, padding, opacity, alignment) | **Implicit**: `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, `AnimatedPadding`, `AnimatedDefaultTextStyle` |
| Swap one widget for another | `AnimatedSwitcher` (give each child a distinct `key`) |
| Smoothly resize to fit content | `AnimatedSize` |
| A custom value from A to B | `TweenAnimationBuilder` |
| Repeat, sequence, scrub, or drive from a gesture | **Explicit**: `AnimationController` + `*Transition` widgets |
| An element continues across screens | `Hero` |
| Lists inserting/removing items | `AnimatedList` / `SliverAnimatedList` |
| Container that expands into a page | `OpenContainer` (`animations` package) |
| Designer-made illustrations | Rive or Lottie |

Start implicit. Use explicit animations only when you need control.

## Motion tokens

Keep durations and curves next to the design tokens, so motion stays consistent:

```dart
abstract final class Motion {
  static const fast = Duration(milliseconds: 150);    // hover, press, small fades
  static const medium = Duration(milliseconds: 250);  // most UI changes
  static const slow = Duration(milliseconds: 400);    // page-level, large surfaces
  static const enter = Curves.easeOutCubic;           // things arriving
  static const exit = Curves.easeInCubic;             // things leaving
  static const standard = Curves.easeInOutCubic;
}
```

## Implicit examples

```dart
AnimatedContainer(
  duration: Motion.medium,
  curve: Motion.standard,
  padding: EdgeInsets.all(selected ? Spacing.lg : Spacing.md),
  decoration: BoxDecoration(
    color: selected ? AppColors.infoSurface : AppColors.surface,
    borderRadius: BorderRadius.circular(Radii.card),
  ),
  child: child,
)

AnimatedSwitcher(
  duration: Motion.medium,
  child: switch (state) {
    Loading() => const ListSkeleton(key: ValueKey('loading')),
    Loaded(:final items) => ItemList(key: const ValueKey('loaded'), items: items),
    Failed(:final error) => ErrorView(key: const ValueKey('error'), error: error),
  },
)
```

## Explicit animations

```dart
class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  late final _scale = Tween(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _c, curve: Motion.standard));

  @override
  void dispose() {
    _c.dispose();                                     // always
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}
```

- Use `*Transition` widgets (`FadeTransition`, `SlideTransition`, `ScaleTransition`,
  `SizeTransition`) or `AnimatedBuilder` with a `child:`. Don't call `setState` on every tick.
- Use `vsync` so animations pause off-screen. Use `TickerProviderStateMixin` for more than one
  controller.
- Stagger with `Interval(start, end)` curves on one controller, not several timers.
- Gesture-driven: update `controller.value` in `onPanUpdate`, then `fling`/`animateTo` on
  release, so it follows the finger.

## Page transitions

- Set them once in the theme (`pageTransitionsTheme`) or per route with `CustomTransitionPage`
  in `go_router`. Don't mix ad-hoc transitions screen by screen.
- Platform defaults (Cupertino slide on iOS, Material fade-through/zoom on Android) usually feel
  best.
- `Hero`: same `tag` on both screens, similar shapes, and use `flightShuttleBuilder` if the
  shapes differ (e.g. avatar → header).

## Respect the user

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);
final duration = reduceMotion ? Duration.zero : Motion.medium;
```

- With reduced motion: no parallax, no auto-playing loops, no big zooms. Use fades or
  instant changes.
- Never animate in a way that delays the user's next action. Tapping during an animation should
  work.
- Avoid infinite animations on screens left open for a long time. They drain battery and
  make `pumpAndSettle` time out in tests (use `pump(duration)` there).

## Performance

- Animate **transform and opacity**. They're cheap. Animating layout (size, padding) of large
  subtrees or long lists is expensive.
- Wrap a busy animated region in a `RepaintBoundary` so it doesn't repaint its neighbours, and
  check in DevTools.
- Avoid animating `Opacity` widgets over big subtrees. Use `FadeTransition`, which composites
  without `saveLayer` in most cases.
- Profile on a low-end Android device in profile mode.

## Checklist

- [ ] Simplest tool used (implicit before explicit); durations and curves from motion tokens.
- [ ] Every controller disposed; uses `vsync`.
- [ ] Reduced motion respected; input never blocked.
- [ ] Transitions consistent across the app; Hero tags match.
- [ ] Smooth in profile mode on a low-end device.
