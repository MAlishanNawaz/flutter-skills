# Navigation & deep links

Use the project's router. For a new app, use `go_router`. If it isn't in the pubspec, say so before you add it.

## Contents
- Routes and redirects
- Cold-start deep links
- Native and site configuration
- Testing commands
- Web

## Routes

- Declare routes in one place (`app/router.dart`), with path constants or typed routes, never inline strings.
- Put **ids in the path**, not objects. The destination loads its own data, so deep links, web refresh and state restoration all work. `extra` is lost on refresh.
- **Validate path parameters** (`^[0-9]{1,12}$` or whatever the id format is). An invalid id gets a not-found screen. Link input is untrusted.
- Create the router **once**, in `State` or DI, never in `build`, or a rebuild drops the pending link.
- Nest detail routes under their list (`/courses` → `:courseId`) so Back from a cold-started link has somewhere to go.
- Tabs use `StatefulShellRoute.indexedStack`, so each tab keeps its own stack.

## Auth redirect: the cold-start trap

On a cold start, the link arrives **before** the session is restored. If "unknown" is treated as "signed out", the link is lost.

```dart
String? authRedirect(AuthStatus status, Uri location) => switch (status) {
      AuthStatus.unknown => isSplash(location) ? null : '/splash?from=${encode(location)}',
      AuthStatus.signedOut => isLogin(location) ? null : '/login?from=${encode(pending(location))}',
      AuthStatus.signedIn => isAuthRoute(location) ? safeReturnPath(location) ?? '/' : null,
    };
```

- Keep the redirect a pure function, re-run through `refreshListenable` when auth changes. Screens never navigate on auth changes themselves.
- `safeReturnPath` accepts **in-app paths only**. Reject schemes, `//host`, backslashes, and the auth routes themselves (they cause loops).

## Native and site configuration

**Android**
- In `AndroidManifest.xml`, add an `intent-filter` with `android:autoVerify="true"`, scheme `https`, your host and a `pathPrefix`, **inside the `<activity>` for MainActivity**.
- `<meta-data android:name="flutter_deeplinking_enabled" android:value="true"/>` must also sit **inside that `<activity>`**. Under `<application>` it's ignored. It's on by default from Flutter 3.27; set it explicitly if the SDK minimum is lower.
- Serve `/.well-known/assetlinks.json` with the **release and Play App Signing** SHA-256 fingerprints.

**iOS**
- Put `applinks:your.domain` in the Associated Domains entitlement in `ios/Runner/Runner.entitlements`. It doesn't belong in `Info.plist`, where it does nothing. Use `?mode=developer` while developing, because Apple's CDN caches the association file.
- Serve `/.well-known/apple-app-site-association` (no extension) with `TEAMID.bundle.id` and the paths.
- Set `FlutterDeepLinkingEnabled` = true in `Info.plist` if the SDK minimum is below 3.27.

Serve both files as `application/json`, HTTP 200, with no redirects. The package name and bundle ID in them must match the native config exactly.

## Testing commands

```bash
adb shell am force-stop com.example.app                                   # cold start
adb shell am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE \
  -d "https://your.domain/courses/42" com.example.app
adb shell pm get-app-links com.example.app                                # verification state
xcrun simctl terminate booted com.example.app
xcrun simctl openurl booted "https://your.domain/courses/42"
```

Test each case: cold signed out, cold signed in, warm, invalid id, and unknown path. In widget tests, simulate a cold start by setting `tester.platformDispatcher.defaultRouteNameTestValue`, and hold session restore open with a `Completer`.

## Web

Call `usePathUrlStrategy()`, and have the host rewrite unknown paths (but not `/.well-known`) to `index.html`. Refresh and browser back must work on every route.
