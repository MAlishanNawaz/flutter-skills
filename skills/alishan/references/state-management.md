# State management

**Use what the project already has.** This guide shows how to use each common option well
within the layers in `architecture.md`. The rules are the same whichever library you use:

- State is **immutable** and modelled as **sealed states** (`functional-programming.md`).
- State holders call **repositories/use cases**, never HTTP/DB directly.
- Widgets **render state and send intents**. They don't decide anything.
- One-off effects (navigate, snackbar, dialog) go through **listeners**, not flags in state.
- Rebuild **as little as possible**: select the slice a widget needs.

## Where state lives

| State | Lives in |
|---|---|
| Ephemeral UI (tab index, field focus, expanded tile, animation) | `StatefulWidget` / hooks, local to the widget |
| Screen state (loaded data, form status) | A state holder scoped to the screen's route |
| App state (session, current user, feature flags, theme) | A state holder provided above the router |
| Server data | The repository (single source of truth), exposed through state holders |

Don't push ephemeral UI state into a bloc, and don't keep server data in widget `State`.

## bloc / cubit (`flutter_bloc`)

Use a **Cubit** for straightforward method → state flows. Use a **Bloc** when you need
event transformers (debounce, `droppable`, `restartable`) or an event log.

```dart
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileLoading());
  final ProfileRepository _repo;

  Future<void> load(String id) async {
    emit(const ProfileLoading());
    final result = await _repo.getProfile(id);
    if (isClosed) return;                                   // screen left while awaiting
    emit(result.fold(ProfileFailed.new, ProfileLoaded.new));
  }
}
```

```dart
// Rebuild only when the name changes
final name = context.select((ProfileCubit c) => switch (c.state) {
      ProfileLoaded(:final profile) => profile.name,
      _ => null,
    });

// Side effects
BlocListener<ProfileCubit, ProfileState>(
  listenWhen: (prev, next) => next is ProfileFailed && prev is! ProfileFailed,
  listener: (context, state) => showErrorSnackBar(context, (state as ProfileFailed).error),
  child: ...,
)
```

- Check `isClosed` after an `await` before calling `emit`.
- Use `buildWhen` / `listenWhen` / `context.select` to keep rebuilds small.
- Search-as-you-type: a `Bloc` with `restartable()` (from `bloc_concurrency`) plus a debounce.
- Submit buttons: `droppable()` ignores repeat taps while one is in flight.
- Test with `bloc_test` and a fake repository.

## Riverpod

```dart
@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(ref.watch(apiProvider));

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<Profile> build(String id) async =>
      (await ref.watch(profileRepositoryProvider).getProfile(id)).fold((e) => throw e, (p) => p);

  Future<void> rename(String name) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading<Profile>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await repo.updateName(id, name).then((r) => r.fold((e) => throw e, (_) {}));
      return ref.refresh(profileControllerProvider(id).future);
    });
  }
}
```

- `ref.watch` in `build`/providers, `ref.read` in callbacks, `ref.listen` for side effects.
- `select` to narrow rebuilds: `ref.watch(p.select((s) => s.valueOrNull?.name))`.
- Use autoDispose (the default with codegen) for screen state, and `keepAlive` only for real
  caches.
- Render `AsyncValue` with `switch`/`when`, using `skipLoadingOnRefresh` so content stays on screen
  while it refreshes.
- Override providers in `ProviderScope(overrides: [...])` for tests.

## provider / ChangeNotifier

```dart
class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier(this._repo);
  final ProfileRepository _repo;

  ProfileState _state = const ProfileLoading();
  ProfileState get state => _state;

  Future<void> load(String id) async {
    _set(const ProfileLoading());
    _set((await _repo.getProfile(id)).fold(ProfileFailed.new, ProfileLoaded.new));
  }

  bool _disposed = false;
  void _set(ProfileState s) { if (_disposed) return; _state = s; notifyListeners(); }
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
```

- Keep one immutable `state` field rather than several mutable fields with a
  `notifyListeners()` after each.
- `context.select<ProfileNotifier, String?>(...)` or `Selector` for narrow rebuilds;
  `context.read` in callbacks; never `context.watch` in callbacks.
- Guard `notifyListeners` after dispose (above).

## setState / ValueNotifier

Fine for widget-local, ephemeral state. `ValueNotifier` + `ValueListenableBuilder` is the
lightest way to rebuild just one small subtree.

## Anti-patterns

- ❌ Calling repositories from `build()`, or kicking off a load on every build.
- ❌ `bool isLoading; String? error; Data? data;` combinations instead of sealed state.
- ❌ Navigating or showing snackbars from inside `build`/`BlocBuilder`.
- ❌ One global "AppBloc" that holds everything.
- ❌ Passing `BuildContext` into a state holder.
- ❌ Calling `emit`/`notifyListeners` after close/dispose.
