import 'package:flutter_test/flutter_test.dart';
import 'package:profile_feature_example/core/routing/auth_redirect.dart';

void main() {
  final link = Uri.parse('/courses/42');

  test('cold start: the link waits on splash while the session restores', () {
    expect(authRedirect(AuthStatus.unknown, link), '/splash?from=%2Fcourses%2F42');
  });

  test('restore finds no session: splash hands the link to login', () {
    expect(
      authRedirect(AuthStatus.signedOut, Uri.parse('/splash?from=%2Fcourses%2F42')),
      '/login?from=%2Fcourses%2F42',
    );
  });

  test('after sign-in the user lands on the link', () {
    expect(authRedirect(AuthStatus.signedIn, Uri.parse('/login?from=%2Fcourses%2F42')), '/courses/42');
  });

  test('signed in and already on a page: stay', () => expect(authRedirect(AuthStatus.signedIn, link), isNull));

  test('from= only accepts in-app paths', () {
    for (final bad in ['//evil.com', 'https://evil.com', r'/\evil.com', '/login', 'courses']) {
      expect(safeReturnPath(bad), isNull, reason: bad);
    }
    expect(safeReturnPath('/courses/42?tab=info'), '/courses/42?tab=info');
  });

  test('ids from links are validated', () {
    expect(isValidId('42'), isTrue);
    for (final bad in ['abc', '', '1' * 13, '42;drop']) {
      expect(isValidId(bad), isFalse, reason: bad);
    }
  });
}
