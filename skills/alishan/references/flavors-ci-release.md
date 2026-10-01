# Flavors, CI & releases

## Contents
- Toolchain
- Flavors and config
- Keeping QA builds out of production
- CI
- Releases

## Toolchain

Pin Flutter with fvm (`.fvmrc`), and use `fvm flutter` both locally and in CI. A different global Flutter can break dependency resolution. Commit `pubspec.lock` for apps, not for packages.

## Flavors

- Use **native flavors** with **distinct application/bundle IDs** (`com.example.app.dev`, `.qa`, and the plain ID for prod), with their own name, icon badge and Firebase project or push keys.
- Dart config comes from a JSON file per flavor:
  ```bash
  flutter run --flavor qa --dart-define-from-file=config/qa.json
  flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json \
    --obfuscate --split-debug-info=build/symbols --build-number=$CI_RUN
  ```
- **Fail fast at startup**: missing values, a non-https prod URL, or `appFlavor` (from `--flavor`) disagreeing with `FLAVOR` from the JSON.
- `--dart-define` values are compiled into the binary. They're config, not secrets (see [security-observability.md](security-observability.md)).

## Keep QA builds out of production

A common, expensive failure: QA and prod pipelines share one store package and one track, so a QA build ships to users.

1. Distinct IDs make it impossible on the store listing.
2. Put a **release guard** in the prod pipeline that fails unless the flavor is prod, the API URL is the prod URL, and the payment key is live.
3. Show the flavor and build number in the app (an about screen or a non-prod ribbon), and tag every crash and log with them.

## CI

```yaml
- uses: kuhnroyal/flutter-fvm-config-action@v2     # reads .fvmrc
  id: fvm
- uses: subosito/flutter-action@v2
  with: { flutter-version: "${{ steps.fvm.outputs.FLUTTER_VERSION }}", cache: true }
- run: flutter pub get
- run: dart format --output=none --set-exit-if-changed .
- run: flutter analyze --fatal-infos
- run: flutter test --coverage
```

- Private Git dependencies: authenticate with a CI secret plus `git config --global url."https://x-access-token:${TOKEN}@github.com/".insteadOf "https://github.com/"`. Never put tokens in `pubspec.yaml`.
- When a build step fails, check whether it also fails on main (a flaky runner, or a third-party Maven/CocoaPods credential) before blaming the diff.

## Releases

- The build number only goes up per store. Generate it in CI.
- Android: an AAB to the internal track, then a staged rollout. iOS: `match` or App Store Connect API keys, then TestFlight, then a phased release.
- Web: long cache on hashed assets; `no-cache` on `index.html`, `flutter_service_worker.js` and `version.json`.
- Upload the `--split-debug-info` symbols on every release, or crash reports can't be read.
- Rollback means halting the rollout or shipping a hotfix with a higher build number. You can't go back to a lower one.
