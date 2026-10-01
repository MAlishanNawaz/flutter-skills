# State management

Use the library the project already has. Don't add Riverpod to a bloc app, or the other way round.

## Where state lives

| State | Home |
|---|---|
| Ephemeral UI (tab index, expanded tile, focus) | `StatefulWidget` / `ValueNotifier`, kept local |
| Screen state (loaded data, submit status) | A state holder scoped to the route |
| App state (session, flags, theme) | A state holder above the router |
| Server data | The repository; state holders expose it |

## Rules for every library

- State is immutable and sealed. Each transition emits a new value.
- State holders call repositories or use cases, never HTTP directly. Never pass a `BuildContext` in.
- **After every `await`**, check `isClosed` (bloc), `ref.mounted` (Riverpod 3) or a disposed flag (ChangeNotifier) before emitting.
- **Drop repeat intents** while one is in flight: `if (state is Submitting) return;`, or bloc's `droppable()`.
- Rebuild narrowly: `context.select`, `buildWhen`, `Selector`, `ref.watch(p.select(...))`.
- One-off effects (navigate, snackbar) go in `BlocListener` with `listenWhen`, or in `ref.listen`, never in a builder.
- **Concurrent refreshes**: share the in-flight `Future` rather than firing a second request.

## bloc / cubit

- Use a Cubit for method → state. Use a Bloc when you need event transformers: `restartable()` for search-as-you-type with a debounce, `droppable()` for submit.
- Test with `bloc_test` and a fake repository: `seed`, `act`, `expect`, and `verify` the call counts.

## Riverpod

- `ref.watch` in build and providers, `ref.read` in callbacks, `ref.listen` for effects.
- Screen state is autoDispose (the codegen default). Use `keepAlive` only for real caches.
- Render `AsyncValue` with `switch`. Use `skipLoadingOnRefresh` so content stays visible during a refresh.
- In tests, override providers via `ProviderScope(overrides:)` or a `ProviderContainer`.

## provider / ChangeNotifier

- Hold one immutable `state` field with a single `_set()` that notifies, not several mutable fields.
- Guard `notifyListeners` after dispose. Use `context.read` in callbacks and never `watch` there.

## Anti-patterns

- Starting a load from `build()`
- One global "AppBloc" for everything
- Flags instead of sealed state
- Emitting after close
