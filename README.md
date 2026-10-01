# Flutter Skills

[Claude Code](https://claude.com/claude-code) skills for building Flutter apps the way I do:
layered feature-first architecture, functional Dart, and UI that is token-driven, reuse-first,
responsive, and tested with real fonts.

## Skills

### `/alishan`: Flutter playbook

One entry point that loads the right guide for the task:

| Guide | Covers |
|---|---|
| [`design-tokens.md`](skills/alishan/references/design-tokens.md) | Finding a project's colour, text, spacing and radius tokens; no raw hex, `TextStyle()` or magic numbers; a grep to review your diff |
| [`ui-components.md`](skills/alishan/references/ui-components.md) | Reuse-before-build, narrow-column/web layout, copy, state, null safety, interaction details |
| [`figma-to-flutter.md`](skills/alishan/references/figma-to-flutter.md) | Turning Figma (or Figma MCP output) into token-bound Flutter: auto-layout mapping, line-height and letter-spacing maths, common export pitfalls |
| [`ui-testing.md`](skills/alishan/references/ui-testing.md) | Widget tests with the real theme, loading real fonts so overflows are real, multi-size and text-scale checks, `kIsWeb` and goldens |
| [`functional-programming.md`](skills/alishan/references/functional-programming.md) | Immutable models, pure business functions, sealed states with exhaustive `switch`, `Result` errors, composition, side effects at the edges |
| [`architecture.md`](skills/alishan/references/architecture.md) | Presentation/domain/data layers, feature-first folders, unidirectional data flow, repositories, DI, testing each layer, review checklist |
| [`state-management.md`](skills/alishan/references/state-management.md) | bloc/cubit, Riverpod and provider done well: where state lives, narrow rebuilds, listeners for effects, anti-patterns |
| [`performance.md`](skills/alishan/references/performance.md) | Profiling, rebuild scope, lazy lists and slivers, image decode size, isolates, startup, leaks |
| [`accessibility-theming.md`](skills/alishan/references/accessibility-theming.md) | Semantics, 48 dp targets, 2× text, contrast, reduced motion, a11y guideline tests, `ThemeExtension` dark mode, RTL |
| [`forms.md`](skills/alishan/references/forms.md) | Pure composable validators, when to show errors, keyboard/focus/autofill, double-submit-proof submit, server field errors |
| [`examples/profile_feature`](skills/alishan/examples/profile_feature) | A complete, tested feature (domain/data/presentation + 18 tests) showing every guide in practice |
| [`tokens_template.dart`](skills/alishan/references/tokens_template.dart) | A starter token file for projects that don't have one |

The guides aren't tied to any project. The skill reads your project's own tokens, widgets,
state management and copy setup first, and follows them.

## Install

Personal (all projects):

```bash
git clone https://github.com/MAlishanNawaz/flutter-skills.git
cp -R flutter-skills/skills/alishan ~/.claude/skills/
```

Single project:

```bash
cp -R flutter-skills/skills/alishan your-app/.claude/skills/
```

Then in Claude Code run `/alishan`, or just ask for Flutter UI work. The skill loads
on its own when it's relevant.

## License

MIT
