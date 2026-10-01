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

The skill is evaluated with [`evals/evals.json`](skills/alishan/evals/evals.json): 8 realistic tasks, each with objective checks, scored by a blind grader. The latest rounds used the three tasks that separated versions the most (Figma to widget, list jank, cold-start deep link):

| Configuration | Checks passed |
|---|---|
| Current version, Opus | 28/28 (100%), ranked first on every task |
| Current version, Sonnet | 34/35 (97%), up from 83% before the verify gate and deep-link workflow |
| Current version, Haiku | 21/35 (60%), unchanged |
| Previous (longer) version, Opus | 26/28 (93%) |

**Use it with Sonnet or Opus.** Haiku follows parts of the workflow, such as the deep-link auth states, but still skips tests and invents one-off tokens, so review its output closely.

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
