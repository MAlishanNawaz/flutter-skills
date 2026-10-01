# Functional Dart

Use Dart 3 features (sealed classes, records, patterns, `switch` expressions) before reaching for a library. If the project already uses `fpdart` or `dartz`, use its `Either`/`Option` instead of defining a second `Result`.

## Rules

- **Immutable models**: `final` fields, `const` constructor, `copyWith`, and value equality (`freezed` if it's in the pubspec, otherwise hand-written `==`/`hashCode`). Equality stops redundant rebuilds in `select`/`buildWhen`.
- **No mutable collections exposed**: return `List.unmodifiable(...)`. Update state by building a new value.
- **Pure functions for rules**: pricing, validation, eligibility, formatting and filtering live in top-level or static functions. Pass in the clock, random source and config as arguments; never call `DateTime.now()` inside.
- **Declarative collections**: `where`/`map`/`fold`, and collection `if`/`for` in widget lists.
- **Composition over inheritance**: build widgets by composing them, take callbacks and builders as parameters, use extensions for small pure helpers, and use typedefs for common function shapes.
- **Null handling**: promote to a local or pattern-match (`if (x case final v?)`), and avoid `!` chains.

## Sealed state instead of flags

```dart
sealed class LoadState<T> { const LoadState(); }
final class Loading<T> extends LoadState<T> { const Loading(); }
final class Loaded<T> extends LoadState<T> { const Loaded(this.data); final T data; }
final class Failed<T> extends LoadState<T> { const Failed(this.error); final AppError error; }

Widget build(BuildContext context) => switch (state) {
      Loading() => const Skeleton(),
      Loaded(:final data) when data.isEmpty => const EmptyView(),
      Loaded(:final data) => ItemList(items: data),
      Failed(:final error) => ErrorView(error: error),
    };
```

`bool isLoading; String? error; T? data;` allows impossible combinations. Replace it.

## Errors as values

```dart
sealed class Result<T> {
  const Result();
  R fold<R>(R Function(AppError e) err, R Function(T v) ok) =>
      switch (this) { Ok(:final value) => ok(value), Err(:final error) => err(error) };
}
final class Ok<T> extends Result<T> { const Ok(this.value); final T value; }
final class Err<T> extends Result<T> { const Err(this.error); final AppError error; }

sealed class AppError { const AppError(); }   // NetworkError, NotFoundError, UnauthorisedError,
                                              // ValidationError(fieldErrors), UnknownError(cause)…
```

Catch exceptions only at the data boundary, and return `Result`. Presentation chooses the user-facing copy for each `AppError` with an exhaustive `switch`.

## Effects at the edges

`build()` is a pure function of state. Network calls, navigation, snackbars and analytics go in event handlers, listeners (`BlocListener`, `ref.listen`) or state holders, never in `build`.
