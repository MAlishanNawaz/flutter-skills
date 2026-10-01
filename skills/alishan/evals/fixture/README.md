# Eval fixture app

The starting project for every eval in `../evals.json`. Copy it into a fresh git repo for each run:

```bash
cp -R evals/fixture /tmp/run && cd /tmp/run && git init -q && git add -A && git commit -qm fixture && flutter pub get
```

It has a token file (`lib/core/design/tokens.dart`), a profile feature in presentation/domain/data, and two deliberately flawed screens: `lib/features/courses/courses_screen.dart` (jank) and `lib/features/signup/signup_screen.dart` (double submit, eager validation).
