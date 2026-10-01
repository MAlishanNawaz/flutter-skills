/// Auth redirect for go_router (or any router), as a pure function so it can be unit-tested.
///
/// The cold-start trap: a deep link arrives before the saved session is restored. If "still
/// restoring" were treated as "signed out", the link would be lost. Hence three states, and the
/// pending location travels in `?from=` until the user lands on it.
enum AuthStatus { unknown, signedOut, signedIn }

abstract final class AuthRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
}

/// Returns where to redirect, or null to stay. Wire it up as
/// `GoRouter(redirect: (_, s) => authRedirect(auth.status, s.uri), refreshListenable: auth)`.
String? authRedirect(AuthStatus status, Uri location) {
  final path = location.path;
  final onSplash = path == AuthRoutes.splash;
  final onLogin = path == AuthRoutes.login;
  final pending = (onSplash || onLogin) ? safeReturnPath(location.queryParameters['from']) : location.toString();

  return switch (status) {
    AuthStatus.unknown => onSplash ? null : _withFrom(AuthRoutes.splash, pending),
    AuthStatus.signedOut => onLogin ? null : _withFrom(AuthRoutes.login, pending),
    AuthStatus.signedIn => (onSplash || onLogin) ? (pending ?? AuthRoutes.home) : null,
  };
}

/// Accepts only in-app paths. Link input is untrusted: `//evil.com`, `https://…` and backslash
/// tricks would otherwise become open redirects, and the auth routes themselves would loop.
String? safeReturnPath(String? raw) {
  if (raw == null || raw.isEmpty || !raw.startsWith('/') || raw.startsWith('//') || raw.contains(r'\')) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (uri.path == AuthRoutes.splash || uri.path == AuthRoutes.login) return null;
  return raw;
}

String _withFrom(String route, String? from) =>
    from == null || from == AuthRoutes.home ? route : '$route?from=${Uri.encodeComponent(from)}';

/// Path ids from links are untrusted too. Validate before loading.
bool isValidId(String? id) => id != null && RegExp(r'^[0-9]{1,12}$').hasMatch(id);
