# Claude Setup Wizard

> **Interactive wizard that configures the complete Claude Code environment for any project.**

An installable Claude Code plugin that detects your stack, asks guided questions,
and generates a production-grade configuration: `CLAUDE.md`, skills, safety hooks,
a token-aware status line, scoped rules, MCP config, and output styles.

**Neutral by design.** No opinionated defaults — the wizard asks, you decide.

---

## Install

```bash
# Inside Claude Code
/plugin marketplace add fschifone/claude-setup-wizard
/plugin install setup-wizard@claude-setup-wizard
```

Restart Claude Code after installing.

---

## Usage

```
/setup-wizard              # interactive — asks mode + depth
/setup-wizard --existing   # analyze repo, fill gaps
/setup-wizard --new        # scaffold from scratch
/setup-wizard --quick      # ~8 questions, ~2 minutes
/setup-wizard --full       # up to 30 questions, everything
/setup-wizard --audit      # read-only gap report, no writes
/audit                     # standalone audit skill
```

---

## Choose your depth

Not every project needs 30 questions. Pick a depth level:

| Depth | Questions | Time | What you get |
|-------|-----------|------|-------------|
| **Quick** | ~8 | ~2 min | `CLAUDE.md` + `settings.json` + safety hook + minimal status line. Good enough to start. |
| **Standard** | ~15 | ~4 min | Adds safety rules, secrets config, automation hooks, rich status line. Right for most projects. |
| **Full** | up to 30 | ~8 min | Adds architecture docs, MCP integrations, custom skills, scoped rules, output styles. For large teams. |

You can always re-run the wizard later at a deeper level — it detects existing
config and only fills gaps.

### What happens when you skip a question?

Skipped questions are **omitted entirely** from generated files. No `<TBD>`
placeholders, no empty sections. A concise `CLAUDE.md` with 5 solid sections
beats a full one with 12 half-empty sections — and saves tokens on every turn.

---

## How it works

1. **Mode selection** — new project, existing project, or audit-only
2. **Repo detection** — scans for package.json, pyproject.toml, Cargo.toml, go.mod, Makefile, lock files, linter configs, and existing Claude config. Skips what it can infer.
3. **Depth selection** — Quick / Standard / Full (or `--quick` / `--full` flags)
4. **Questions** — asked one at a time, numbered, with smart defaults for skipped questions
5. **File plan** — shows every file it will create, waits for explicit "yes"
6. **File generation** — writes all files; never overwrites (offers merge / backup / skip)
7. **Post-setup** — tells you how to activate and suggests re-running at deeper level

---

## The questions

### Quick depth (~8 questions)

These produce a functional `CLAUDE.md` + `settings.json` + safety hook + status line.

| # | Question | Generates |
|---|----------|-----------|
| 1 | Project name and one-sentence purpose | `CLAUDE.md` header |
| 2 | Stage: prototype / staging / production / mixed | `CLAUDE.md` metadata |
| 3 | Languages & frameworks (confirm detected) | `CLAUDE.md` Stack |
| 4 | Test command | `settings.json` allow, `CLAUDE.md` Commands |
| 5 | Lint / format command | `settings.json` allow, auto-format hook |
| 6 | Build command | `settings.json` allow, `CLAUDE.md` Commands |
| 7 | Things Claude must NEVER do | `CLAUDE.md` Rules, `settings.json` deny |
| 8 | Enable safety hook? (recommended: yes) | `block-dangerous-bash.sh` |

**Smart defaults at Quick depth:** team size inferred from git log, chat language = English, package manager detected from lock files, status line = Minimal (auto-enabled), commit style detected from git history, secrets = `.env` assumed with standard .gitignore protections.

### Standard depth adds (~7 more questions)

| # | Question | Generates |
|---|----------|-----------|
| 9 | Team size: solo / small / large | `.gitignore` strategy |
| 10 | Dev / run command | `CLAUDE.md` Commands |
| 11 | Deploy command | `settings.json` ask (requires confirmation) |
| 12 | Database / migration commands | `CLAUDE.md` Commands |
| 13 | Things Claude must ALWAYS do | `CLAUDE.md` Rules |
| 14 | Known pitfalls | `CLAUDE.md` Pitfalls |
| 15 | How are secrets managed? | `CLAUDE.md` Secrets section |
| 16 | Additional hooks: auto-format, run tests on stop, log bash | `.claude/hooks/*.sh` |
| 17 | Status line: Rich / Minimal / None | `.claude/statusline.sh` |

### Full depth adds (~13 more questions)

| # | Question | Generates |
|---|----------|-----------|
| 18 | Primary chat language | `CLAUDE.md` metadata |
| 19 | Main modules / directories | `CLAUDE.md` Architecture |
| 20 | Architectural patterns | `CLAUDE.md` Architecture |
| 21 | Sub-areas for nested CLAUDE.md | `<area>/CLAUDE.md` files |
| 22 | Env files Claude can read vs. never touch | `CLAUDE.md` Secrets |
| 23 | External APIs | `CLAUDE.md` External context |
| 24 | MCP servers | `.mcp.json` stubs |
| 25 | Workflows → skills | `.claude/skills/*/SKILL.md` |
| 26 | Specialized skills | `.claude/skills/*/SKILL.md` |
| 27 | Output style: Default / Concise / Explanatory / Custom | `.claude/output-styles/*.md` |
| 28 | Commit message style | `CLAUDE.md` Style |
| 29 | Documentation style | `CLAUDE.md` Style |
| 30 | Scoped rules for specific directories | `.claude/rules/*.md` |

---

## What it produces

| File | When | Purpose |
|------|------|---------|
| `CLAUDE.md` | Always | Root project context — loaded every session |
| `CLAUDE.local.md` | Always | Personal notes, gitignored |
| `<area>/CLAUDE.md` | Full: Q21 | Nested context for sub-modules |
| `.claude/settings.json` | Always | Permissions (allow/deny/ask), hooks, status line |
| `.claude/skills/*/SKILL.md` | Full: Q25–Q26 | Custom skills for workflows and specialized tasks |
| `.claude/rules/*.md` | Full: Q30 | Scoped rules — load only for matching directories |
| `.claude/hooks/block-dangerous-bash.sh` | Quick: Q8 | Blocks `rm -rf /`, fork bombs, `curl\|bash`, force push, `DROP DATABASE` |
| `.claude/hooks/auto-format.sh` | Standard: Q16 | Runs linter after Write/Edit (Python, JS/TS, Go, Rust, Swift, Shell) |
| `.claude/hooks/run-tests-on-stop.sh` | Standard: Q16 | Runs test command when Claude finishes |
| `.claude/hooks/log-bash.sh` | Standard: Q16 | Audit log of every bash command |
| `.claude/statusline.sh` | Quick+ | Token-aware status bar (Minimal auto-enabled at Quick) |
| `.claude/output-styles/*.md` | Full: Q27=Custom | Custom response style |
| `.mcp.json` | Full: Q24 | MCP server config (stubs with env var placeholders) |
| `.gitignore` | Always (appends) | Protects `CLAUDE.local.md`, `.env`, `.claude/logs/` |

---

## Example: Quick setup (~2 min)

```
You: /setup-wizard --existing --quick

Claude: Detected:
  - Stack: Python 3.12 + FastAPI
  - Test: pytest
  - Linter: ruff
  - Git: main, solo developer

  Question 1/8: Project name and purpose?
You: ordergate — validates orders before routing to fulfillment
Claude: Question 2/8: Stage?
You: production
Claude: Question 3/8: Detected Python 3.12 + FastAPI — correct?
You: yes
Claude: Question 4/8: Test command — detected `pytest`. Correct?
You: yes
Claude: Question 5/8: Lint command — detected `ruff check`. Correct?
You: ruff check --fix
Claude: Question 6/8: Build command?
You: skip
Claude: Question 7/8: Things Claude must NEVER do?
You: never modify alembic migration files, never drop tables
Claude: Question 8/8: Enable safety hook to block dangerous commands? (recommended)
You: yes

Claude: FILE PLAN
  CLAUDE.md                             — root context (Stack, Commands, Rules)
  CLAUDE.local.md                       — personal notes
  .claude/settings.json                 — permissions + safety hook + status line
  .claude/hooks/block-dangerous-bash.sh — blocks dangerous patterns
  .claude/statusline.sh                 — minimal (model + context %)
  .gitignore                            — protections added

  Proceed? [yes / edit / cancel]
You: yes

Claude: ✓ CLAUDE.md — root context (compact: Stack, Commands, Rules only)
        ✓ CLAUDE.local.md — personal notes
        ✓ .claude/settings.json — permissions, hook, status line
        ✓ .claude/hooks/block-dangerous-bash.sh — safety hook
        ✓ .claude/statusline.sh — minimal status line
        ✓ .gitignore — updated

        Setup complete. Restart Claude Code to activate.
        Want more? Re-run /setup-wizard at Standard or Full depth.
```

## Example: Full setup (~8 min)

```
You: /setup-wizard --existing --full

Claude: Detected:
  - Stack: Python 3.12 + FastAPI + PostgreSQL
  - Test: pytest · Linter: ruff · Build: none
  - Existing Claude config: none
  - Git: main (3 commits, 2 authors)

  Question 1/30: Project name and purpose?

... (30 questions, one at a time, skipping what was detected) ...

Claude: FILE PLAN
  CLAUDE.md, CLAUDE.local.md, backend/CLAUDE.md
  .claude/settings.json, .gitignore
  .claude/rules/backend.md
  .claude/skills/deploy/SKILL.md
  .claude/skills/new-migration/SKILL.md
  .claude/skills/test-writer/SKILL.md
  .claude/hooks/block-dangerous-bash.sh, auto-format.sh
  .mcp.json (postgres + github)
  .claude/statusline.sh (rich)

  Proceed? [yes / edit / cancel]
```

---

## The status line

If enabled, the **rich** status line shows:

```
Sonnet 4.6  [▓▓▓▓▓░░░░░] 47% (94k)  ordergate/backend  ⎇ feature/audit-log*  $0.23
└── model   └── context  └── tokens  └── cwd            └── git (dirty)      └── cost
```

- Context bar: **green** < 50%, **yellow** < 75%, **red** >= 75%
- Token count humanized (94k, 1.2M)
- Git branch with `*` dirty marker
- Session cost in USD
- **Minimal** variant: `Sonnet 4.6  47%`

Falls back gracefully without `jq`.

---

## The safety hooks

| Hook | Event | Behavior |
|------|-------|----------|
| `block-dangerous-bash.sh` | PreToolUse | **Blocks** (exit 2) — `rm -rf /`, fork bombs, `mkfs`, `dd` to disks, `chmod -R 777 /`, `curl\|bash`, force-push to main/master/prod, `DROP DATABASE`, `TRUNCATE TABLE` |
| `auto-format.sh` | PostToolUse | **Non-blocking** — ruff/black, prettier, gofmt, rustfmt, swiftformat, shfmt |
| `run-tests-on-stop.sh` | Stop | **Non-blocking** — `$CLAUDE_TEST_CMD` or auto-detects pytest/npm test/cargo test/go test |
| `log-bash.sh` | PreToolUse | **Non-blocking** — `[timestamp] session=id cwd=dir cmd=command` → `.claude/logs/bash.log` |

All hooks: `set -o pipefail`, `jq` fallbacks, plain readable bash.

---

## Why Claude needs this

| What | Without it |
|------|-----------|
| **Context** (`CLAUDE.md`) | Claude doesn't know your project, guesses commands wrong |
| **Safety** (hooks + deny list) | `rm -rf /` and force-push are one hallucination away |
| **Token awareness** (status line) | You can't tell the context window is full until it's too late |
| **Skills** | Repetitive workflows typed from scratch every time |
| **Scoped rules** | All rules load every turn even when irrelevant — wasting tokens |
| **MCP** | No access to databases, APIs, or tools Claude could use |

---

## Philosophy

1. **Neutral.** No defaults about stack, style, or tooling. The wizard asks.
2. **Additive.** Existing files never overwritten — merge, backup, or skip.
3. **Conservative.** Skipped questions are omitted, never invented.
4. **Transparent.** Every generated file is plain text you can edit.
5. **Anthropic-aligned.** Official plugin format, standard hooks, documented APIs.
6. **Token-conscious.** Concise CLAUDE.md, scoped rules, visible context usage.

---

## Development

```
claude-setup-wizard/
├── .claude-plugin/
│   └── marketplace.json             ← marketplace manifest
├── plugins/setup-wizard/
│   ├── .claude-plugin/plugin.json   ← plugin manifest
│   ├── skills/                      ← setup-wizard, audit (SKILL.md format)
│   ├── commands/                    ← legacy commands (backward compat)
│   ├── hooks/                       ← 4 shell scripts
│   ├── statusline/                  ← rich.sh, minimal.sh
│   └── templates/                   ← 9 generated-file templates
├── examples/sample-output/          ← complete example for a fictional project
├── scripts/validate.sh              ← local CI mirror
└── .github/workflows/validate.yml   ← CI: validates JSON + bash syntax
```

### Validate locally

```bash
./scripts/validate.sh
```

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Quick rules: `set -o pipefail` + `jq` fallback in all hooks, `{{PLACEHOLDER}}` syntax in all templates, no network calls.

### License

MIT — see [LICENSE](LICENSE).

---

## Links

- [Claude Code plugin spec](https://code.claude.com/docs/en/plugin-marketplaces)
- [Skills reference](https://code.claude.com/docs/en/skills)
- [Hook events](https://code.claude.com/docs/en/hooks)
- [Status line spec](https://code.claude.com/docs/en/statusline)
