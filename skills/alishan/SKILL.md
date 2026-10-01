---
name: alishan
description: Opinionated Flutter playbook covering design-token-bound UI, feature-first presentation/domain/data layers, functional immutable Dart, and the Flutter gotchas that cost hours. Use for any Flutter or Dart app task.
---

# Flutter playbook

Where the project already has conventions (tokens, widgets, state library, strings location, lint rules), follow them, even where this playbook differs.

## Opinions

- **Widgets use design tokens, not raw values.** That covers colours, text styles, spacing and radii. Spacing that's off the scale gets rounded to the nearest step and flagged; it doesn't get a new token. `scripts/find_tokens.sh` locates the token file.
- **Feature-first layers: presentation → domain ← data.** Domain code is pure Dart. Repositories own I/O and return `Result`/`AppError` instead of throwing. State is immutable and sealed.
- **Change only what the task needs.** Mention anything else you notice. Raising the Dart or Flutter SDK minimum for a package needs the user's go-ahead.
- **Nothing secret ships in the app.** That includes `--dart-define` values. Logs, analytics and crash reports carry no personal data.

## References

Copy the patterns from the code rather than from prose.

- [examples/profile_feature/](examples/profile_feature/): a complete feature with tests. It covers:
  - entity, repository, DTO and `Result`
  - sealed state and a cubit
  - a form with a double-submit guard
  - the cold-start auth redirect
  - fakes and a widget-test harness
- [examples/deeplink_config/](examples/deeplink_config/): Android, iOS and website files for verified links.
- [templates/](templates/): a token file and a lint set for projects without them.

## Gotchas

Read the file for the area you're working in.

- [gotchas/ui.md](gotchas/ui.md): tokens, Figma, layout, forms, accessibility, motion
- [gotchas/data.md](gotchas/data.md): layers, state, networking, caching, pagination
- [gotchas/platform.md](gotchas/platform.md): routing and deep links, platform APIs, security, release
- [gotchas/testing.md](gotchas/testing.md): the Ahem font trap, harness, fakes, E2E, performance

## Checks

Run these from the project root; use `fvm` if the project pins Flutter.

```bash
<skill-dir>/scripts/check_tokens.sh     # raw design values in changed lib/ files
<skill-dir>/scripts/format_changed.sh   # formats only changed files, at the project's line length
flutter analyze && flutter test
```
