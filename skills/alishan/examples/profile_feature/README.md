# Worked example: `profile` feature

One feature built the way `architecture.md`, `functional-programming.md`, `state-management.md`,
`ui-components.md` and `ui-testing.md` describe. It's a real package, so you can run it:

```bash
flutter pub get && flutter analyze && flutter test
```

| File | Shows |
|---|---|
| `lib/core/error/result.dart`, `app_error.dart` | `Result<T>` and a sealed `AppError`: errors are values |
| `lib/core/design/tokens.dart` | The only file with raw colours or sizes |
| `features/profile/domain/profile.dart` | Immutable entity with value equality and `copyWith` |
| `features/profile/domain/profile_repository.dart` | Repository **interface** owned by the domain |
| `features/profile/domain/profile_rules.dart` | Pure business rules and composable validators |
| `features/profile/data/profile_dto.dart` | Wire DTO → entity mapping; nullable fields defaulted once |
| `features/profile/data/profile_repository_impl.dart` | The one place exceptions become `AppError` |
| `features/profile/presentation/profile_state.dart` | Sealed screen states |
| `features/profile/presentation/profile_cubit.dart` | Cubit with `isClosed` checks, double-tap guard, keeps data on failure |
| `features/profile/presentation/profile_screen.dart` | Exhaustive `switch` render, listener for effects, skeleton loading, narrow column |
| `test/…` | Fakes, not mocks; tests for rules, repository, cubit (`bloc_test`) and widgets (sizes, 2× text, a11y guidelines) |

Checked on Flutter 3.24.3 and 3.41.2: `analyze` reports no issues and all 18 tests pass.
