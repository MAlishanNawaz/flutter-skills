---
name: alishan
description: Builds and reviews Flutter apps with token-bound UI, feature-first layered architecture, functional immutable Dart, and tests that catch real overflows. Covers screens, widgets, Figma-to-Flutter, forms, state management (bloc, Riverpod, provider), networking and offline caching, go_router and deep links, performance, accessibility, theming, animation, flavors, CI and releases, security, and platform channels. Use for any Flutter or Dart app task, such as building a screen from a Figma link, structuring a feature or repository, fixing jank or a double submit, adding API calls, routing, writing tests, or setting up environments and secrets.
---

# Flutter playbook

## Rules

1. **Follow the project first.** Its tokens, widgets, state management, copy (user-facing strings) storage and lint rules win over anything in these guides.
2. **No raw design values in widgets.** Colours, text styles, spacing, radii and icons come from the project's tokens. If a value is missing, add a named token or round to the nearest step. Don't add a one-off token.
3. **Reuse before you build.** Search the shared widgets before writing a new button, card, dialog or input.
4. **Functional core, effects at the edges.** Use immutable data, pure functions for rules, sealed states, and errors returned as values. I/O happens only in repositories. `build()` stays pure.
5. **Layered and feature-first.** presentation → domain ← data. Dependencies arrive through constructors as interfaces.
6. **Stay in scope.** Change only what the task needs. Mention other problems you spot instead of fixing them, and format only the files you changed.
7. **Verify like a user.** Check phone width, the web content width and 2× text, and run analyze and the tests before you call it done.

## Start: learn the project

```bash
grep -rlE "class \w*(Colors|Palette|Spacing|Tokens)\b|ThemeExtension<" lib | head   # tokens
ls lib/common lib/shared lib/widgets lib/components lib/core/widgets 2>/dev/null    # shared widgets
grep -E "flutter_bloc|riverpod|provider|go_router|dio|freezed" pubspec.yaml          # stack
ls .fvmrc lib/l10n 2>/dev/null; cat CLAUDE.md CONTRIBUTING.md 2>/dev/null | head -50  # conventions
```

If `.fvmrc` exists, use `fvm flutter` and `fvm dart`. Use only packages already in `pubspec.yaml`. If one is missing, say so before you add it with `flutter pub add`, and pick a version that works with the project's current SDK constraint. Never raise the Dart or Flutter minimum to fit a package; ask first.

## Workflows

Copy the matching checklist into your response and tick off each item as you go.

### Build or change UI (screen, widget, Figma frame)

```
- [ ] 1. Read the token file; list the shared widgets that might fit
- [ ] 2. Figma: pull screenshot, design context and variables, then write a value → token map before any code
- [ ] 3. Build with tokens and existing widgets; copy in the project's strings location
- [ ] 4. Run scripts/check_tokens.sh, fix every hit, run again until clean
- [ ] 5. Widget test: phone + web content width, 2× text, no overflow, a11y guidelines
- [ ] 6. scripts/format_changed.sh, flutter analyze, flutter test
```

### Add a feature (data + state + UI)

```
- [ ] 1. Domain: immutable entity, repository interface, pure rules
- [ ] 2. Data: DTO + mapper, remote/local source, repository impl returning Result
- [ ] 3. Presentation: sealed state, state holder in the project's library, screen
- [ ] 4. Tests per layer with fakes (rules, mapper, repository, state holder, widget)
- [ ] 5. scripts/check_tokens.sh → scripts/format_changed.sh → flutter analyze → flutter test
```

### Add routing or a deep link

```
- [ ] 1. Read references/navigation-deeplinks.md before writing any router code
- [ ] 2. Auth state has three values: unknown (restoring), signedOut, signedIn. Unknown holds the link on a splash route
- [ ] 3. Redirect is a pure function carrying ?from=<in-app path>; path params are validated
- [ ] 4. Android: intent-filter + flutter_deeplinking_enabled inside <activity>; iOS: applinks in Runner.entitlements (not Info.plist)
- [ ] 5. Widget test: cold start (defaultRouteNameTestValue) signed out → login → target; invalid id → not found
```

### Fix a bug

```
- [ ] 1. Reproduce it in a test at the lowest layer that shows it; confirm the test fails
- [ ] 2. Fix the root cause (not the symptom), keeping the diff to what the bug needs
- [ ] 3. Confirm the test passes and the suite is green; note any related issues without fixing them
```

## Before your final message

Run the checks and paste the **last line of each one's real output** into your final message:

```
<skill-dir>/scripts/check_tokens.sh      → must print "check_tokens: clean"
<skill-dir>/scripts/format_changed.sh
flutter analyze                          → "No issues found!"
flutter test                             → "All tests passed!"
```

If a check fails, fix it and run it again. Only claim what these outputs show. If you couldn't run one, say so.

## Scripts (run them, don't read them)

| Script | Does |
|---|---|
| `scripts/check_tokens.sh [files…]` | Flags raw hex, Material colours, bare `TextStyle(`, and numeric gaps, paddings and radii in changed `lib/` files. Skips the token file. Exits 1 on findings. |
| `scripts/format_changed.sh [--check] [files…]` | Runs `dart format` on changed files only. Uses `formatter: page_width` from `analysis_options.yaml` when set. |
| `scripts/changed_dart_files.sh [base]` | Lists the branch's changed `.dart` files; the two scripts above use it. |

Run them from the project root using the skill's directory, for example `<skill-dir>/scripts/check_tokens.sh`. Without git, pass the files explicitly.

## Guides (read only the one the task needs)

**UI**
- Tokens, rounding and adding tokens: [references/design-tokens.md](references/design-tokens.md)
- Screens, widget reuse and layout: [references/ui-components.md](references/ui-components.md)
- Figma to Flutter: [references/figma-to-flutter.md](references/figma-to-flutter.md)
- Forms, validation timing and safe submit: [references/forms.md](references/forms.md)
- Accessibility, dark mode and RTL: [references/accessibility-theming.md](references/accessibility-theming.md)
- Animation and motion: [references/animation-motion.md](references/animation-motion.md)

**Structure**
- Layers, folders and dependency injection: [references/architecture.md](references/architecture.md)
- Immutability, sealed states and `Result`: [references/functional-programming.md](references/functional-programming.md)
- bloc, Riverpod and provider: [references/state-management.md](references/state-management.md)
- HTTP, auth refresh, caching, offline and pagination: [references/networking-offline.md](references/networking-offline.md)
- go_router, auth redirects and deep links: [references/navigation-deeplinks.md](references/navigation-deeplinks.md)
- Permissions, push, Pigeon and lifecycle: [references/platform-integration.md](references/platform-integration.md)

**Quality and shipping**
- Widget and layout tests: [references/ui-testing.md](references/ui-testing.md)
- Test pyramid, fakes and E2E: [references/testing-strategy.md](references/testing-strategy.md)
- Jank, lists, images and startup: [references/performance.md](references/performance.md)
- Flavors, CI and store releases: [references/flavors-ci-release.md](references/flavors-ci-release.md)
- Secrets, hardening, logging and analytics: [references/security-observability.md](references/security-observability.md)

**Starters**
- A complete tested feature: [examples/profile_feature/](examples/profile_feature/)
- A token file: [references/tokens_template.dart](references/tokens_template.dart)
- Lint rules: [references/analysis_options.yaml](references/analysis_options.yaml)
