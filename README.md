# Claude Setup Wizard

> **Interactive wizard that configures the complete Claude Code environment for any project — in under 5 minutes.**

An installable Claude Code plugin that asks 30 guided questions and generates
a coherent, production-grade configuration: `CLAUDE.md` hierarchy, skills,
safety hooks, a token-aware status line, scoped rules, MCP config, and output
styles.

**Neutral by design.** No opinionated defaults are imposed — the wizard asks,
you decide. Say "skip" to any question you're not ready to answer.

---

## Install

```bash
# Inside Claude Code
/plugin marketplace add fschifone/claude-setup-wizard
/plugin install setup-wizard@claude-setup-wizard
```

Then restart Claude Code so skills, hooks, and the status line are picked up.

---

## Usage

```
/setup-wizard              # asks: new project / existing / audit
/setup-wizard --new        # scaffold from scratch
/setup-wizard --existing   # analyze repo, fill gaps
/setup-wizard --audit      # read-only gap report, no writes
/audit                     # standalone audit skill
```

---

## How it works

1. **Mode selection** — new project, existing project (auto-detects your stack), or audit-only
2. **Repo detection** — in existing mode, scans for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc. and skips questions it can infer
3. **30 questions** — asked one at a time; say "skip" or "I don't know" for any
4. **File plan** — shows every file it will create and waits for explicit "yes"
5. **File generation** — writes all files; never overwrites silently (offers merge / backup / skip)
6. **Post-setup** — tells you how to activate and verify

---

## The 30 questions

### A · Identity

| # | Question | Used for |
|---|----------|----------|
| 1 | Project name and one-sentence purpose | `CLAUDE.md` header |
| 2 | Stage: prototype / staging / production / mixed | `CLAUDE.md` metadata |
| 3 | Team size: solo / small (2–5) / large | Decides if `.claude/` is committed or gitignored |
| 4 | Primary chat language: English / Italian / other | Sets Claude's response language |

### B · Stack & conventions

| # | Question | Used for |
|---|----------|----------|
| 5 | Languages & frameworks (if not auto-detected) | `CLAUDE.md` Stack section |
| 6 | Linter / formatter commands + auto-run? | `settings.json` permissions, auto-format hook |
| 7 | Test runner command | `settings.json` permissions, run-tests-on-stop hook |
| 8 | Package manager | `CLAUDE.md` Stack section |

### C · Operational commands

| # | Question | Used for |
|---|----------|----------|
| 9 | Build command | `CLAUDE.md` Commands table, `settings.json` allow |
| 10 | Dev / run command | `CLAUDE.md` Commands table, `settings.json` allow |
| 11 | Deploy command (or "none") | `settings.json` ask (requires confirmation) |
| 12 | Database / migration commands | `CLAUDE.md` Commands table |

### D · Architecture

| # | Question | Used for |
|---|----------|----------|
| 13 | Main modules / directories | `CLAUDE.md` Architecture section |
| 14 | Patterns: MVC / MVVM / hexagonal / event-driven / other | `CLAUDE.md` Architecture section |
| 15 | Sub-areas needing their own nested `CLAUDE.md` | Generates `<area>/CLAUDE.md` files |

### E · Safety rails

| # | Question | Used for |
|---|----------|----------|
| 16 | Things Claude must **NEVER** do | `CLAUDE.md` Rules, `settings.json` deny list |
| 17 | Things Claude must **ALWAYS** do | `CLAUDE.md` Rules section |
| 18 | Known pitfalls — tricky parts where bugs lived | `CLAUDE.md` Pitfalls section |

### F · Secrets & environments

| # | Question | Used for |
|---|----------|----------|
| 19 | How are secrets managed? (.env / vault / cloud) | `CLAUDE.md` Secrets section |
| 20 | Which env files can Claude read vs. never touch? | `CLAUDE.md` readable/forbidden lists |

### G · MCP & integrations

| # | Question | Used for |
|---|----------|----------|
| 21 | MCP servers to configure (postgres, github, etc. or "none") | `.mcp.json` stubs |
| 22 | External APIs Claude should know about | `CLAUDE.md` External context |

### H · Automation

| # | Question | Used for |
|---|----------|----------|
| 23 | Repetitive workflows → slash commands? (e.g. `/deploy`, `/test-all`) | `.claude/skills/*/SKILL.md` |
| 24 | Specialized skills? (e.g. test-writer, security-reviewer) | `.claude/skills/*/SKILL.md` |
| 25 | Hooks (multi-select): block dangerous bash, auto-format, run tests on stop, log bash, none | `.claude/hooks/*.sh` + `settings.json` wiring |

### I · Display & style

| # | Question | Used for |
|---|----------|----------|
| 26 | Status line: Rich / Minimal / None | `.claude/statusline.sh` + `settings.json` |
| 27 | Output style: Default / Concise / Explanatory / Custom | `.claude/output-styles/*.md` |
| 28 | Commit message style: conventional / free-form / other | `CLAUDE.md` Style section |
| 29 | Documentation style for new code: docstrings? format? | `CLAUDE.md` Style section |

### J · Token efficiency

| # | Question | Used for |
|---|----------|----------|
| 30 | Are any rules specific to certain directories? | `.claude/rules/<area>.md` — loads only when relevant files are touched, saving tokens every other turn |

---

## What it produces

| File | Created when | Purpose |
|------|-------------|---------|
| `CLAUDE.md` | Always | Root project context — loaded every session |
| `CLAUDE.local.md` | Always | Personal notes, gitignored |
| `<area>/CLAUDE.md` | Q15 has entries | Nested context for sub-modules |
| `.claude/settings.json` | Always | Permissions (allow/deny/ask), hooks, status line |
| `.claude/skills/*/SKILL.md` | Q23 or Q24 have entries | Custom skills for workflows and specialized tasks |
| `.claude/rules/*.md` | Q30 has entries | Scoped rules — load only for matching directories |
| `.claude/hooks/block-dangerous-bash.sh` | Selected in Q25 | Blocks `rm -rf /`, fork bombs, `curl\|bash`, force push, `DROP DATABASE`, etc. |
| `.claude/hooks/auto-format.sh` | Selected in Q25 | Runs linter after Write/Edit (Python, JS/TS, Go, Rust, Swift, Shell) |
| `.claude/hooks/run-tests-on-stop.sh` | Selected in Q25 | Runs test command when Claude finishes responding |
| `.claude/hooks/log-bash.sh` | Selected in Q25 | Audit log of every bash command to `.claude/logs/bash.log` |
| `.claude/statusline.sh` | Q26 != None | Token-aware status bar |
| `.claude/output-styles/*.md` | Q27 = Custom | Custom response style |
| `.mcp.json` | Q21 != none | MCP server config (stubs with env var placeholders) |
| `.gitignore` | Always (appends) | Protects `CLAUDE.local.md`, `.env`, `.claude/logs/` |

A typical project gets **6–12 files** depending on which features you enable. Everything is plain text and editable by hand.

---

## The status line

If you enable it, the **rich** status line shows:

```
Sonnet 4.6  [▓▓▓▓▓░░░░░] 47% (94k)  ordergate/backend  ⎇ feature/audit-log*  $0.23
└── model   └── context  └── tokens  └── cwd            └── git (dirty)      └── cost
```

- Context bar turns **green** < 50%, **yellow** < 75%, **red** >= 75%
- Token count is humanized (94k, 1.2M)
- Git branch shows a `*` dirty marker when there are uncommitted changes
- Session cost in USD (when available)
- **Minimal** variant shows just: `Sonnet 4.6  47%`

Falls back gracefully if `jq` is not installed.

---

## The safety hooks

| Hook | Event | Behavior |
|------|-------|----------|
| `block-dangerous-bash.sh` | PreToolUse | **Blocks** (exit 2) — catches 13+ patterns: `rm -rf /`, fork bombs, `mkfs`, `dd` to disks, `chmod -R 777 /`, `curl\|bash`, force-push to main/master/prod, `DROP DATABASE`, `TRUNCATE TABLE` |
| `auto-format.sh` | PostToolUse | **Non-blocking** — auto-detects file type and runs: ruff/black (Python), prettier (JS/TS/JSON/CSS/YAML/MD), gofmt (Go), rustfmt (Rust), swiftformat (Swift), shfmt (Shell) |
| `run-tests-on-stop.sh` | Stop | **Non-blocking** — runs `$CLAUDE_TEST_CMD` or auto-detects: pytest, npm test, cargo test, go test |
| `log-bash.sh` | PreToolUse | **Non-blocking** — appends `[timestamp] session=id cwd=dir cmd=command` to `.claude/logs/bash.log` |

All hooks use `set -o pipefail`, include `jq` fallbacks, and are plain readable bash.

---

## Example session

```
You: /setup-wizard --existing

Claude: Detected:
  - Stack: Python 3.12 + FastAPI + PostgreSQL
  - Existing Claude config: none
  - Git: main (3 commits)
  - README: present

  I'll ask only about what I can't infer. Question 1/30:
  What is this project's name and one-sentence purpose?

You: ordergate — gateway that validates orders before routing to fulfillment

Claude: Question 2/30: Stage — prototype / staging / production / mixed?

You: production

... (28 more questions, one at a time) ...

Claude: FILE PLAN

  Context:
    CLAUDE.md                              — root project context
    CLAUDE.local.md                        — personal, gitignored
    backend/CLAUDE.md                      — backend-specific context

  Configuration:
    .claude/settings.json                  — permissions, hooks, statusLine
    .gitignore                             — additions

  Scoped rules:
    .claude/rules/backend.md               — backend-only safety rules

  Automation:
    .claude/skills/deploy/SKILL.md         — deployment workflow
    .claude/skills/new-migration/SKILL.md  — Alembic migration helper
    .claude/skills/test-writer/SKILL.md    — pytest test generator
    .claude/hooks/block-dangerous-bash.sh
    .claude/hooks/auto-format.sh

  Integrations:
    .mcp.json                              — postgres + github

  Display:
    .claude/statusline.sh                  — rich

  Proceed? [yes / edit / cancel]

You: yes

Claude: ✓ CLAUDE.md — root context
        ✓ CLAUDE.local.md — personal notes
        ✓ backend/CLAUDE.md — backend context
        ✓ .claude/settings.json — permissions, hooks, statusLine wired
        ✓ .claude/rules/backend.md — scoped rules for backend/
        ✓ .claude/skills/deploy/SKILL.md — deployment skill
        ✓ .claude/skills/new-migration/SKILL.md — migration skill
        ✓ .claude/skills/test-writer/SKILL.md — test writer skill
        ✓ .claude/hooks/block-dangerous-bash.sh — safety hook
        ✓ .claude/hooks/auto-format.sh — auto-format hook
        ✓ .claude/statusline.sh — rich status line
        ✓ .mcp.json — MCP stubs (fill in credentials)
        ✓ .gitignore — updated

        Setup complete. Restart Claude Code to activate.
```

---

## Why Claude needs this

A well-configured Claude Code environment requires many coordinated pieces.
Most projects ship with none of them. The wizard produces all of them in one pass:

| What | Why it matters |
|------|---------------|
| **Context** (`CLAUDE.md`) | Claude needs to know the project, its commands, and its rules before writing code |
| **Commands** | Without exact shell invocations, Claude invents plausible-but-wrong commands |
| **Safety** (`settings.json` + hooks) | `permissions.deny` stops footguns; hooks with exit 2 actually block dangerous patterns |
| **Token awareness** (status line) | Without it, neither you nor Claude can tell the context window is full until it's too late |
| **Skills** | Repetitive workflows and specialized tasks become reusable, scoped, restricted |
| **Scoped rules** | Directory-specific rules load only when relevant — saving tokens on every other turn |
| **MCP** | Project-specific tool integrations (databases, APIs, issue trackers) via env vars |
| **Output style** | Match Claude's verbosity to the project — terse for glue code, verbose for onboarding |

---

## Philosophy

1. **Neutral.** No defaults about stack, style, or tooling. The wizard asks, you decide.
2. **Additive.** Existing files are never overwritten silently — merge, backup, or skip.
3. **Conservative.** Unknown answers become `<TBD>`, never invented.
4. **Transparent.** Every generated file is plain text you can edit by hand.
5. **Anthropic-aligned.** Uses the official plugin format, standard hook events, the documented `statusLine` API, and skills format.
6. **Token-conscious.** Keeps `CLAUDE.md` concise, moves scoped rules to `.claude/rules/`, and makes context usage visible.

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

Checks: JSON validity, required files, shellcheck, frontmatter, hook smoke tests (allow + block), status line smoke tests.

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines. Quick rules:

- All hooks: `set -o pipefail` + `jq` fallback
- All templates: `{{PLACEHOLDER}}` syntax only
- Status line: reads stdin JSON, no network calls
- Run `./scripts/validate.sh` before PR

### License

MIT — see [LICENSE](LICENSE).

---

## Acknowledgments

- [Claude Code plugin spec](https://code.claude.com/docs/en/plugin-marketplaces)
- [Skills reference](https://code.claude.com/docs/en/skills)
- [Hook events reference](https://code.claude.com/docs/en/hooks)
- [Status line spec](https://code.claude.com/docs/en/statusline)
