# Animation & motion

## Choose the simplest tool

| Need | Use |
|---|---|
| A property changes | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPadding`, `AnimatedAlign` |
| Swap widgets (for example between state branches) | `AnimatedSwitcher`, where each child has a distinct `key` |
| Resize to content | `AnimatedSize` |
| A custom value from A to B | `TweenAnimationBuilder` |
| Loop, sequence, or drive from a gesture | `AnimationController` + `*Transition` widgets |
| An element carries across screens | `Hero` (matching `tag`; `flightShuttleBuilder` if the shapes differ) |
| List insert/remove | `AnimatedList` / `SliverAnimatedList` |

## Motion tokens

Keep these next to the design tokens rather than writing a duration at each call site:

```dart
abstract final class Motion {
  static const fast = Duration(milliseconds: 150);   // press, hover, small fades
  static const medium = Duration(milliseconds: 250); // most UI changes
  static const slow = Duration(milliseconds: 400);   // page-level
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
}
```

## Rules

- **Reduced motion**: `MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium`.
- **Never block input.** A tap during an animation must still work.
- **Explicit animations**: `vsync: this`, dispose the controller, and drive from `AnimatedBuilder(child:)` or a `*Transition`. Never call `setState` per tick.
- **Stagger** with `Interval` curves on one controller, not several timers.
- **Animate transform and opacity.** Animating the layout of large subtrees or list rows is expensive. Use `FadeTransition` rather than `Opacity` over big subtrees.
- **Page transitions**: set them once (`pageTransitionsTheme`, or go_router's `CustomTransitionPage`). Platform defaults usually feel best.
- **Endless animations** make `pumpAndSettle` time out. In tests, use `pump(duration)`.
- Profile on a low-end Android device in profile mode.
