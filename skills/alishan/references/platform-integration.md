# Platform integration

## Platform checks

- Check `kIsWeb` **first**, then `defaultTargetPlatform`. Never import `dart:io` (`Platform.isIOS`, `SocketException`) in code that compiles for web. Use conditional imports or keep it behind the HTTP client.
- Put platform differences behind an interface (`Haptics`, `ShareService`, `PushService`) and inject the implementation. Widgets shouldn't be full of `if (isIOS)`.
- `kIsWeb` is always false under `flutter test` on the VM, so inject the flag to test both paths.

## Plugins

Prefer a maintained plugin: a verified publisher or Flutter Favorite, recent releases, every platform you ship covered. Complete its native setup (manifest entries, Info.plist keys, min SDK), and wrap it in your own interface so it can be faked and swapped.

## Custom native code

- Prefer **Pigeon**: typed, generated bindings (`dart run pigeon --input pigeons/x.dart`).
- For a quick one-off, use a `MethodChannel` call that catches `PlatformException` and `MissingPluginException` and maps them to `AppError` or `null`. Never let a platform exception reach the UI.
- Do heavy native work off the platform main thread.

## Permissions

- Ask **in context**, just before the feature needs it, after a one-line in-app explanation. Never ask on first launch.
- Handle every status: granted, denied (ask again later), permanently denied (`openAppSettings()`), and limited (iOS photos).
- Write specific usage strings in `Info.plist`; vague ones get rejected in review. Re-check the status when the app resumes.

## Push notifications

- Ask for permission in context. Android 13+ needs a runtime prompt.
- Route all three entry points through the router: a foreground message, a tap from the background, and a tap that cold-starts the app (`getInitialMessage`).
- Sync the device token on receipt **and on refresh**, and unregister it on sign-out.
- Fire "opened" or "viewed" backend events once per open, not on every rebuild.

## Lifecycle

Use `AppLifecycleListener`. On resume, refresh stale data and re-check permissions. On pause, close sockets and timers and save drafts, because the OS can kill a backgrounded app without warning.

## Other touchpoints

- `url_launcher`: check `canLaunchUrl` and handle failure.
- `image_picker`: downscale before upload and clean up temp files.
- `workmanager`: iOS runs it rarely and briefly.
- `local_auth`: only a convenience unlock for a token already in secure storage, never the only proof of identity.
