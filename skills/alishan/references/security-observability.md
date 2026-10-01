# Security & observability

## Secrets: the app binary is public

Anything in the app (Dart constants, `--dart-define`, assets, `.env` files bundled as assets,
native config) **can be extracted**. Obfuscation only slows that down.

- Real secrets (third-party API secret keys, signing keys, admin tokens) stay **on a server**.
  The app calls your backend, and the backend calls the third party.
- Keys that are *meant* to be public (Firebase config, Maps keys, publishable payment keys) are
  fine in the app, but **restrict them** (bundle ID / SHA-1 / HTTP referrer, API scope) in the
  provider's console.
- Never commit secrets. Use `.gitignore` for local config, CI secret stores, and secret scanning
  (GitHub push protection / `gitleaks`) in CI.

## Storing data on the device

| Data | Store |
|---|---|
| Access/refresh tokens, credentials | `flutter_secure_storage` (Keychain / Keystore). Never `shared_preferences` |
| Personal data cached for offline | Encrypted DB (e.g. SQLCipher with drift) or keep it minimal |
| Settings, flags | `shared_preferences` |

- Clear tokens and cached personal data on sign-out.
- iOS: Keychain items **survive uninstall**. Clear them on the first launch after a reinstall
  if that matters.
- Hide sensitive screens in the app switcher (`FLAG_SECURE` on Android, a blur overlay on iOS when
  the app goes inactive) for banking, health or ID documents.

## Network

- HTTPS only: Android `network_security_config` with `cleartextTrafficPermitted="false"`, and
  iOS ATS left enabled.
- Certificate pinning only if your threat model needs it, and with a **backup pin plus a plan
  to rotate**. A bad pin bricks the app for every user.
- Validate on the server. Client-side validation is for UX, not security.

## Input & links

- Deep links, push payloads, QR codes and WebView messages are **untrusted input**: validate them,
  and never perform destructive actions without confirmation (`navigation-deeplinks.md`).
- WebViews: restrict navigation to allowed domains, turn JavaScript off unless needed, and never
  expose a JS bridge to arbitrary pages.
- Don't build SQL, file paths or shell arguments from user input without escaping.

## Hardening releases

- `--obfuscate --split-debug-info=…` on release builds, and upload the symbols.
- Android: R8/minify enabled, `android:allowBackup="false"` (or rules that exclude tokens),
  `debuggable` false in release, and `exported` set explicitly on components.
- Keep dependencies current. Run `flutter pub outdated` and check advisories before each release.
- For high-risk apps: root/jailbreak detection and app attestation (Play Integrity / App
  Attest) checked **on the server**.

## Privacy

- Collect the minimum. Every analytics property should have a purpose.
- **No PII in logs, analytics or crash reports**: no emails, names, phone numbers, tokens or free
  text. Use opaque user IDs.
- Ask for consent where the law requires it (analytics/ads in the EU, ATT on iOS) **before**
  collecting, and respect opt-out.
- Fill in the Play Data Safety form and the iOS privacy manifest (`PrivacyInfo.xcprivacy`)
  accurately, and include required-reason APIs used by plugins.

## Observability

### Crash reporting

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCrashReporting();                          // Crashlytics or Sentry

  FlutterError.onError = (details) => crash.recordFlutterError(details);
  PlatformDispatcher.instance.onError = (error, stack) {
    crash.record(error, stack, fatal: true);
    return true;
  };

  runApp(const App());
}
```

- Tag every report with **flavor, version, build number** and an opaque user ID.
- Use breadcrumbs (screen views, key actions) so you can see what led to a crash.
- Upload obfuscation symbols for every release (`flavors-ci-release.md`).

### Logging

- One `Logger` abstraction (e.g. the `logging` package) with levels. Debug logs go to the
  console in dev; warnings and errors go to the crash tool's breadcrumbs or a log backend in prod.
- Log **once** where an error is translated (the data layer), with context: endpoint, status,
  `AppError` type, request id. Not at every layer.
- Make logs **structured** (key/value) so they can be searched, and redact PII.

### Analytics

- An `Analytics` interface in `core/`, implemented by Firebase/Amplitude/etc. and faked in tests.
- **Typed events**: `analytics.track(CourseOpened(courseId: id))`, not `track('course_open', {...})`
  strings scattered around. Keep a tracking plan (event, properties, owner).
- Send screen views from the router (observer), not from each screen.
- Fire "viewed" events once per real view, not on every rebuild.

### Performance monitoring

Firebase Performance or Sentry tracing for app start, screen render times and network latency.
Watch the crash-free rate and ANRs (Android vitals) after every release.

## Checklist

- [ ] No real secrets in the app; public keys restricted; secret scanning in CI.
- [ ] Tokens in secure storage; cleared on sign-out.
- [ ] HTTPS enforced; links, payloads and WebViews treated as untrusted.
- [ ] Release builds obfuscated and minified, symbols uploaded.
- [ ] Crash reporting catches Flutter and platform errors, tagged with flavor and build.
- [ ] No PII in logs or analytics; consent handled; store privacy forms accurate.
