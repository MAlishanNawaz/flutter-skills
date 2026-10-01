# Testing strategy

## Pyramid

| Layer | Tool | Cover |
|---|---|---|
| Rules, validators, mappers, repositories | `test` | Everything pure, every `AppError` branch, JSON fixtures |
| State holders | `bloc_test` / `ProviderContainer` | Happy path, each error, empty data, double intent, close while awaiting |
| Widgets | `flutter_test` | Each state renders, interactions, sizes, a11y (see [ui-testing.md](ui-testing.md)) |
| E2E | `integration_test`, or Patrol for native UI | A few money-critical journeys |

Each bug fix adds a test at the **lowest layer that reproduces it**.

## Fakes over mocks

- Fakes are small in-memory implementations of your interfaces, with switches (`failWith`, `offline`) and counters (`calls`, `requestedCursors`). They read as scenarios and survive refactors.
- Use mocks (`mocktail`) only when the interaction itself is the assertion, such as an analytics event sent once.
- Never mock types you don't own (`Dio`, Firebase). Wrap them in an interface and fake that.
- Inject the clock, and use `fake_async` for timers and debounce.
- Use a `Completer` in a fake to hold a request in flight. That's how you test double taps and close-while-awaiting.

## E2E

- `integration_test` for in-app flows. **Patrol** when the flow touches native UI: permission dialogs, notifications, share sheets, WebViews, or background/foreground.
- Find widgets by stable `Key`s, not copy.
- Seed or fake the backend, and use unique test users per run.
- Never use fixed sleeps. With endless animations, use `pump(duration)` rather than `pumpAndSettle`.
- Test credentials come from CI secrets or the project's test config, never from the test file.

## Coverage & CI

Run these on every PR:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

Exclude generated files from coverage. Aim for ≥ 90% on domain and state holders, and don't chase a number for widgets. Run E2E on an emulator for main-branch merges, or nightly if it's slow.
