# Security & observability

## Secrets: the app binary is public

Anything shipped can be extracted, and obfuscation only slows that down. That covers Dart constants, `--dart-define` values, bundled `.env`/assets and native config.

- **Secret keys** (payment secret keys, third-party API secrets, admin tokens) live only on the backend, in its secret store. The app calls your backend, which calls the provider. For payments, the backend creates the intent with the secret key and returns a single-use client secret, and payment success is confirmed by webhook, never trusted from the client.
- **Public keys** (publishable payment keys, Firebase and Maps config) may ship, but **restrict them** in the provider console by bundle ID, SHA-1, referrer and scope. Use test keys in dev/qa and live keys only in prod, and reject a secret-looking key (`sk_`, `rk_`) in app config at startup.
- Never commit secrets. Use secret scanning and push protection, plus `gitleaks` in CI. Rotate any key that has ever been in the app, git history or chat.

## Device storage

- Tokens and credentials go in `flutter_secure_storage`, never `shared_preferences`. Clear them on sign-out. iOS Keychain items survive an uninstall, so clear them on the first launch after a reinstall if that matters.
- Encrypt cached personal or financial data, or don't persist it.
- Hide sensitive screens in the app switcher (`FLAG_SECURE`, or an iOS blur on inactive).

## Hardening

- HTTPS only: Android `cleartextTrafficPermitted="false"`, and leave iOS ATS on.
- Cert pinning only if the threat model needs it, and always with a backup pin and a rotation plan.
- Release builds: `--obfuscate --split-debug-info`, R8 on, `allowBackup="false"` (or rules that exclude tokens), and `exported` set explicitly.
- Deep links, push payloads, QR codes and WebView messages are untrusted input. Validate them, and never take destructive actions without confirmation.

## Privacy

- **No PII in logs, analytics or crash reports.** Use opaque user IDs.
- Get consent before collecting where required (EU analytics, iOS ATT).
- Keep the Play Data Safety form and the iOS `PrivacyInfo.xcprivacy` accurate.

## Observability

- **Crashes**: route both `FlutterError.onError` and `PlatformDispatcher.instance.onError` to Crashlytics or Sentry. Tag every report with flavor, version and build number, and add breadcrumbs for screens and key actions.
- **Logs**: use one `Logger` abstraction with structured key/value entries and PII redacted. Log once, where the error is translated (the data layer), with the endpoint, status, `AppError` type and request id.
- **Analytics**: an interface in `core/` with typed events (`track(CourseOpened(id))`), not stray strings. Send screen views from a router observer. Fire "viewed" once per real view.
- After each release, watch the crash-free rate and ANRs.
