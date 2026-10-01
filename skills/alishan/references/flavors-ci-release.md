# Flavors, CI/CD & releases

## Pin the toolchain

- Pin Flutter with **fvm** (`.fvmrc`) and use `fvm flutter …` locally *and* in CI. A different
  global Flutter version can break dependency resolution or produce different builds.
- Commit `pubspec.lock` for apps (not for packages).
- Write the Dart/Flutter constraints into `pubspec.yaml` `environment:` to match.

## Environments (flavors)

Use separate **native flavors** (Android `productFlavors`, iOS schemes/configurations) for each
environment, with **different application IDs**, so dev/QA/prod can be installed side by side and
can never be mistaken for each other:

| | dev | qa | prod |
|---|---|---|---|
| App ID | `com.example.app.dev` | `com.example.app.qa` | `com.example.app` |
| Name / icon | "App Dev" + badge | "App QA" + badge | "App" |
| Backend | dev API | QA API | prod API |
| Firebase project / push keys | dev | qa | prod |

Dart-side config comes from a JSON file per flavor, read at compile time:

```bash
flutter run --flavor qa --dart-define-from-file=config/qa.json
flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json --obfuscate --split-debug-info=build/symbols
```

```dart
abstract final class Env {
  static const flavor = String.fromEnvironment('FLAVOR');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static void assertValid() {
    if (apiBaseUrl.isEmpty) throw StateError('API_BASE_URL missing, check --dart-define-from-file');
  }
}
```

- Values in `--dart-define` are **compiled into the binary** and can be extracted. They're
  config, **not secrets** (see `security-observability.md`).
- Fail fast at startup if required config is missing.

### Keep QA builds out of production

A common, expensive mistake: QA and prod pipelines share **one store package and one track**, so
a QA build gets promoted, or a failed prod run leaves the QA build live.

- Separate application IDs (above) make that impossible for store listings.
- If the stores force one ID, separate by **track** (internal for QA, production for prod)
  *and* add a guard step in the prod pipeline that fails unless `FLAVOR == prod` and the API URL
  is the prod URL.
- Show the flavor and build number on a debug/about screen, and send them with every crash and
  log, so "which build is this user on?" takes one look.

## Versioning

- `version: 2.4.0+410` → name `2.4.0`, build number `410`. The build number must **only go up**
  per store. Generate it in CI (run number or a timestamp) instead of editing it by hand.
- Tag releases (`v2.4.0`) and keep a `CHANGELOG.md` (Unreleased → version on release).

## CI pipeline (every PR)

```yaml
# .github/workflows/ci.yml (sketch)
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: kuhnroyal/flutter-fvm-config-action@v2          # reads .fvmrc
        id: fvm
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ steps.fvm.outputs.FLUTTER_VERSION }}
          channel: ${{ steps.fvm.outputs.FLUTTER_CHANNEL }}
          cache: true
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
```

- Cache pub and Gradle. Run Android/iOS builds only for main or release branches, or with a
  label, if they're slow.
- Private Git dependencies: authenticate with a **CI secret** plus
  `git config --global url."https://x-access-token:${TOKEN}@github.com/".insteadOf "https://github.com/"`.
  Never commit tokens in `pubspec.yaml`.
- When a build step fails, check whether it fails on main too (a flaky runner, or a dead
  third-party Maven/CocoaPods credential) before blaming your diff. Re-run once.

## CD (releases)

- **Android**: signed `appbundle` → Play Console via Fastlane `supply` or the Play Developer API;
  start on the **internal** track, then promote to closed, staged production (e.g. 10% → 50% →
  100%).
- **iOS**: signing via Fastlane `match` (or App Store Connect API keys); build an IPA → TestFlight
  → phased release.
- **Web**: `flutter build web --release` → hosting with long cache headers on hashed assets, and
  `no-cache` on `index.html`, `flutter_service_worker.js` and `version.json`.
- Tools: Fastlane, Codemagic or GitHub Actions. Choose one and keep signing config in its
  secret store.
- Upload **symbols** for every release (`--split-debug-info` output → Crashlytics/Sentry), or
  obfuscated crash reports can't be read.

## Release checklist

- [ ] Correct flavor, app ID and API URL for this pipeline (guard step passed).
- [ ] Build number higher than the last store build.
- [ ] CHANGELOG updated; tag pushed.
- [ ] Smoke-tested the store build (internal track/TestFlight), not just a local debug build.
- [ ] Symbols uploaded; crash-free rate and logs watched for the first hours of a staged rollout.
- [ ] Rollback plan: halt the staged rollout, or ship a hotfix with a higher build number. Stores
      don't let you go back to a lower build number.
