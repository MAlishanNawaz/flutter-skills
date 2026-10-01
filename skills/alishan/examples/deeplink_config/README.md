# Deep-link config reference

Pairs with `examples/profile_feature/lib/core/routing/auth_redirect.dart` (cold-start redirect).

- Serve both `.well-known` files from the link's host: HTTP 200, `application/json`, no redirects. The AASA file has no extension.
- `package_name` / `appIDs` must match the app's applicationId and `TEAMID.bundleId` exactly.
- Include the Play App Signing fingerprint, not just your upload key, or verification fails for store installs.

Test a cold start:

```bash
adb shell am force-stop com.example.app
adb shell am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://example.com/courses/42" com.example.app
adb shell pm get-app-links com.example.app
xcrun simctl terminate booted com.example.app
xcrun simctl openurl booted "https://example.com/courses/42"
```
