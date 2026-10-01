import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/features/profile/domain/profile_rules.dart';

import 'fakes.dart';

void main() {
  group('completionPercent', () {
    test('counts filled sections', () => expect(completionPercent(ada), 60));
    test('100 when everything is filled', () {
      expect(completionPercent(ada.copyWith(bio: 'Mathematician', photoUrl: 'https://x/y.png')), 100);
    });
    test('whitespace does not count', () => expect(completionPercent(ada.copyWith(bio: '   ')), 60));
  });

  test('displayName and initials skip blanks', () {
    final p = ada.copyWith(lastName: ' ');
    expect(displayName(p), 'Ada');
    expect(initials(ada), 'AL');
  });

  group('validators compose', () {
    final name = all([required('Required'), maxLength(5, 'Too long')]);
    test('first failing rule wins', () {
      expect(name(''), 'Required');
      expect(name('Abcdefg'), 'Too long');
      expect(name('Ada'), isNull);
    });
  });
}
