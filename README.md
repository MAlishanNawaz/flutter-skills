# Flutter Skills

[Claude Code](https://claude.com/claude-code) skills for building Flutter apps the way I do:
layered feature-first architecture, functional Dart, and UI that is token-driven, reuse-first,
responsive, and tested with real fonts.

## Skills

### `/alishan`: Flutter playbook

A short SKILL.md with four opinions (tokens, layers, scope, no secrets), and four supporting parts that load only when needed:

| Part | What it holds |
|---|---|
| [`examples/profile_feature/`](skills/alishan/examples/profile_feature) | **The main reference: runnable code, not prose.** Feature in presentation/domain/data, `Result`/`AppError`, sealed state, cubit, double-submit form, cold-start auth redirect, fakes, widget-test harness. 29 tests. |
| [`examples/deeplink_config/`](skills/alishan/examples/deeplink_config) | Android manifest snippet, `Runner.entitlements`, `assetlinks.json`, AASA, test commands |
| [`gotchas/`](skills/alishan/gotchas) | Four files of non-obvious Flutter traps only: `ui`, `data`, `platform`, `testing` |
| [`scripts/`](skills/alishan/scripts) | `find_tokens.sh`, `check_tokens.sh` (raw values in changed files), `format_changed.sh` (changed files only, detects line length) |
| [`templates/`](skills/alishan/templates) | Token file and lint set for projects without them |
| [`evals/`](skills/alishan/evals) | 8 tasks with checks, plus the fixture app they run against |

Written to Anthropic's [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) and the [context-engineering rules for Claude 5 models](https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/): code references over specs, gotchas over generic advice, each instruction stated once, absolute language only where it's critical.

## Tested

The skill is evaluated with [`evals/evals.json`](skills/alishan/evals/evals.json): 8 tasks with objective checks, run against [`evals/fixture/`](skills/alishan/evals/fixture) and scored by a blind grader that reads each run's git diff. The latest round compared this from-scratch version with the previous one on the three tasks that separated versions most (Figma to widget, list jank, cold-start deep link):

| Configuration | Checks passed | Rank (of 4, per task) |
|---|---|---|
| This version, Opus | 35/35 (100%) | 1 · 1 · 1 |
| Previous version, Opus | 34/35 (97%) | 2 · 2 · 2 |
| This version, Sonnet | 32/35 (91%) | 3 · 4 · 3 |
| Previous version, Sonnet | 33/35 (94%) | 4 · 3 · 4 |

This version uses about 80% less always-loaded guidance at the same or lower token cost per task. Sonnet's misses (a whole-project `dart format`, and a `go_router` version that silently raises the SDK minimum) are now covered in SKILL.md. The skill targets Sonnet and Opus.

## Install

Personal (all projects):

```bash
git clone https://github.com/MAlishanNawaz/flutter-skills.git
cp -R flutter-skills/skills/alishan ~/.claude/skills/   # evals/ is optional
```

Single project:

```bash
cp -R flutter-skills/skills/alishan your-app/.claude/skills/
```

Then in Claude Code run `/alishan`, or just ask for Flutter UI work. The skill loads
on its own when it's relevant.

## License

MIT
