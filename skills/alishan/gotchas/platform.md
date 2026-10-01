# Routing, platform, security and release gotchas

Contents: routing and deep links · platform · security · release

## Routing and deep links

The redirect logic lives in [../examples/profile_feature/lib/core/routing/auth_redirect.dart](../examples/profile_feature/lib/core/routing/auth_redirect.dart), with tests. The native and site config lives in [../examples/deeplink_config/](../examples/deeplink_config/).

- **Cold start.** A link arrives before the saved session is restored. Auth needs an `unknown` state that holds the link on a splash route; treating unknown as signed out loses it.
- **Untrusted input.** Ids in the path are untrusted, so validate them. `?from=` accepts only in-app paths, or it becomes an open redirect. Don't act destructively straight from a link.
- **Build the router once,** in `State` or dependency injection. A router built in `build` drops the pending link on rebuild.
- **Nest detail routes under their list** (`/courses` → `:courseId`), so Back from a cold-started link has somewhere to go. Pass ids, not objects: `extra` is lost on a web refresh.
- **Android:** `flutter_deeplinking_enabled` and the `autoVerify` intent-filter go inside the MainActivity `<activity>`. Under `<application>` the flag is silently ignored. It's on by default from Flutter 3.27.
- **iOS:** `applinks:` belongs in `Runner.entitlements`. In `Info.plist` it does nothing.
- **Verification files:** `assetlinks.json` needs the Play App Signing fingerprint as well as your own. Serve both files as `application/json` with HTTP 200 and no redirects.
- **Tests:** simulate a cold start with `tester.platformDispatcher.defaultRouteNameTestValue`, and hold session restore open with a `Completer`.

## Platform

- Check `kIsWeb` before `defaultTargetPlatform`. `dart:io` doesn't compile for web.
- `kIsWeb` is always false under VM tests, so inject it if both paths need coverage.
- Channel calls throw `PlatformException` and `MissingPluginException`. Catch both and map them to `AppError`. Use Pigeon for anything beyond a one-off call.
- Permissions have four outcomes: granted, denied, permanently denied (only `openAppSettings()` helps), and iOS limited photos. Re-check them when the app resumes.
- Push notifications arrive three ways: foreground, a tap from the background, and a tap that cold-starts the app (`getInitialMessage`). Route all three through the router, and re-sync the device token when it refreshes.
- The OS kills backgrounded apps without warning, so save drafts in `onPause`. iOS runs `workmanager` jobs rarely. `local_auth` unlocks a stored token; it isn't proof of identity.

## Security

- Payments: the backend creates the intent with the secret key and returns a single-use client secret. Success is confirmed by webhook, never trusted from the client.
- Restrict shipped public keys to your bundle ID or SHA-1 in the provider console. Reject secret-looking keys (`sk_`, `rk_`) in app config at startup.
- iOS Keychain items survive an uninstall. Clear tokens on the first launch after a fresh install if that matters.
- Route both `FlutterError.onError` and `PlatformDispatcher.instance.onError` to crash reporting. Upload `--split-debug-info` symbols with every release.
- Pin certificates only with a backup pin and a rotation plan; a single expired pin locks every user out.

## Release

- When QA and prod share one store package and track, a QA build can ship to users. Give each flavor its own app ID, and add a release step that fails unless the flavor, API URL and keys are all prod.
- `--flavor prod` with `config/qa.json` builds a prod app pointed at QA. Compare `appFlavor` with the config's `FLAVOR` at startup.
- If the project pins Flutter with fvm, use `fvm` in CI too (`kuhnroyal/flutter-fvm-config-action` reads `.fvmrc`).
- Build numbers only go up, so a rollback ships as a hotfix with a higher number.
- Private Git dependencies in CI: use a secret plus `git config url."https://x-access-token:${TOKEN}@github.com/".insteadOf`, never a token in `pubspec.yaml`.
- If a CI step fails on main too, the cause is the runner or an expired Maven or CocoaPods credential, not your diff.
- Web: serve `index.html`, `flutter_service_worker.js` and `version.json` with `no-cache`.
