---
name: alishan
description: Alishan's Flutter playbook — architect apps in clean feature-first layers with functional, immutable Dart, and build screens, widgets and Figma designs in any Flutter app with every colour, text style, radius and gap bound to a design token, shared widgets reused before new ones are written, layouts that hold up on phones and narrow web columns, UI tests that catch real overflows, plus state management, performance, accessibility, theming and forms. Use when creating or refactoring a Flutter screen, card, dialog, button or input; when implementing a Figma frame or figma.com link in Flutter; when setting up or auditing a design-token file; when writing widget/layout tests for UI; or when designing app architecture, structuring features, repositories, state and error handling, or writing functional-style Dart (immutability, pure functions, sealed states, Result types); when writing a bloc/cubit/Riverpod/provider state holder; when fixing jank or slow lists; when handling accessibility, dark mode or RTL; or when building forms and validation.
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

| Task | Read |
|---|---|
| Find, use, or create the project's tokens (colours, text, spacing, radius) | `references/design-tokens.md` |
| Build or refactor a screen / widget | `references/ui-components.md` |
| Implement a Figma frame or figma.com link | `references/figma-to-flutter.md` (and the two above) |
| Write widget, layout or golden tests for UI | `references/ui-testing.md` |
| Model data/state, write business logic, handle errors functionally | `references/functional-programming.md` |
| Structure an app or feature, add a repository, wire DI, review architecture | `references/architecture.md` |
| Write a bloc/cubit, Riverpod notifier, ChangeNotifier; decide where state lives | `references/state-management.md` |
| Jank, slow lists, heavy images, startup time, memory leaks | `references/performance.md` |
| Screen readers, tap targets, text scale, contrast, dark mode, RTL | `references/accessibility-theming.md` |
| Build a form: validation, error timing, keyboard/focus, safe submit | `references/forms.md` |
| See all of the above in real, tested code | `examples/profile_feature/` (one complete feature) |
| Project has no token file yet | `references/tokens_template.dart` as a starting point |

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
- [ ] `dart format`, `flutter analyze` clean; tests pass.
