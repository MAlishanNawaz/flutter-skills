# Platform integration

## Platform checks

```dart
import 'package:flutter/foundation.dart';

final isWeb = kIsWeb;                                          // check this FIRST
final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
```

- Don't `import 'dart:io'` in code that compiles for web. `Platform.isIOS` throws there.
  Use `defaultTargetPlatform`, or conditional imports (`if (dart.library.js_interop)`).
- Hide platform differences **behind an interface** (`Haptics`, `FilePicker`, `ShareService`)
  with an implementation per platform, injected at startup. Widgets shouldn't be full of
  `if (isIOS)` checks.
- `kIsWeb` is always false under `flutter test` on the VM. Inject the platform choice so both
  paths can be tested (`ui-testing.md`).
- Adapt the UI where users expect it: `Switch.adaptive`, `CircularProgressIndicator.adaptive`,
  Cupertino-style dialogs and back-swipe on iOS. Keep brand components the same everywhere.

## Plugins first

Before writing native code, check pub.dev for a **well-maintained** plugin: a verified
publisher or Flutter Favorite, recent releases, support for every platform you ship, and open
issues getting answered. Read its native setup steps (manifest entries, Info.plist keys,
minimum SDK).

When you depend on a plugin, wrap it in your own interface. That lets you fake it in tests and
swap it out if it's abandoned.

## Writing your own platform code

### Pigeon (preferred)

Type-safe, generated bindings instead of hand-written channel strings:

```dart
// pigeons/battery.dart
@ConfigurePigeon(PigeonOptions(dartOut: 'lib/core/platform/battery_api.g.dart', kotlinOut: '...', swiftOut: '...'))
@HostApi()
abstract class BatteryApi {
  @async
  int level();
}
```

```bash
dart run pigeon --input pigeons/battery.dart
```

Then implement `BatteryApi` in Kotlin/Swift. Calls are async, typed and null-safe.

### MethodChannel (small one-offs)

```dart
const _channel = MethodChannel('com.example.app/battery');
Future<int?> batteryLevel() async {
  try {
    return await _channel.invokeMethod<int>('level');
  } on PlatformException catch (e) {
    log.warning('battery level failed', e);
    return null;
  } on MissingPluginException {
    return null;                                            // platform without an implementation
  }
}
```

- Use `EventChannel` for streams (sensors, native events), and cancel subscriptions.
- Platform calls are async and can fail. Map failures to `AppError` or `null`; never let a
  `PlatformException` reach the UI.
- Heavy native work goes on a background thread on the native side, not the platform main thread.

## Permissions

```dart
Future<bool> ensureCamera() async {
  var status = await Permission.camera.status;
  if (status.isGranted) return true;
  if (status.isPermanentlyDenied) return false;          // UI offers "Open settings" → openAppSettings()
  status = await Permission.camera.request();
  return status.isGranted;
}
```

- Ask **in context**, just before the feature needs it, after a short in-app explanation. Never
  ask for everything on first launch.
- Handle denied (offer to ask again later), permanently denied (link to settings) and limited
  (iOS limited photos).
- Declare usage strings (`NSCameraUsageDescription` etc.) and Android manifest permissions. The
  stores reject apps whose purpose strings are missing or vague.
- Re-check status when the app resumes (`AppLifecycleListener`), since the user may have changed
  it in Settings.

## Push notifications

- FCM for both platforms (with APNs configured for iOS), or your provider's SDK, behind a
  `PushService` interface.
- Ask for notification permission in context (Android 13+ also needs runtime permission).
- Handle **three entry points** and send them all through the router (`navigation-deeplinks.md`):
  foreground message (show in-app or local notification), tap from background, and tap that
  cold-starts the app (`getInitialMessage`).
- Send the device token to the backend when you get it **and when it refreshes**. Unregister on
  sign-out.
- Android: create notification channels with sensible importance. iOS: set foreground
  presentation options.

## App lifecycle

```dart
late final _lifecycle = AppLifecycleListener(
  onResume: () => context.read<SessionCubit>().refreshIfStale(),
  onPause: () => _socket.close(),
);
```

- Refresh stale data when the app resumes. Pause sockets, timers and location in the background.
- Save drafts on pause, because the OS can kill a backgrounded app without warning.
- Android can restore an app into a fresh process. Use ids in routes so screens can reload.

## Other native touchpoints

- **Share / open URLs / email**: `share_plus`, `url_launcher` (check `canLaunchUrl`, handle
  failure).
- **Files & camera**: `image_picker`/`file_picker`; compress or downscale before upload; clean
  up temp files.
- **Background work**: `workmanager` (Android WorkManager / iOS BGTaskScheduler). Expect iOS to
  run it rarely and briefly.
- **Biometrics**: `local_auth` as a convenience unlock for a token that's already in secure
  storage, never as the only proof of identity.
- **In-app review/updates**: ask after a success moment, rarely, and let the store throttle it.
- **Home-screen widgets, App Clips, watch apps**: native code with data shared through app
  groups or shared storage. Treat them as small native apps.

## Checklist

- [ ] Platform checks start with `kIsWeb`; no `dart:io` in web code; differences behind interfaces.
- [ ] Plugins vetted and wrapped; native setup (manifest/Info.plist) complete.
- [ ] Custom native code uses Pigeon, or a channel with error handling and no main-thread blocking.
- [ ] Permissions requested in context; denied and permanently denied handled; purpose strings
      clear.
- [ ] Push: foreground, background tap and cold-start tap all routed; token refresh synced.
- [ ] Lifecycle handled: refresh on resume, pause work in background, drafts saved.
