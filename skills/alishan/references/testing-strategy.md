# Testing strategy (beyond widgets)

`ui-testing.md` covers widget tests. This guide covers the rest: how many tests of each kind,
fakes, state-holder tests, integration/E2E, and CI.

## The pyramid

| Layer | Tool | What | Share |
|---|---|---|---|
| Unit | `test` | Pure rules, validators, mappers, repositories (with fake sources) | Most |
| State holder | `bloc_test`, Riverpod `ProviderContainer`, plain tests for notifiers | State sequences for each intent, error paths, double-submit, close-while-awaiting | Many |
| Widget | `flutter_test` | Rendering per state, interaction, sizes, a11y | Some per screen |
| Integration / E2E | `integration_test` or Patrol | Critical journeys on a real device/emulator | A few |

Rule of thumb: every bug fix adds a test **at the lowest layer that can reproduce it**.

## Fakes over mocks

```dart
class FakeProfileRepository implements ProfileRepository {
  Profile profile = testProfile;
  AppError? failWith;
  int updateCalls = 0;
  // ...real, tiny behaviour
}
```

- A fake implements the interface with real in-memory behaviour. Tests read as scenarios
  (`repo.failWith = const NetworkError()`), and a fake doesn't break when call order changes.
- Use mocks (`mocktail`) only to **verify an interaction** that is the point of the test (analytics
  event sent once, a platform channel called with these args).
- Never mock types you don't own (`Dio`, Firebase). Wrap them in your own interface and fake that.
- Inject the **clock** (`DateTime Function() now`) and randomness, and use `fake_async` for
  timers and debounce.

## State-holder tests

```dart
blocTest<SearchBloc, SearchState>(
  'debounces and keeps only the last query',
  build: () => SearchBloc(fakeRepo),
  act: (b) => b..add(const QueryChanged('fl'))..add(const QueryChanged('flu'))..add(const QueryChanged('flutter')),
  wait: const Duration(milliseconds: 350),
  expect: () => [isA<SearchLoading>(), isA<SearchResults>().having((s) => s.query, 'query', 'flutter')],
  verify: (_) => expect(fakeRepo.searchCalls, 1),
);
```

For each state holder, cover: happy path, every `AppError` branch, empty data, double intent
(double tap), and closing while a request is still running.

## Integration & E2E

Test the **few journeys that cost money when they break**: sign up / log in, the core
create-or-purchase flow, the deep link into a key screen, and an offline round-trip if the app
supports it.

### `integration_test` (built in)

```dart
// integration_test/login_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can log in and see home', (tester) async {
    await app.main(overrides: testOverrides);             // fake backend or a seeded test env
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'qa+login@example.com');
    await tester.enterText(find.byKey(const Key('password')), testPassword);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-screen')), findsOneWidget);
  });
}
```

```bash
flutter test integration_test -d <device-id>
```

### Patrol (when you need native UI)

Use Patrol when a journey touches **native** UI: permission dialogs, notifications, system share
sheets, WebViews, or going to the background and back. `integration_test` can't tap those.

```dart
patrolTest('grants camera permission', ($) async {
  await $.pumpWidgetAndSettle(const App());
  await $(#scanButton).tap();
  if (await $.native.isPermissionDialogVisible()) await $.native.grantPermissionWhenInUse();
  await $(#scannerView).waitUntilVisible();
});
```

### Make E2E reliable

- Find widgets by **stable `Key`s** (`Key('login-submit')`), not text that changes with copy or locale.
- Seed or fake the backend so tests don't depend on shared mutable data. Generate unique test
  users for each run.
- Avoid fixed sleeps. Wait for conditions (`pumpAndSettle`, Patrol's `waitUntilVisible`), and use
  `pump(duration)` for screens with endless animations (where `pumpAndSettle` never settles).
- Keep test-only credentials in CI secrets or the project's test config, never in the test file.

## Golden tests (optional)

Useful for design-system components. Run them on one pinned platform in CI (Linux), load real
fonts (`ui-testing.md`), and update them on purpose (`--update-goldens`) in their own commit.

## Coverage

```bash
flutter test --coverage
lcov --remove coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.freezed.dart' 'lib/gen/**' -o coverage/lcov.info
```

Aim high for **domain and state holders** (≥ 90%) and don't chase a number for widgets. Treat
coverage as a hint about what's missing, not as the goal.

## In CI

1. `dart format --set-exit-if-changed .` → `flutter analyze` → `flutter test --coverage` on every PR.
2. Integration/E2E on an emulator (or Firebase Test Lab) for every PR to main, or nightly if
   they're slow.
3. Fail on new analyzer issues. Upload coverage and test reports as artifacts.

## Checklist

- [ ] Each bug fix comes with a test at the lowest layer that reproduces it.
- [ ] Fakes for your interfaces; no mocks of third-party types; clock/timers injected.
- [ ] State holders: happy path, every error, empty data, double intent, close-while-awaiting.
- [ ] A handful of E2E journeys with stable keys and seeded data.
- [ ] CI runs format, analyze and tests on every PR.
