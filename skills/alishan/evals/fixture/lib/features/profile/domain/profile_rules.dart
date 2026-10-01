import 'profile.dart';

// Pure business rules: same input, same output, no I/O. Trivial to unit-test.

/// Share of optional profile sections filled in, 0–100.
int completionPercent(Profile p) {
  final checks = <bool>[
    p.firstName.trim().isNotEmpty,
    p.lastName.trim().isNotEmpty,
    p.email.trim().isNotEmpty,
    (p.bio ?? '').trim().isNotEmpty,
    (p.photoUrl ?? '').trim().isNotEmpty,
  ];
  return (checks.where((done) => done).length * 100 / checks.length).round();
}

String displayName(Profile p) => [p.firstName, p.lastName].map((s) => s.trim()).where((s) => s.isNotEmpty).join(' ');

String initials(Profile p) =>
    [p.firstName, p.lastName].map((s) => s.trim()).where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).join();

typedef Validator = String? Function(String value);

Validator required(String message) => (v) => v.trim().isEmpty ? message : null;
Validator maxLength(int n, String message) => (v) => v.trim().length > n ? message : null;

Validator all(List<Validator> validators) => (v) {
      for (final validate in validators) {
        final error = validate(v);
        if (error != null) return error;
      }
      return null;
    };
