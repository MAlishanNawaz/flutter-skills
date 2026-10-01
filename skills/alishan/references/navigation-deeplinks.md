# Navigation & deep links

Use the project's router. For new apps, use **`go_router`**: declarative, URL-based, works on web,
and supports deep links natively. Examples below use `go_router`; the rules apply to any router.

## Routes in one place

```dart
// app/router.dart
final router = GoRouter(
  initialLocation: '/home',
  refreshListenable: authState,                    // re-runs redirect when auth changes
  redirect: (context, state) {
    final signedIn = authState.isSignedIn;
    final goingToAuth = state.matchedLocation.startsWith('/login');
    if (!signedIn && !goingToAuth) return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    if (signedIn && goingToAuth) return state.uri.queryParameters['from'] ?? '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    StatefulShellRoute.indexedStack(               // bottom tabs, each keeps its own stack
      builder: (_, __, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/courses',
            builder: (_, __) => const CoursesScreen(),
            routes: [
              GoRoute(
                path: ':courseId',
                builder: (_, s) => CourseScreen(courseId: s.pathParameters['courseId']!),
              ),
            ],
          ),
        ]),
      ],
    ),
  ],
  errorBuilder: (_, s) => NotFoundScreen(uri: s.uri),
);
```

- **Typed routes** (`go_router_builder`) or route-name constants per feature. Don't scatter
  `'/courses/$id'` strings around.
- Pass **ids** in the path, not whole objects. The destination loads its own data, so deep links,
  web refresh and restored state all work.
- Use `extra` only for optional, non-essential hints. It's lost on web refresh and deep links.

## Navigating

- `context.go(...)` replaces the stack (tab switches, after login). `context.push(...)` adds to it
  (drill-down, and you want back to return).
- Navigation that state causes (after a save, on sign-out) happens in a **listener**, never in
  `build`.
- Return results with `final r = await context.push<bool>('/edit')` / `context.pop(true)`.
- Back handling: `PopScope(canPop: !dirty, onPopInvokedWithResult: ...)` for unsaved changes.
  Don't block back without a reason.
- Modal flows (onboarding, checkout) can be a nested route group with their own shell, so
  "close" exits the whole flow.

## Auth and guards

- A single `redirect` is the source of truth for "can this user see this route". Don't put
  guards inside screens.
- Keep `from=` so the user lands where they were going after signing in.
- When the session expires mid-use, the auth state changes, `refreshListenable` fires, and the
  redirect sends the user to login. You don't need manual navigation calls everywhere.

## Deep links

### Set up both platforms

- **Android App Links**: an `intent-filter` with `android:autoVerify="true"` for `https://your.domain`,
  plus `/.well-known/assetlinks.json` on the domain with the **release (and Play signing) SHA-256**.
- **iOS Universal Links**: an Associated Domains entitlement `applinks:your.domain`, plus
  `/.well-known/apple-app-site-association` on the domain listing the app ID and paths.
- Custom schemes (`myapp://`) are fine for OAuth callbacks, but any app can claim them, so don't
  rely on them for anything sensitive.
- Flutter's built-in deep linking passes the URL to the router: make sure
  `flutter_deeplinking_enabled` isn't disabled, or turn it off on purpose when you use
  `app_links` to handle URLs yourself.

### Handle them robustly

- **Treat link parameters as untrusted input.** Validate ids, never act on a link straight away
  (no "delete" or "pay" from a URL without confirmation), and never put tokens in links that get
  logged.
- **Cold start vs warm start**: test both. On cold start the link arrives before auth is
  restored. Hold it, let the redirect send the user to login with `from=`, then continue.
- Unknown or old paths go to a friendly not-found or home screen, never a crash.
- Push-notification taps are deep links too: send the notification's payload through the same
  router path.
- On a flow that sends the backend a "viewed/opened" event, send it **once** per link open, not on
  every rebuild.

### Test deep links

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "https://your.domain/courses/42" com.example.app
adb shell pm get-app-links com.example.app        # verification status
# iOS simulator
xcrun simctl openurl booted "https://your.domain/courses/42"
```

Test cold start (app killed), warm start (app in background), signed out, and an invalid id.

## Web

- Use path URLs (`usePathUrlStrategy()`) instead of `#/` hashes, and configure the host to
  rewrite unknown paths to `index.html`.
- Every screen reachable by URL must load from just its URL (ids in the path, data fetched on
  arrival).
- Browser back/forward and refresh must work. Test them.

## Checklist

- [ ] Routes declared centrally; typed or constant paths; ids in paths, not objects.
- [ ] One `redirect` handles auth and keeps `from=`.
- [ ] Tabs use a stateful shell so each tab keeps its stack.
- [ ] App Links / Universal Links verified with the release signing key.
- [ ] Deep links tested cold and warm, signed out, with invalid ids; parameters validated.
- [ ] Web: path URLs, refresh and back work on every route.
