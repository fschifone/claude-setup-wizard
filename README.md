<p align="center">
  <h1 align="center">Claude Setup Wizard</h1>
  <p align="center">
    <strong>Configure the complete Claude Code environment for any project — from zero questions to thirty.</strong>
  </p>
  <p align="center">
    <a href="#install">Install</a> · <a href="#three-ways-to-use-it">Usage</a> · <a href="#the-questions">Questions</a> · <a href="#token-cost-vs-benefit">Token Cost</a> · <a href="#examples">Examples</a>
  </p>
  <p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
    <a href="https://github.com/fschifone/claude-setup-wizard/actions"><img src="https://github.com/fschifone/claude-setup-wizard/actions/workflows/validate.yml/badge.svg" alt="CI"></a>
    <img src="https://img.shields.io/badge/version-1.2.0-green.svg" alt="Version 1.2.0">
  </p>
</p>

---

A Claude Code plugin that detects your stack, asks guided questions (or none at
all), and generates a production-grade configuration: `CLAUDE.md`, skills, safety
hooks, a token-aware status line, scoped rules, MCP config, and output styles.

**Neutral by design** — no opinionated defaults. The wizard asks, you decide.
Skip any question — skipped sections are omitted entirely, not filled with placeholders.

---

## Install

```bash
/plugin marketplace add fschifone/claude-setup-wizard
/plugin install setup-wizard@claude-setup-wizard
```

Restart Claude Code after installing to activate skills.

---

## Three ways to use it

### `/setup-wizard` — Interactive setup

```bash
/setup-wizard                  # asks mode + depth
/setup-wizard --quick          # ~8 questions, ~2 min
/setup-wizard --existing       # ~15 questions, ~4 min (default)
/setup-wizard --full           # up to 30 questions, ~8 min
/setup-wizard --new            # scaffold from scratch (no detection)
```

Choose a depth level:

| Depth | Questions | Time | What you get |
|:------|:---------:|:----:|:-------------|
| **Quick** | ~8 | ~2 min | `CLAUDE.md` + `settings.json` + safety hook + status line |
| **Standard** | ~15 | ~4 min | + safety rules, secrets, automation hooks, rich status line |
| **Full** | up to 30 | ~8 min | + architecture, MCP, custom skills, scoped rules, output styles |

Re-run at a deeper level anytime — the wizard detects existing config and fills gaps.

### `/setup-wizard --auto` — Zero questions

Reads your codebase deeply — README, dependencies, source files, git history,
linter configs, directory structure — then cross-references against built-in
[detection catalogs](#smart-detection) and generates the entire configuration.
You just confirm or edit the result.

```bash
/setup-wizard --auto
```

### `/fix` — Diagnose & repair existing config

For projects that already have Claude config but Claude isn't performing well.

```bash
/fix
```

1. Deep-scans your codebase **and** existing Claude config
2. Diagnoses mismatches (wrong commands, stale references, missing rules, broken hooks, token waste)
3. Reports: **CRITICAL** / **PROBLEMS** / **SUGGESTIONS** with a score
4. Applies targeted edits with your approval — never rewrites from scratch

### `/audit` — Read-only gap report

```bash
/setup-wizard --audit
/audit
```

Scans everything, scores your config 0–10, suggests next steps. Writes nothing.

### `/setup-wizard agents` — Specialized agent team

After the environment is set up, add a team of role-specialized subagents
tuned to your detected stack. Runs standalone — doesn't re-ask the full
questionnaire.

```bash
/setup-wizard agents
```

Offers (stack-gated where it makes sense):

- `frontend-specialist` — UI, components, client state (shown for React/Vue/Svelte/Next/Angular/SolidJS/SwiftUI)
- `backend-specialist` — endpoints, server logic, integrations (shown for Express/Fastify/Nest/FastAPI/Django/Rails/Go/Spring/Phoenix)
- `code-reviewer-critical` — strict read-only reviewer; opus by default
- `tester` — writes and fixes tests; wired to your detected test command
- `debugger` — root-causes errors before attempting a fix
- `db-migrations` — forward-only schema changes (shown for Prisma/Drizzle/Alembic/SQLAlchemy/ActiveRecord/Ecto)
- `security-auditor` — read-only security findings; opus by default

Each generated agent lives at `.claude/agents/<role>.md` with the official
frontmatter (`name`, `description`, `tools`, `model`). Tool restrictions are
applied per role — read-only reviewers can't `Edit` or `Write`. Claude Code
auto-delegates to them based on the `description` field, so descriptions
include explicit trigger phrases ("Use PROACTIVELY when…", "MUST BE USED for…").

Re-runnable at any time to add or regenerate agents.

---

## The questions

### Quick depth (~8 questions)

Produces `CLAUDE.md` + `settings.json` + safety hook + minimal status line.

| # | Question | Generates |
|:-:|----------|-----------|
| 1 | Project name and one-sentence purpose | `CLAUDE.md` header |
| 2 | Stage: prototype / staging / production / mixed | `CLAUDE.md` metadata |
| 3 | Languages & frameworks (confirm detected) | `CLAUDE.md` Stack |
| 4 | Test command | `settings.json` allow, `CLAUDE.md` Commands |
| 5 | Lint / format command | `settings.json` allow, auto-format hook |
| 6 | Build command | `settings.json` allow, `CLAUDE.md` Commands |
| 7 | Things Claude must NEVER do | `CLAUDE.md` Rules, `settings.json` deny |
| 8 | Enable safety hook? (recommended: yes) | `block-dangerous-bash.sh` |

> **Smart defaults at Quick depth:** team size from git log, English chat language,
> package manager from lock files, status line = Minimal (auto-enabled), commit
> style from git history, secrets = `.env` with standard .gitignore protections.

### Standard depth adds ~7 more

| # | Question | Generates |
|:-:|----------|-----------|
| 9 | Team size: solo / small / large | `.gitignore` strategy |
| 10 | Dev / run command | `CLAUDE.md` Commands |
| 11 | Deploy command | `settings.json` ask (requires confirmation) |
| 12 | Database / migration commands | `CLAUDE.md` Commands |
| 13 | Things Claude must ALWAYS do | `CLAUDE.md` Rules |
| 14 | Known pitfalls | `CLAUDE.md` Pitfalls |
| 15 | How are secrets managed? | `CLAUDE.md` Secrets section |
| 16 | Additional hooks (multi-select) | `.claude/hooks/*.sh` |
| 17 | Status line: Rich / Minimal / None | `.claude/statusline.sh` |

### Full depth adds ~13 more

| # | Question | Generates |
|:-:|----------|-----------|
| 18 | Primary chat language | `CLAUDE.md` metadata |
| 19 | Main modules / directories | `CLAUDE.md` Architecture |
| 20 | Architectural patterns | `CLAUDE.md` Architecture |
| 21 | Sub-areas for nested CLAUDE.md | `<area>/CLAUDE.md` files |
| 22 | Env files: readable vs. forbidden | `CLAUDE.md` Secrets |
| 23 | External APIs | `CLAUDE.md` External context |
| 24 | MCP servers | `.mcp.json` stubs |
| 25 | Workflows to automate | `.claude/skills/*/SKILL.md` |
| 26 | Specialized skills | `.claude/skills/*/SKILL.md` |
| 27 | Output style | `.claude/output-styles/*.md` |
| 28 | Commit message style | `CLAUDE.md` Style |
| 29 | Documentation style | `CLAUDE.md` Style |
| 30 | Directory-scoped rules | `.claude/rules/*.md` |

---

## What it produces

| File | Depth | Purpose |
|:-----|:-----:|:--------|
| `CLAUDE.md` | All | Root project context — loaded every session |
| `CLAUDE.local.md` | All | Personal notes, gitignored |
| `.claude/settings.json` | All | Permissions, hooks, status line wiring |
| `.claude/statusline.sh` | All | Token-aware status bar (Minimal auto-enabled) |
| `.claude/hooks/block-dangerous-bash.sh` | Quick+ | Blocks `rm -rf /`, fork bombs, force push, `DROP DATABASE`... |
| `.gitignore` | All | Protects `CLAUDE.local.md`, `.env`, `.claude/logs/` |
| `<area>/CLAUDE.md` | Full | Nested context for sub-modules |
| `.claude/hooks/auto-format.sh` | Standard+ | Auto-formats on Write/Edit (7 languages) |
| `.claude/hooks/run-tests-on-stop.sh` | Standard+ | Runs tests when Claude finishes |
| `.claude/hooks/log-bash.sh` | Standard+ | Audit log of every bash command |
| `.claude/skills/*/SKILL.md` | Full | Custom skills for workflows and specialized tasks |
| `.claude/rules/*.md` | Full | Scoped rules — load only for matching directories |
| `.claude/output-styles/*.md` | Full | Custom response styles |
| `.mcp.json` | Full | MCP server config with env var placeholders |

---

## Smart detection

Both `--auto` and `/fix` use built-in detection catalogs that map project signals
to configurations:

| Catalog | Detects | Generates |
|:--------|:--------|:----------|
| [mcp-servers.md](plugins/setup-wizard/skills/setup-wizard/references/mcp-servers.md) | `@supabase/supabase-js`, `pg`, `@aws-sdk/*`, Playwright, GitHub remote... | `.mcp.json` entries with `${ENV_VAR}` placeholders |
| [hooks-patterns.md](plugins/setup-wizard/skills/setup-wizard/references/hooks-patterns.md) | `.prettierrc`, `[tool.ruff]`, `tsconfig.json`, test runners... | `settings.json` hook configs + script selection |
| [skills-catalog.md](plugins/setup-wizard/skills/setup-wizard/references/skills-catalog.md) | `fly.toml`, `alembic/`, `prisma/`, low test coverage... | `.claude/skills/*/SKILL.md` for deploy, migrate, test-write |

---

## Examples

### Quick setup (~2 min, 8 questions)

```
You: /setup-wizard --existing --quick

Claude: Detected:
  Stack: Python 3.12 + FastAPI · Test: pytest · Lint: ruff · Git: main (solo)

  Question 1/8: Project name and purpose?
You: ordergate — validates orders before routing to fulfillment
Claude: Question 2/8: Stage?
You: production
  ...
Claude: Question 8/8: Enable safety hook? (recommended)
You: yes

Claude: FILE PLAN
  CLAUDE.md, CLAUDE.local.md, .claude/settings.json
  .claude/hooks/block-dangerous-bash.sh
  .claude/statusline.sh (minimal), .gitignore

  Proceed? [yes / edit / cancel]
You: yes

Claude: ✓ 6 files written. Setup complete — restart Claude Code to activate.
```

### Auto mode (0 questions)

```
You: /setup-wizard --auto

Claude: [reading README.md, package.json, src/, git log, .prettierrc...]

  AUTO-DETECTED CONFIGURATION

  Project: ordergate — validates orders before routing to fulfillment
  Stack: Python 3.12 + FastAPI + PostgreSQL + Alembic
  Stage: production · Team: 3 developers · Commit style: conventional

  Commands: pytest, ruff check --fix, uvicorn, alembic upgrade head
  Rules: NEVER modify migrations, drop tables, edit .env

  FILE PLAN:
    CLAUDE.md, CLAUDE.local.md, .claude/settings.json
    .claude/hooks/block-dangerous-bash.sh
    .claude/statusline.sh (minimal), .gitignore

  Everything look right? [yes / edit / cancel]
You: yes

Claude: ✓ 6 files written. Setup complete — restart Claude Code to activate.
```

### Fix mode (existing config)

```
You: /fix

Claude: CLAUDE CONFIG DIAGNOSIS — ordergate       Score: 4/10

  CRITICAL:
    ! CLAUDE.md says "npm test" but pyproject.toml uses pytest
    ! settings.json hooks reference .claude/hooks/format.sh — doesn't exist

  PROBLEMS:
    ~ CLAUDE.md is 230 lines — move backend rules to .claude/rules/backend.md
    ~ No deny list — rm -rf and force push not blocked

  SUGGESTIONS:
    + Add status line for token awareness
    + Create /deploy skill — detected fly deploy in Makefile

  Fix all? [fix all / one-by-one / cancel]
You: fix all

Claude: ✓ 5 fixes applied. Score: 4/10 → 8/10
```

---

## The status line

Always included (Minimal at Quick depth, configurable at Standard+).

**Rich:**
```
Sonnet 4.6  [▓▓▓▓▓░░░░░] 47% (94k)  ordergate/backend  ⎇ feature/audit-log*  $0.23
```

**Minimal:**
```
Sonnet 4.6  47%
```

Context bar: green < 50%, yellow < 75%, red >= 75%. Falls back gracefully without `jq`.

---

## The safety hooks

| Hook | Event | Behavior |
|:-----|:------|:---------|
| **block-dangerous-bash** | PreToolUse | **Blocks** (exit 2) — `rm -rf /`, fork bombs, `mkfs`, `dd` to disks, `chmod -R 777 /`, `curl\|bash`, force-push to main/master/prod, `DROP DATABASE`, `TRUNCATE TABLE` |
| **auto-format** | PostToolUse | **Non-blocking** — ruff/black, prettier, gofmt, rustfmt, swiftformat, shfmt |
| **run-tests-on-stop** | Stop | **Non-blocking** — `$CLAUDE_TEST_CMD` or auto-detects pytest/npm test/cargo test/go test |
| **log-bash** | PreToolUse | **Non-blocking** — `[timestamp] session=id cwd=dir cmd=command` → `.claude/logs/bash.log` |

All hooks: `set -o pipefail`, `jq` fallbacks, plain readable bash.

---

## Token cost vs. benefit

### One-time cost (running the wizard)

| Mode | Prompt size | Session tokens | Time |
|:-----|:------------|:---------------|:-----|
| `--auto` | ~4,300 | ~8k–15k | ~1 min |
| `--quick` | ~4,300 | ~10k–20k | ~2 min |
| `--existing` | ~4,300 | ~15k–30k | ~4 min |
| `--full` | ~4,300 | ~25k–50k | ~8 min |
| `/fix` | ~2,200 | ~10k–25k | ~2 min |
| `/audit` | ~670 | ~3k–5k | ~30 sec |

For context: a typical coding session uses 50k–200k tokens. Running the wizard
is equivalent to 2–5 normal exchanges.

### Ongoing cost (every turn)

| Depth | CLAUDE.md size | Per-turn cost | % of 200k context |
|:------|:---------------|:--------------|:-------------------|
| Quick | ~40–60 lines | ~500–700 tokens | 0.3% |
| Standard | ~60–100 lines | ~700–1,000 tokens | 0.5% |
| Full | ~80–120 lines | ~900–1,200 tokens | 0.6% |

`settings.json`, hooks, and status line cost **zero tokens** — they're executed
by Claude Code's runtime, not loaded into context.

### What that buys you

| Benefit | Saves | Without it |
|:--------|:------|:-----------|
| Correct commands first try | ~2k–10k tokens/task | Claude guesses wrong, wastes round-trips |
| Safety deny list | Your project | One hallucination from `rm -rf /` |
| NEVER rules | ~1k–5k tokens | Claude attempts forbidden actions, gets rejected, retries |
| Status line | Entire sessions | Context fills silently, responses degrade |
| Scoped rules | ~200–800 tokens/turn | Irrelevant rules load every turn |
| Hooks | Zero token cost | Without auto-format, you waste turns formatting |

> **The wizard pays for itself within the first 5–10 exchanges.**
> After that, every turn is more efficient than without configuration.

---

## Philosophy

| Principle | Meaning |
|:----------|:--------|
| **Neutral** | No defaults about stack, style, or tooling — the wizard asks |
| **Additive** | Existing files never overwritten — merge, backup, or skip |
| **Conservative** | Skipped questions omitted entirely, never invented |
| **Transparent** | Every generated file is plain text you can edit by hand |
| **Anthropic-aligned** | Official plugin format, standard hooks, documented APIs |
| **Token-conscious** | Concise CLAUDE.md, scoped rules, visible context usage |

---

## Project structure

```
claude-setup-wizard/
├── .claude-plugin/marketplace.json      ← marketplace manifest
├── plugins/setup-wizard/
│   ├── .claude-plugin/plugin.json       ← plugin manifest
│   ├── skills/                          ← setup-wizard, audit, fix
│   │   ├── setup-wizard/
│   │   │   ├── SKILL.md                 ← main wizard (~300 lines)
│   │   │   └── references/              ← detection catalogs
│   │   │       ├── mcp-servers.md       ← dependency → MCP mapping
│   │   │       ├── hooks-patterns.md    ← linter/test → hook mapping
│   │   │       └── skills-catalog.md    ← pattern → skill mapping
│   │   ├── audit/SKILL.md              ← read-only gap report
│   │   └── fix/SKILL.md               ← diagnose & repair
│   ├── templates/hooks/                 ← 4 safety/automation scripts
│   ├── statusline/                      ← rich.sh, minimal.sh
│   └── templates/                       ← 9 file generation templates
├── examples/sample-output/              ← complete example project
├── scripts/validate.sh                  ← local CI mirror
└── .github/workflows/validate.yml       ← CI
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

**Quick rules:** `set -o pipefail` + `jq` fallback in all hooks,
`{{PLACEHOLDER}}` syntax in all templates, no network calls, run
`./scripts/validate.sh` before PR.

---

## License

MIT — see [LICENSE](LICENSE).

---

<p align="center">
  <a href="https://code.claude.com/docs/en/plugin-marketplaces">Plugin spec</a> · <a href="https://code.claude.com/docs/en/skills">Skills</a> · <a href="https://code.claude.com/docs/en/hooks">Hooks</a> · <a href="https://code.claude.com/docs/en/statusline">Status line</a>
</p>
