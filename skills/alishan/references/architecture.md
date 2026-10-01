# Flutter app architecture

Aim for layers with one-way dependencies, organised by feature, with data flowing one way.
On an **existing** project, extend the structure it already has. Only restructure when the task
asks for it, and then do it one feature at a time.

## Layers

```
presentation  →  domain  ←  data
(widgets,        (entities,    (repositories impl,
 state holders)   use cases,    API/DB clients,
                  repo          DTOs + mappers)
                  interfaces)
```

| Layer | Contains | Must not |
|---|---|---|
| **Presentation** | Screens, widgets, bloc/cubit/notifier/view-model, view models (UI-ready data) | Call HTTP/DB directly; hold business rules |
| **Domain** | Immutable entities, pure business functions, use cases, repository **interfaces**, `AppError` | Import Flutter, `http`, `dio`, Amplify, JSON; know about widgets |
| **Data** | Repository implementations, remote/local data sources, DTOs, DTO↔entity mappers, caching | Leak DTOs or SDK types above itself; throw raw SDK exceptions upward |

Dependencies point **inwards**. Domain depends on nothing; data implements domain's interfaces;
presentation depends on domain (and gets the implementations through DI).

For small apps, a use-case layer is optional. A state holder can call a repository directly.
Add use cases when logic combines several repositories or appears on more than one screen.

## Feature-first folders

```
lib/
├── app/                       # MaterialApp, router, theme, DI setup, env/flavors
├── core/                      # cross-cutting: tokens, Result/AppError, network client,
│   ├── design/                #   logging, extensions, shared widgets
│   ├── error/
│   ├── network/
│   └── widgets/
└── features/
    └── profile/
        ├── domain/
        │   ├── profile.dart                 # entity (immutable)
        │   ├── profile_repository.dart      # abstract interface
        │   └── profile_rules.dart           # pure functions (completion %, validation)
        ├── data/
        │   ├── profile_dto.dart             # JSON shape
        │   ├── profile_mapper.dart          # DTO ↔ entity
        │   ├── profile_remote_source.dart   # API calls
        │   └── profile_repository_impl.dart # returns Result<Profile>
        └── presentation/
            ├── profile_cubit.dart           # or notifier / view-model
            ├── profile_state.dart           # sealed LoadState
            ├── profile_screen.dart
            └── widgets/                     # private to this feature
```

- A feature can import from `core/` and from another feature's `domain/`, **never** from another
  feature's `data/` or `presentation/`.
- A widget used by two or more features moves to `core/widgets/`.

## Unidirectional data flow

```
User event ──▶ State holder ──▶ Use case / Repository ──▶ Data source
     ▲               │                                        │
     └── Widget ◀── new immutable State ◀── Result<Entity> ◀──┘
```

- Widgets **send events/intents** and **render state**. Nothing else.
- State holders are the only things that change state, and each change emits a new immutable
  state (see `functional-programming.md`).
- One-off effects (navigate, toast) go through listeners or a separate effect stream, not
  through flags left in state.

## Repository pattern

```dart
// domain
abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile(String id);
  Future<Result<void>> updateName(String id, String name);
  Stream<Profile> watchProfile(String id);
}

// data
final class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._cache);
  final ProfileRemoteSource _remote;
  final ProfileCache _cache;

  @override
  Future<Result<Profile>> getProfile(String id) async {
    try {
      final dto = await _remote.fetch(id);
      final profile = dto.toEntity();
      await _cache.save(profile);
      return Ok(profile);
    } on ApiException catch (e) {
      return Err(AppError.fromApi(e));
    }
  }
  // ...
}
```

- The repository is the **single source of truth** for its data: it decides cache vs network.
- Map DTOs to entities **inside** the data layer. Generated SDK models (Amplify, OpenAPI,
  GraphQL codegen) count as DTOs too. Wrap them; don't pass them up into widgets.
- Translate exceptions to `AppError` at this boundary.

## Dependency injection

Wire the graph in one place (`app/di.dart`) using what the project uses: `get_it`, Riverpod
providers, or `RepositoryProvider`/`MultiProvider`. Constructors take **interfaces**:

```dart
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const Loading());
  final ProfileRepository _repo;     // interface, so tests can pass a fake
}
```

No `ServiceLocator.get()` calls hidden inside widgets or business functions. Inject at the
boundary.

## Errors

- One `AppError` sealed type in `core/error/` (network, unauthorised, validation, notFound,
  unknown), with user-facing copy chosen in presentation.
- Log once, where the error is translated (data layer), with context. Don't log at every layer.

## Navigation

Declarative routing (`go_router` or the project's router) is set up in `app/`. Features expose
route constants or typed routes. Deep links get parsed into typed parameters at the router,
never inside widgets.

## Testing by layer

| Layer | Test | Mock? |
|---|---|---|
| Domain pure functions | Plain unit tests | Nothing to mock |
| Mappers | Unit: JSON fixture → entity | No |
| Repository | Unit with fake data sources | Fake sources |
| State holder | `bloc_test` / notifier tests with a fake repository | Fake repo |
| Widgets | Widget tests with stubbed state (see `ui-testing.md`) | State only |

Fakes (small in-memory implementations of the interface) are easier to maintain than mocks
with long `when(...)` setups.

## Architecture review checklist

- [ ] No Flutter, HTTP, SDK or JSON imports in `domain/`.
- [ ] No DTOs or SDK models in presentation.
- [ ] Widgets have no business logic or I/O; `build()` is pure.
- [ ] State is immutable and modelled as sealed states.
- [ ] Failures come back as `Result`/`AppError`, not stray exceptions.
- [ ] Dependencies arrive through constructors as interfaces.
- [ ] Feature folders don't import each other's `data/` or `presentation/`.
