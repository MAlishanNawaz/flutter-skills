# Networking & offline

All network code lives in the **data layer** (`architecture.md`). Nothing above a repository
knows about HTTP, status codes, JSON or connectivity.

## One configured client

Build a single client (usually `dio`) in `core/network/` and inject it.

```dart
Dio buildDio(AppConfig config, TokenStore tokens) => Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,                 // from flavor config, never hardcoded
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    )..interceptors.addAll([
        AuthInterceptor(tokens),
        RetryInterceptor(maxRetries: 2),
        if (config.logHttp) LogInterceptor(requestBody: false, responseBody: false), // no PII in logs
      ]);
```

### Auth refresh, single-flight

When several requests get a 401 at the same moment, refresh **once** and replay all of them:

```dart
class AuthInterceptor extends QueuedInterceptor {          // queues requests while one is handled
  AuthInterceptor(this._tokens);
  final TokenStore _tokens;

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final token = await _tokens.accessToken();
    if (token != null) o.headers['Authorization'] = 'Bearer $token';
    h.next(o);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) async {
    if (e.response?.statusCode != 401 || e.requestOptions.extra['retried'] == true) return h.next(e);
    final refreshed = await _tokens.refresh();             // returns false if the refresh token is dead
    if (!refreshed) return h.next(e);                      // repository maps to UnauthorisedError → sign out
    final retry = e.requestOptions..extra['retried'] = true;
    retry.headers['Authorization'] = 'Bearer ${await _tokens.accessToken()}';
    h.resolve(await Dio().fetch(retry));
  }
}
```

### Retries

- Retry **only idempotent** requests (GET, PUT, DELETE), or POSTs with an idempotency key.
- Retry on timeouts, connection errors, 502/503/504 and 429. Never retry 4xx validation errors.
- Use exponential backoff with jitter (e.g. 300 ms, 900 ms ± random). Respect `Retry-After`.
- Cap total attempts. A retry storm makes outages worse.

## Errors: read the whole response

Map every failure to `AppError` in the repository (see the example's
`profile_repository_impl.dart`). Read the **body of every non-2xx response**, not just 400s.
A 429 carries `Retry-After`, and a 409/422 carries field errors. A helper that drops bodies for
other status codes loses exactly the information the UI needs.

| Situation | AppError | UI |
|---|---|---|
| No connection / timeout | `NetworkError` | "You're offline", retry |
| 401 after refresh failed | `UnauthorisedError` | Sign out → login |
| 403 | `ForbiddenError` | Explain, no retry |
| 404 | `NotFoundError` | Empty/gone state |
| 409 / 422 | `ValidationError(fields)` | Inline field errors |
| 429 | `RateLimitedError(retryAfter)` | Disable action until then |
| 5xx | `ServerError` | Generic error, retry |

## Parsing

- Use typed DTOs with `fromJson` (hand-written or `json_serializable`/`freezed`), and never
  pass `Map<String, dynamic>` into the domain.
- Be lenient with unknown enum values (map to `unknown`), so a new server value doesn't crash old
  app versions.
- Parse big payloads off the UI isolate (`Isolate.run(() => parse(body))`).
- Keep a JSON fixture per endpoint in `test/fixtures/` and unit-test the mapper against it.

## Caching & offline

Choose a strategy **per screen**:

| Strategy | Use for | How |
|---|---|---|
| Network-only | Payments, one-time codes, anything that must be fresh | Plain fetch, clear error when offline |
| Cache-then-network (stale-while-revalidate) | Feeds, profiles, lists | Emit cached data straight away, fetch, emit fresh data |
| Offline-first | Notes, drafts, checklists, field apps | Local DB is the source of truth; sync queue to server |

Cache-then-network as a stream:

```dart
Stream<Result<List<Course>>> watchCourses() async* {
  final cached = await _db.courses();
  if (cached.isNotEmpty) yield Ok(cached);
  final fresh = await _guard(() => _remote.courses());
  if (fresh case Ok(:final value)) await _db.saveCourses(value);
  if (fresh is Ok || cached.isEmpty) yield fresh;        // don't replace cached data with an error
}
```

Offline-first essentials:

- Local storage: `drift` (SQL) or `isar`/`hive` for documents. Use `shared_preferences` only for
  small settings.
- **Outbox**: write locally first, add `{id, op, payload, attempts}` to a queue, and flush it
  when connectivity comes back and on app start.
- Make each queued operation **idempotent** (client-generated UUIDs) so a replay can't duplicate.
- Conflicts: last-write-wins with server timestamps is usually enough. Show the user a merge only
  where losing an edit really matters.
- Show sync state in the UI (pending badge, "Saved offline").
- Connectivity plugins only tell you there's a network interface, not that you have internet.
  Treat them as a hint to retry, and still handle failures.

## Pagination

- Cursor-based if the API supports it. State is `{items, cursor, isLoadingMore, reachedEnd, error}`.
- Trigger the next page when the user is about 80% down the list, and **ignore triggers while a
  load is running**.
- An error on page N keeps pages 1..N-1 on screen and shows a "retry" row.

## Real-time

- WebSockets/SSE: reconnect with backoff, resubscribe after reconnecting, and use heartbeats to
  spot dead connections.
- Close sockets when the app goes to the background (`AppLifecycleListener`) unless the feature
  needs them.

## Checklist

- [ ] One injected client; base URL from config; timeouts set.
- [ ] Single-flight token refresh; sign out when the refresh fails.
- [ ] Retries only for idempotent requests, with backoff and a cap.
- [ ] Every non-2xx body read and mapped to an `AppError`; no PII in logs.
- [ ] Cache strategy chosen for each screen; offline writes go through an idempotent outbox.
- [ ] Mappers tested against JSON fixtures.
