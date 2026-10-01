# Architecture, state and data gotchas

Contents: layers · state · networking · caching and offline · pagination

The reference for everything here is [../examples/profile_feature/](../examples/profile_feature/): entity, repository interface, DTO and mapper, `Result`/`AppError`, sealed state, cubit and fakes.

## Layers

- Generated SDK models (Amplify, OpenAPI, GraphQL codegen) are DTOs. Map them in the data layer; widgets don't see them.
- A feature can import `core/` and another feature's `domain/`, but not another feature's `data/` or `presentation/`. When two features need the same helper (an exception type, an error mapper, a skeleton widget), move it to `core/`.
- Translate exceptions to `AppError` in one guard function, not in each repository method.
- If the project already uses `fpdart` or `dartz`, use its `Either` instead of defining a second `Result`.

## State

- After an `await`, the screen may be gone. Check `isClosed` (bloc), `ref.mounted` (Riverpod 3) or a disposed flag before emitting.
- Concurrent refreshes should share the in-flight `Future` instead of sending a second request.
- Navigation and snackbars go in `BlocListener` (with `listenWhen`) or `ref.listen`, not in `build`.
- `isLoading` + `error` + `data` flags allow impossible combinations. Use a sealed state and an exhaustive `switch`.
- Riverpod: `skipLoadingOnRefresh` keeps content visible during a refresh. With provider, guard `notifyListeners` after dispose.

## Networking

- **Auth refresh must be single-flight.** When several requests get a 401 at once, refresh once and replay them all, with dio's `QueuedInterceptor`. Mark retried requests so they can't loop.
- **Retry only idempotent requests** (or POSTs with an idempotency key), and only on timeouts, connection errors, 5xx and 429. Respect `Retry-After`.
- **Read the body of every non-2xx response.** A helper that only reads 400 bodies loses `Retry-After` and the field errors that come with 409 and 422.
- **Unknown enum values map to `unknown`,** so new server values don't crash old app versions.
- **An empty-string cursor means the end of the list.** Otherwise pagination loops.
- **For money, fail the whole page on a malformed row** rather than showing 0.
- Parse large payloads with `Isolate.run`. Keep one JSON fixture per endpoint and test the mapper against it.

## Caching and offline

| Data | Strategy |
|---|---|
| Payment actions, OTPs | Network-only |
| Feeds, profiles, read-only history | Show the cache, fetch, replace. On failure keep the cache and show a "may be out of date" banner |
| Drafts, notes, field apps | Local database as the source of truth, plus a sync outbox |

- Outbox operations need client-side UUIDs so a replay can't create duplicates.
- Connectivity plugins report that a network interface exists, not that the internet is reachable. Treat them as a hint to retry.
- Encrypt persisted financial or personal data.

## Pagination

- Trigger load-more from a scroll listener at about 80% of the extent, not from `build()`.
- Ignore triggers while a page is loading, and while page 1 is still in flight.
- After a failure, show a retry row and stop auto-triggering until the user taps it.
- A refresh bumps a generation counter. Discard any page that started before the refresh, and de-duplicate rows by id.
