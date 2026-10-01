# Networking & offline

All network code lives in the data layer. Nothing above a repository knows about HTTP, status codes or JSON.

## Contents
- Client setup and auth refresh
- Retries
- Error mapping
- Parsing
- Cache strategies and offline writes
- Pagination

## Client

Build one configured client (usually `dio`, if it's in the pubspec) in `core/network/`, inject it, and take the base URL from flavor config. Interceptors handle auth, retry and logging, and logging must never include bodies or PII.

**Auth refresh must be single-flight.** When several requests get a 401 at once, refresh once and replay them all. Use dio's `QueuedInterceptor`. Mark each retried request (`extra['retried'] = true`) so it can't loop. When the refresh fails, return the 401 so the repository maps it to `UnauthorisedError` and the session signs out.

## Retries

- Retry only idempotent requests (GET, PUT, DELETE), or POSTs that carry an idempotency key.
- Retry on timeouts, connection errors, 502/503/504 and 429. Never retry other 4xx.
- Use exponential backoff with jitter, respect `Retry-After`, and cap the attempts.

## Errors

Read the body of **every** non-2xx response. A helper that drops bodies outside 400 loses `Retry-After` and field errors.

| Response | AppError |
|---|---|
| No connection / timeout | `NetworkError` |
| 401 after refresh failed | `UnauthorisedError` |
| 403 / 404 | `ForbiddenError` / `NotFoundError` |
| 409 / 422 | `ValidationError(fieldErrors)` |
| 429 | `RateLimitedError(retryAfter)` |
| 5xx / malformed body | `ServerError` / `UnknownError` |

## Parsing

- Use typed DTOs. Never pass `Map<String, dynamic>` above data.
- Unknown enum values map to `unknown`, so new server values don't crash old app versions.
- An empty-string cursor means the end of the list.
- For money, fail the whole page on a malformed row rather than showing 0.
- Parse large payloads with `Isolate.run`.
- Keep one JSON fixture per endpoint in `test/fixtures/`, and test the mapper against it.

## Caching

| Strategy | For |
|---|---|
| Network-only | Payment *actions*, OTPs, anything that must be fresh |
| Cache-then-network | Feeds, profiles, read-only history: show the cache, fetch, replace; on failure keep the cache with a "may be out of date" banner |
| Offline-first | Drafts, notes, field apps: the local DB is the truth, plus a sync outbox |

- Offline writes go through an **outbox** of idempotent operations (client UUIDs) that flushes on reconnect and on app start.
- Connectivity plugins only report that a network interface exists, not that the internet is reachable. Treat them as a hint to retry.
- Encrypt persisted financial or personal data.

## Pagination

Hold the state as `{items, cursor, loadingMore, reachedEnd, loadMoreError}`.

- Trigger load-more from a scroll listener at about 80% of the scroll extent, **never from `build()`**.
- Ignore triggers while a page is loading, and block load-more while page 1 is in flight.
- After a failure, show a retry row and stop auto-triggering until the user taps retry.
- A refresh increments a generation counter. Discard any page that started before it.
- De-duplicate by id, since cursor windows shift.
