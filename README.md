# Flutter Skills

[Claude Code](https://claude.com/claude-code) skills for building Flutter apps the way I do:
layered feature-first architecture, functional Dart, and UI that is token-driven, reuse-first,
responsive, and tested with real fonts.

## Skills

### `/alishan`: Flutter playbook

One entry point. It reads your project's own conventions first, then loads only the guide for the task.

**Build the UI**
- [`design-tokens.md`](skills/alishan/references/design-tokens.md): no raw hex, `TextStyle()` or magic numbers; finding and creating tokens
- [`ui-components.md`](skills/alishan/references/ui-components.md): reuse before you build, narrow-column/web layout, copy, interaction details
- [`figma-to-flutter.md`](skills/alishan/references/figma-to-flutter.md): Figma / Figma MCP output → token-bound Flutter
- [`forms.md`](skills/alishan/references/forms.md): composable validators, when to show errors, keyboard/autofill, double-submit-proof
- [`accessibility-theming.md`](skills/alishan/references/accessibility-theming.md): semantics, 48 dp targets, 2× text, contrast, `ThemeExtension` dark mode, RTL
- [`animation-motion.md`](skills/alishan/references/animation-motion.md): implicit → explicit, motion tokens, Hero, transitions, reduced motion

**Structure the app**
- [`architecture.md`](skills/alishan/references/architecture.md): presentation/domain/data, feature-first folders, repositories, DI
- [`functional-programming.md`](skills/alishan/references/functional-programming.md): immutability, pure functions, sealed states, `Result` errors
- [`state-management.md`](skills/alishan/references/state-management.md): bloc/cubit, Riverpod, provider done well
- [`networking-offline.md`](skills/alishan/references/networking-offline.md): dio client, single-flight auth refresh, retries, caching, offline outbox, pagination
- [`navigation-deeplinks.md`](skills/alishan/references/navigation-deeplinks.md): go_router, auth redirects, tab shells, App Links / Universal Links, web URLs
- [`platform-integration.md`](skills/alishan/references/platform-integration.md): `kIsWeb`, plugins, Pigeon/channels, permissions, push, lifecycle

**Quality & shipping**
- [`ui-testing.md`](skills/alishan/references/ui-testing.md): widget tests with the real theme and fonts, sizes, text scale
- [`testing-strategy.md`](skills/alishan/references/testing-strategy.md): test pyramid, fakes, bloc tests, integration/Patrol E2E, coverage
- [`performance.md`](skills/alishan/references/performance.md): profiling, rebuild scope, lazy lists, image decoding, isolates, startup
- [`flavors-ci-release.md`](skills/alishan/references/flavors-ci-release.md): fvm, flavors, `--dart-define`, CI, Play/App Store releases
- [`security-observability.md`](skills/alishan/references/security-observability.md): secrets, secure storage, hardening, privacy, crashes, logs, analytics

**Starters**
- [`examples/profile_feature`](skills/alishan/examples/profile_feature): a complete feature (domain/data/presentation + 18 tests), passes analyze and test on Flutter 3.24 and 3.41
- [`tokens_template.dart`](skills/alishan/references/tokens_template.dart): starter design-token file
- [`analysis_options.yaml`](skills/alishan/references/analysis_options.yaml): strict lint set that enforces many of the rules
- [`evals/evals.json`](skills/alishan/evals/evals.json): test prompts for checking the skill with `skill-creator`

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
