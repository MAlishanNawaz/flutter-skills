---
name: alishan
description: Alishan's end-to-end Flutter playbook. It covers clean feature-first architecture with functional, immutable Dart; UI where every colour, text style, radius and gap is a design token; Figma-to-Flutter translation; state management (bloc/cubit, Riverpod, provider); forms; performance; accessibility, theming and dark mode; animation; networking, caching and offline; navigation and deep links; testing from unit tests to E2E; flavors, CI/CD and store releases; security, logging and analytics; and native platform integration. Use for any Flutter or Dart app work: building or refactoring screens and widgets, implementing a Figma frame or figma.com link, structuring a feature or repository, writing state holders, fixing jank, adding API calls or offline support, routing and deep links, writing tests, setting up environments or release pipelines, handling secrets, permissions, push notifications or platform channels. Do not use for non-Flutter work.
---

# Flutter — Alishan's playbook

Six rules sit under everything here:

1. **No raw values in a widget tree.** Colours, text styles, radii and spacing come from the
   project's design tokens. A `Color(0xff…)`, a bare `TextStyle(`, or a magic `SizedBox(height: 18)`
   is a bug.
2. **Reuse before you build.** Search the shared widget folder before writing a new button,
   card, dialog or input. A duplicate widget is the most common review comment.
3. **Design for the narrowest column.** Phones first, and web layouts that clamp content width.
   Fixed widths and unscrollable columns break.
4. **Verify like a user.** Analyze, test with the real theme and real fonts, and compare
   against the design at phone width *and* at the web content width.
5. **Functional core, effects at the edges.** Immutable data, pure functions for business
   rules, sealed types for state, errors returned as values. I/O lives only in repositories.
6. **Layered, feature-first architecture.** Presentation → domain ← data; dependencies point
   inwards and arrive through constructors as interfaces.

## Pick the guide for the task

**Build the UI**

| Task | Read |
|---|---|
| Find, use or create the project's tokens (colours, text, spacing, radius) | `references/design-tokens.md` |
| Build or refactor a screen / widget | `references/ui-components.md` |
| Implement a Figma frame or figma.com link | `references/figma-to-flutter.md` (and the two above) |
| Forms: validation, error timing, keyboard/focus, safe submit | `references/forms.md` |
| Screen readers, tap targets, text scale, contrast, dark mode, RTL | `references/accessibility-theming.md` |
| Implicit/explicit animation, Hero, page transitions, reduced motion | `references/animation-motion.md` |

**Structure the app**

| Task | Read |
|---|---|
| Layers, feature folders, repositories, DI, architecture review | `references/architecture.md` |
| Immutable data, pure functions, sealed states, `Result` errors | `references/functional-programming.md` |
| bloc/cubit, Riverpod, provider; where state lives | `references/state-management.md` |
| HTTP client, auth refresh, retries, caching, offline sync, pagination | `references/networking-offline.md` |
| Routes, auth redirects, tabs, deep links / App Links / Universal Links, web URLs | `references/navigation-deeplinks.md` |
| Permissions, push notifications, Pigeon/channels, lifecycle, `kIsWeb` | `references/platform-integration.md` |

**Quality & shipping**

| Task | Read |
|---|---|
| Widget, layout, golden tests; real fonts; sizes and text scale | `references/ui-testing.md` |
| Test pyramid, fakes, bloc tests, integration/Patrol E2E, coverage, CI tests | `references/testing-strategy.md` |
| Jank, slow lists, heavy images, startup time, memory leaks | `references/performance.md` |
| Flavors, `--dart-define`, versioning, CI pipeline, store releases | `references/flavors-ci-release.md` |
| Secrets, secure storage, hardening, privacy, crash reporting, logging, analytics | `references/security-observability.md` |

**Starters**

| Need | Use |
|---|---|
| A complete, tested feature to copy patterns from | `examples/profile_feature/` |
| Project has no token file | `references/tokens_template.dart` |
| Project has weak or no lints | `references/analysis_options.yaml` |

Read only the guides the task needs.

## First step in any project: learn its conventions

Before writing UI code, spend a minute finding out what the project already has. Its
conventions beat the generic advice in these guides.

```bash
# Token file(s): colours, text styles, spacing
grep -rlE "class \w*(Colors|Palette|Spacing|Sizes|Styles|Tokens)\b|ThemeExtension<" lib | head
# Shared widgets
ls lib/common lib/shared lib/widgets lib/components lib/ui 2>/dev/null
# State management in use
grep -E "flutter_bloc|provider|riverpod|get:|mobx" pubspec.yaml
# How copy is stored (l10n ARB, a strings class, or neither)
ls lib/l10n 2>/dev/null; grep -rlE "class \w*Strings\b" lib | head -3
# Pinned Flutter version
ls .fvmrc .fvm/fvm_config.json 2>/dev/null
```

- If the project pins Flutter with **fvm**, run every command as `fvm flutter …`.
- Follow the **state management the project already uses**. Don't bring in Riverpod in a bloc
  app, or the other way round.
- Put new copy **wherever the project keeps copy now** (ARB files, a strings class), even when
  the template suggests another place.
- Read the project's `CLAUDE.md` / `CONTRIBUTING.md` for branch, changelog and format rules.

## Definition of done

- [ ] No raw hex, no bare `TextStyle(`, no magic spacing or radius numbers in the diff.
- [ ] Reused an existing shared widget, or can say why a new one is needed.
- [ ] Copy lives where the project keeps copy, not as string literals in the widget tree.
- [ ] Renders at phone width and at the web content width; scrolls where content can overflow;
      `SafeArea` at the edges.
- [ ] Labelled for screen readers, 48 dp targets, holds at 2× text, works in dark mode if the app has it.
- [ ] Logic in pure functions; state immutable; no I/O in widgets; layer boundaries respected.
- [ ] Failures mapped to `AppError` and shown to the user; nothing secret or personal in the app
      binary or logs.
- [ ] Tests at the lowest layer that covers the change (unit → state holder → widget → E2E).
- [ ] `dart format`, `flutter analyze` clean; tests pass.
