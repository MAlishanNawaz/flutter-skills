# Functional programming in Dart & Flutter

Flutter is functional by design: `build()` is a function from state to UI. Push the rest of the
code the same way. Use immutable data, pure functions, explicit errors, and keep side effects at
the edges. Dart 3 (sealed classes, records, patterns, `switch` expressions) covers most of this
without a library.

## 1. Immutable data

```dart
// ✅ final fields, const constructor, copyWith for "changes"
final class CartItem {
  const CartItem({required this.id, required this.qty, required this.price});
  final String id;
  final int qty;
  final double price;

  CartItem copyWith({int? qty}) => CartItem(id: id, qty: qty ?? this.qty, price: price);
}

// ❌ mutable fields changed in place
class CartItem { int qty = 0; }
item.qty++;
```

- Use `freezed` (or plain `final` classes) for models. Generated `==`/`hashCode` stop
  pointless rebuilds in `Selector`/`BlocBuilder`/`select`.
- Don't let callers mutate internal collections. Expose `List.unmodifiable(...)` or `IList`
  (`fast_immutable_collections`).
- To "update" state, build a new value: `state.copyWith(items: [...state.items, item])`.

## 2. Pure functions for logic

Business rules (pricing, validation, filtering, formatting, eligibility) go in **pure top-level
or static functions**: same input gives the same output, with no `DateTime.now()`, no I/O and no
globals inside.

```dart
// ✅ pure, and trivial to unit-test
double cartTotal(Iterable<CartItem> items) =>
    items.fold(0, (sum, i) => sum + i.qty * i.price);

bool canCheckout(Cart cart, {required DateTime now}) =>
    cart.items.isNotEmpty && cart.expiresAt.isAfter(now);
```

Pass the clock, random source or config **in as arguments** instead of reaching for them
inside. Widgets and blocs call these functions and stay thin.

## 3. Collections: map / where / fold, not loops that mutate

```dart
final visible = courses
    .where((c) => c.status != Status.archived)
    .map(CourseVm.fromModel)
    .toList();

final byStatus = <Status, List<Course>>{
  for (final s in Status.values) s: courses.where((c) => c.status == s).toList(),
};
```

Collection `if`/`for` inside list and map literals keeps widget trees declarative:

```dart
Column(children: [
  const Header(),
  if (state.hasWarning) const WarningBox(),
  for (final item in state.items) ItemTile(item: item),
])
```

## 4. Model states as sealed types, not nullable flags

```dart
// ❌ impossible states can be represented
class State { bool loading = false; String? error; List<Item>? data; }

// ✅ only valid states exist; the compiler checks the switch covers them all
sealed class LoadState<T> { const LoadState(); }
final class Loading<T> extends LoadState<T> { const Loading(); }
final class Loaded<T> extends LoadState<T> { const Loaded(this.data); final T data; }
final class Failed<T> extends LoadState<T> { const Failed(this.error); final AppError error; }

Widget build(BuildContext context) => switch (state) {
      Loading() => const ListSkeleton(),
      Loaded(:final data) when data.isEmpty => const EmptyView(),
      Loaded(:final data) => ItemList(items: data),
      Failed(:final error) => ErrorView(error: error, onRetry: onRetry),
    };
```

## 5. Errors as values

Throwing across layers hides failures from the type system. At the data boundary, catch and
return a `Result`:

```dart
sealed class Result<T> {
  const Result();
  R fold<R>(R Function(AppError e) onErr, R Function(T v) onOk) => switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final error) => onErr(error),
      };
  Result<R> map<R>(R Function(T v) f) => switch (this) {
        Ok(:final value) => Ok(f(value)),
        Err(:final error) => Err(error),
      };
}
final class Ok<T> extends Result<T> { const Ok(this.value); final T value; }
final class Err<T> extends Result<T> { const Err(this.error); final AppError error; }
```

```dart
Future<Result<Profile>> getProfile(String id) async {
  try {
    return Ok(Profile.fromJson(await api.get('/profiles/$id')));
  } on HttpException catch (e) {
    return Err(AppError.network(e.message));
  }
}
```

Callers have to deal with both cases, with `switch` or `fold`. If the project already uses
`fpdart`/`dartz` (`Either`, `TaskEither`, `Option`), use theirs rather than defining a second
one.

## 6. Composition over inheritance

- Build widgets by **composing** small widgets. Don't subclass a screen to tweak it.
- Prefer **functions as parameters** (`ValueChanged<T>`, `Widget Function(BuildContext, T)`
  builders) over abstract base classes with one method.
- Use **extension methods** for small pure helpers (`DateTime.isSameDay`, `String.initials`).
  They read well and stay testable.
- Use **typedefs** for function shapes that come up often:
  `typedef Validator = String? Function(String value);`, then compose them:

```dart
Validator all(List<Validator> vs) => (v) {
      for (final f in vs) {
        final err = f(v);
        if (err != null) return err;
      }
      return null;
    };
final emailValidator = all([required, maxLength(120), email]);
```

## 7. Side effects at the edges

- `build()` must be pure: no network calls, no `setState`, no navigation, no analytics. Put
  those in event handlers, `initState`/listeners, or the bloc/notifier.
- Navigation, snackbars and dialogs that come from state go in `BlocListener` / `ref.listen` /
  a listener callback, not in `build`.
- Keep I/O in repositories and services (see `architecture.md`), so everything above them can be
  pure and tested without mocks.

## 8. Null handling

Treat nullable values as optional and transform them, rather than force-unwrapping:

```dart
final name = user?.name?.trim();
final label = (name == null || name.isEmpty) ? strings.anonymous : name;
if (state.course case final course?) { /* course is non-null */ }
```

Avoid `!` chains. Promote to a local first, or pattern-match.
