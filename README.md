# Claude Setup Wizard

> **Interactive wizard that configures the complete Claude Code environment for any project — in under 5 minutes.**

An installable Claude Code plugin that asks a guided set of questions and
generates a coherent, production-grade configuration: `CLAUDE.md` hierarchy,
skills, safety hooks, a token-aware status line, scoped rules, MCP config,
and output styles.

**Neutral by design.** No opinionated defaults are imposed — the wizard asks,
you decide.

---

## What it produces

Running `/setup-wizard` generates a complete Claude Code configuration:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project context loaded automatically every session |
| `CLAUDE.local.md` | Personal, gitignored overrides |
| `<area>/CLAUDE.md` | Nested context for sub-modules |
| `.claude/settings.json` | Permissions, hooks, status line wiring |
| `.claude/skills/*/SKILL.md` | Custom skills for workflows and specialized tasks |
| `.claude/rules/*.md` | Scoped rules that load only for matching directories |
| `.claude/hooks/*.sh` | Safety & automation hooks |
| `.claude/statusline.sh` | Token-aware status bar with context meter |
| `.claude/output-styles/*.md` | Custom response styles |
| `.mcp.json` | MCP server configuration |
| `.gitignore` | Extended to protect secrets and local files |

---

## Install

**One-time, per machine:**

```bash
# Inside Claude Code
/plugin marketplace add fschifone/claude-setup-wizard
/plugin install setup-wizard@claude-setup-wizard
```

Then restart Claude Code so commands, hooks, and the status line are picked up.

---

## Use

```
/setup-wizard              # asks: new project / existing / audit
/setup-wizard --new        # scaffold from scratch
/setup-wizard --existing   # analyze repo, fill gaps
/setup-wizard --audit      # read-only gap report, no writes
/audit                     # standalone audit skill
```

### Example session

```
You: /setup-wizard --existing

Claude: Detected:
  - Stack: Python 3.12 + FastAPI + PostgreSQL
  - Existing Claude config: none
  - Git: main (3 commits)
  - README: present

  I'll ask only about what I can't infer. Question 1/29:
  What is this project's name and one-sentence purpose?

You: "ordergate — gateway service that validates orders before routing to fulfillment"

Claude: Question 2/29: Stage — prototype / staging / production / mixed?

... (27 more questions, each one-at-a-time) ...

Claude: 📋 FILE PLAN
  CLAUDE.md                            — root project context
  .claude/settings.json                — permissions, hooks, statusLine
  .claude/skills/deploy/SKILL.md       — from Q23
  .claude/skills/new-migration/SKILL.md — from Q23
  .claude/skills/test-writer/SKILL.md  — from Q24
  .claude/rules/backend.md             — scoped rules from Q30
  .claude/hooks/block-dangerous-bash.sh
  .claude/hooks/auto-format.sh
  .claude/statusline.sh                — rich
  .mcp.json                            — postgres + github
  .gitignore                           — additions

  Proceed? [yes / edit / cancel]

You: yes

Claude: ✓ CLAUDE.md — root context written
        ✓ .claude/settings.json — permissions, hooks, statusLine wired
        ✓ .claude/commands/deploy.md — slash command scaffolded
        ... etc ...

        ✅ Setup complete. Restart Claude Code to activate.
```

---

## The status line

If you enable it, the **rich** status line shows:

```
Sonnet 4.6  [▓▓▓▓▓░░░░░] 47% (94k)  ordergate/backend  ⎇ feature/audit-log*  $0.23
└── model   └── context  └── tokens  └── cwd            └── git (dirty)      └── cost
```

Colors switch from green → yellow → red as context fills. Uses the
`current_usage.used_percentage` field exposed by Claude Code (input tokens only,
matching Claude Code's own calculation).

---

## The safety hooks

When selected, these hooks run automatically:

- **`block-dangerous-bash.sh`** (PreToolUse) — exits with code 2, which actually
  blocks the tool call. Catches `rm -rf /`, fork bombs, `mkfs`, `dd` to disks,
  `curl | bash`, force-push to main, `DROP DATABASE`, and more.
- **`auto-format.sh`** (PostToolUse) — formats Python, JS/TS, Go, Rust, Swift,
  Shell after any `Write`/`Edit`/`MultiEdit`. Non-blocking.
- **`run-tests-on-stop.sh`** (Stop) — runs your test command when Claude
  finishes responding.
- **`log-bash.sh`** (PreToolUse) — appends every bash invocation to
  `.claude/logs/bash.log` for audit.

All hooks are plain `bash`, readable, and editable. No hidden magic.

---

## Philosophy

1. **Neutral.** No defaults about stack, style, or tooling are imposed. The
   wizard asks.
2. **Additive.** Existing files are never overwritten silently — merge, backup,
   or skip.
3. **Conservative.** If you don't know an answer, it writes `<TBD>` instead of
   inventing one.
4. **Transparent.** Every generated file is plain text you can edit.
5. **Anthropic-aligned.** Uses the official plugin format
   (`.claude-plugin/plugin.json`), standard hook events, the documented
   `statusLine` API, and the `current_usage` field for token awareness.

---

## What Claude needs to perform at its best

This plugin exists because a well-configured Claude Code environment requires
many coordinated pieces, and most projects ship with none of them. The wizard
produces all of them in one shot:

### 1. Context (`CLAUDE.md` hierarchy)
Claude needs to know **what the project is**, **how to build/test/run it**,
**what it must never do**, and **where the tricky parts are** — before writing
a single line of code.

### 2. Operational commands
Claude needs the exact shell invocations for build/test/deploy/migrate. Without
them, it will invent plausible-but-wrong commands.

### 3. Safety rails (`settings.json` + hooks)
- `permissions.deny` stops common footguns (`rm -rf`, force push).
- `permissions.ask` makes deploy-like commands require explicit confirmation.
- `PreToolUse` hooks with exit code 2 actually block dangerous patterns.

### 4. Token / context awareness (`statusLine`)
Without the status line, Claude (and you) can't tell how full the context
window is until it's too late. The rich status line makes this visible on
every exchange.

### 5. Reusable workflows (`skills/`)
Repetitive tasks (deploy, review-pr, add-migration) and specialized tasks
(test-writer, security-reviewer) become skills with restricted tool sets.

### 5b. Token efficiency (`rules/`)
Directory-scoped rules in `.claude/rules/` load only when Claude touches
matching files — keeping per-turn token cost low for large projects.

### 6. External integrations (`.mcp.json`)
MCP servers expose project-specific tools (databases, Obsidian vaults, issue
trackers). The wizard stubs them; you fill in credentials via env vars.

### 7. Response style (`output-styles/`)
Match Claude's verbosity to the project's needs — terse for CI glue code,
explanatory for onboarding docs.

The wizard covers all seven.

---

## Development

```
claude-setup-wizard/
├── .claude-plugin/
│   └── marketplace.json          ← marketplace manifest (install entry point)
├── plugins/setup-wizard/
│   ├── .claude-plugin/plugin.json
│   ├── skills/                    ← setup-wizard, audit (SKILL.md format)
│   ├── commands/                  ← legacy commands (backward compat)
│   ├── hooks/                     ← 4 shell scripts
│   ├── statusline/                ← rich.sh, minimal.sh
│   └── templates/                 ← all generated-file templates
└── .github/workflows/validate.yml ← CI: validates JSON + bash syntax
```

### Contributing
- Open an issue before large changes.
- All hooks must be POSIX `bash`, must have `set -o pipefail`, and must
  include a fallback for missing `jq`.
- Status line scripts must read from stdin and must not depend on network.
- Templates must use `{{PLACEHOLDER}}` syntax — no Jinja, no mustache.
- Run `./scripts/validate.sh` before PR.

### License
MIT — see [LICENSE](LICENSE).

---

## Acknowledgments

- Claude Code plugin spec: <https://code.claude.com/docs/en/plugin-marketplaces>
- Status line spec: <https://code.claude.com/docs/en/statusline>
- Hook events reference: <https://code.claude.com/docs/en/hooks>
