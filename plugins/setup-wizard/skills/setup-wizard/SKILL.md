---
name: setup-wizard
description: Interactive wizard that configures the complete Claude Code environment for this project (CLAUDE.md, skills, hooks, status line, MCP, output styles, specialized agents)
argument-hint: [--new | --existing | --auto | --audit | --quick | --full | agents]
allowed-tools: Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(git:*) Bash(mkdir:*) Bash(chmod:*) Bash(test:*) Bash(head:*) Bash(wc:*) Bash(grep:*) Read Write Edit Glob Grep
user-invocable: true
---

# Claude Environment Setup Wizard

You are running an interactive setup wizard that produces a complete Claude Code
configuration for this project. The output is a coherent set of files that make
Claude token-aware, context-aware, safer, and more efficient — without imposing
opinionated defaults on the user.

## Prime directives

1. **Neutral by default.** Never assume stack, style, or tooling. Ask or detect.
2. **One question at a time.** Wait for each answer. No walls of questions.
3. **Detect before asking.** Always inspect the repo first, skip what you can infer.
4. **Plan before writing.** Show the complete file plan, require explicit "yes".
5. **Never overwrite silently.** If a file exists, offer merge / backup / skip.
6. **Omit what's unknown.** If a question is skipped, omit the section entirely
   from generated files — don't write `<TBD>` placeholders. A clean file with
   fewer sections is better than a full file with empty placeholders nobody
   fills in later.
7. **Keep your replies short.** This is a form, not a conversation.

---

## Step 0 — Mode and depth selection

Parse `$ARGUMENTS`:
- `--new` → skip detection, go to Step 2
- `--existing` → Step 1 detection, then Step 2
- `--auto` → Step 1A deep introspection, then Step 1B auto-generation (0 questions)
- `--audit` → Step 1 detection, then Step 5 (report, no writes)
- `--quick` → Quick depth (same as choosing Quick below)
- `--full` → Full depth (same as choosing Full below)
- `agents` → run Step 1 (light detection only), then jump straight to **Step 4.5 — Agent team phase**. Skip Steps 2, 3, 4, 5. This is the invocation used by `/setup-wizard agents`. It lets the user add or regenerate a specialized agent team at any time without re-answering every wizard question. See Step 4.5 for the flow. **`agents` takes precedence** over other flags: `/setup-wizard --full agents` and `/setup-wizard --existing agents` both behave the same as `/setup-wizard agents` (the standalone agent-team phase). If the user wanted the full wizard flow *and* the agent team, they run `/setup-wizard --full` first, then `/setup-wizard agents` — they are two separate invocations by design, because the agent phase is re-runnable and idempotent.
- empty → ask mode first, then depth

**Mode** (if not set by argument):

> **Which mode?**
> 1. **New project** — scaffold from scratch
> 2. **Existing project** — analyze repo, fill gaps
> 3. **Auto** — deep-scan the codebase, generate config with zero questions
> 4. **Audit only** — report what's missing, don't write

**Depth** (if not set by argument — ask AFTER mode, skip for Auto):

> **How thorough?**
> 1. **Quick** (~8 questions, ~2 min) — project identity, stack, commands, safety hook. Good enough to start.
> 2. **Standard** (~15 questions, ~4 min) — adds safety rules, secrets, automation, status line. Right for most projects.
> 3. **Full** (up to 30 questions, ~8 min) — everything: architecture, MCP, skills, scoped rules, output style. For large teams or complex projects.
>
> You can always re-run the wizard later at a deeper level to fill gaps.

---

## Step 1 — Repo detection

**Always run this** (even in `--new` mode, run a lighter version to detect
existing config that shouldn't be overwritten).

Run silently:

```bash
ls -la
find . -maxdepth 3 -type f \( \
  -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" \
  -o -name "go.mod" -o -name "*.xcodeproj" -o -name "Podfile" \
  -o -name "requirements*.txt" -o -name "Gemfile" -o -name "pom.xml" \
  -o -name "build.gradle*" -o -name "composer.json" -o -name "mix.exs" \
  -o -name "pubspec.yaml" -o -name "Dockerfile" -o -name "docker-compose*.yml" \
\) 2>/dev/null
find . -maxdepth 3 \( -name "CLAUDE*.md" -o -name "AGENTS.md" -o -name ".mcp.json" \) 2>/dev/null
test -d .claude && find .claude -type f 2>/dev/null
git log --oneline -5 2>/dev/null
test -f README.md && head -30 README.md
test -f .gitignore && grep -E "^(\.env|CLAUDE\.local|\.claude)" .gitignore
```

Also attempt to detect operational commands:
```bash
# detect test runner
test -f package.json && grep -o '"test"[[:space:]]*:[[:space:]]*"[^"]*"' package.json
test -f pyproject.toml && grep -A2 '\[tool.pytest' pyproject.toml
test -f Makefile && grep -E '^test:' Makefile
# detect linter
test -f .prettierrc* && echo "prettier detected"
test -f .eslintrc* && echo "eslint detected"
test -f setup.cfg && grep '\[flake8\]' setup.cfg
test -f pyproject.toml && grep -E '\[tool\.(ruff|black|flake8)\]' pyproject.toml
# detect build
test -f package.json && grep -o '"build"[[:space:]]*:[[:space:]]*"[^"]*"' package.json
test -f Makefile && grep -E '^build:' Makefile
```

Report findings compactly:

> **Detected:**
> - Stack: <inferred>
> - Test: <detected or "unknown">
> - Linter: <detected or "unknown">
> - Existing Claude config: <list or "none">
> - Git: <branch + last 3 commits, or "not a git repo">
>
> **I'll ask only about what I couldn't infer.**

---

## Step 1A — Deep introspection (Auto mode only)

If `--auto` was selected, go deeper than basic detection. Read actual source
files to understand the project without asking any questions.

### Read these files fully:
- `README.md` — project purpose, setup instructions, architecture notes
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` — dependencies,
  scripts, metadata
- `Makefile` / `Taskfile.yml` / `justfile` — build/test/deploy targets
- `docker-compose*.yml` / `Dockerfile` — services, ports, dependencies
- `.editorconfig`, `.prettierrc*`, `.eslintrc*`, `pyproject.toml [tool.*]` —
  code conventions
- `docs/*.md` or `doc/*.md` — architecture docs (first 3 files)
- A sample of 2–3 source files — to detect patterns (type hints, docstrings,
  import conventions, error handling style)

### Analyze git history:
```bash
git log --format='%an' | sort -u                    # team members
git log --oneline -20                                # recent activity
git log --format='%s' -20                            # commit style
git remote -v                                        # origin
```

### Analyze directory structure:
```bash
find . -maxdepth 2 -type d -not -path './.git*' -not -path './node_modules*'
```

### From all this, infer:
- Project name and purpose (from README or package.json description)
- Stage (from git activity, branch strategy, CI presence)
- Team size (from git authors)
- Stack, languages, frameworks (from dependencies)
- All operational commands (from scripts/Makefile/package.json)
- Architecture and main modules (from directory structure)
- Code conventions (from linter configs and source samples)
- Commit style (from git log)
- Secrets policy (from .gitignore and .env presence)
- NEVER rules (from dangerous files like migrations, generated code, vendor/)

### Then pattern-match against reference catalogs:
- Read [references/mcp-servers.md](references/mcp-servers.md) — match detected
  dependencies to MCP server configs. Generate `.mcp.json` entries for matches.
- Read [references/hooks-patterns.md](references/hooks-patterns.md) — match
  detected linter/formatter/test configs to hook configurations. Wire into
  settings.json.
- Read [references/skills-catalog.md](references/skills-catalog.md) — match
  detected project patterns (deploy targets, migration tools, test frameworks)
  to skill templates. Generate top 2-3 most relevant skills.

### Then go to Step 1B.

---

## Step 1B — Auto-generate and confirm (Auto mode only)

Using everything inferred in Step 1A, generate the complete file plan
as if the user had answered every applicable question. Present it as:

```
AUTO-DETECTED CONFIGURATION

Project: <name> — <purpose>
Stack: <languages + frameworks>
Stage: <inferred> · Team: <N authors detected>

CLAUDE.md will include:
  - Stack: <summary>
  - Commands: <test>, <lint>, <build>, <dev>, <deploy>
  - Rules: NEVER <list>, ALWAYS <list>
  - Pitfalls: <any detected from code patterns>

settings.json will include:
  - Allow: <commands>
  - Deny: rm -rf, force push, <project-specific>
  - Hooks: block-dangerous-bash (recommended)
  - Status line: minimal

FILE PLAN:
  CLAUDE.md                           — <line count> lines
  CLAUDE.local.md                     — personal notes
  .claude/settings.json               — permissions, hooks, status line
  .claude/hooks/block-dangerous-bash.sh
  .claude/statusline.sh               — minimal
  .gitignore                          — protections added

Everything look right? [yes / edit / cancel]
```

If "yes" → go to Step 4 (file generation).
If "edit" → ask which part to change, make the adjustment, re-confirm.
If "cancel" → stop.

The key: **zero questions asked**. The user just confirms or edits the result.

---

## Step 2 — The questions

Questions are organized into three tiers. Ask questions for the selected depth,
**skipping any already answered by detection**. Number your questions.

If the user says "skip" or "I don't know" for any question → **silently note it
and move on**. Do NOT write `<TBD>` later — just omit that section from the
generated files.

### QUICK depth — core setup (~8 questions)

These produce a functional `CLAUDE.md` + `settings.json` + safety hook +
**minimal status line** (auto-included — token awareness is always enabled).

1. **Project name and one-sentence purpose.**
2. **Stage:** prototype / staging / production / mixed?
3. **Languages & frameworks** (confirm or correct what was detected).
4. **Test command** (confirm or provide — e.g. `pytest`, `npm test`).
5. **Lint / format command** (confirm or provide — e.g. `ruff check`, `prettier`).
6. **Build command** (or "none").
7. **Things Claude must NEVER do** — files off-limits, destructive commands,
   anti-patterns. (One question, free-form.)
8. **Enable safety hook?** Block dangerous bash commands (rm -rf, force push,
   curl|bash, DROP DATABASE). Recommended: yes.

**Smart defaults applied at Quick depth:**
- Team size → inferred from git log (1 author = solo, else small team)
- Chat language → English
- Package manager → detected from lock files
- Dev command → detected or omitted
- Deploy → omitted
- DB/migrations → omitted
- Architecture → omitted (section not written)
- ALWAYS rules → omitted unless NEVER rules imply them
- Pitfalls → omitted
- Secrets → `.env` assumed, standard .gitignore protections applied
- MCP → none
- Skills → none
- Status line → Minimal (auto-enabled — token awareness is too useful to skip)
- Output style → Default
- Commit style → detected from git log or conventional commits
- Doc style → omitted
- Scoped rules → none

### STANDARD depth — adds safety, automation, display (~15 questions)

Includes all Quick questions, plus:

9. **Team size:** solo / small team (2–5) / large team?
10. **Dev / run command.**
11. **Deploy command** (or "none").
12. **Database / migration commands** (or "none").
13. **Things Claude must ALWAYS do** (type hints, tests before commit, etc.).
14. **Known pitfalls** — tricky parts where past bugs lived.
15. **How are secrets managed?** (.env / vault / cloud)
16. **Hooks** — multi-select (adds to the safety hook from Q8):
    - [ ] Auto-format on file write
    - [ ] Run tests on Stop
    - [ ] Log all bash commands
17. **Status line:** Rich / Minimal / None?

**Smart defaults applied at Standard depth:**
- Chat language → English
- Architecture → omitted
- MCP → none
- Skills → none
- Output/commit/doc style → defaults or detected
- Scoped rules → none

### FULL depth — everything (~30 questions)

Includes all Standard questions, plus:

18. **Primary chat language:** English / Italian / other?
19. **Main modules / directories** — one line each.
20. **Architectural patterns:** MVC / MVVM / hexagonal / event-driven / other.
21. **Sub-areas needing their own nested `CLAUDE.md`** (e.g. `backend/`, `frontend/`).
22. **Which env files can Claude read vs. never touch?**
23. **External APIs Claude should know about?**
24. **MCP servers** to configure? (postgres, github, filesystem, etc. or "none")
25. **Repetitive workflows → skills?** (`/deploy`, `/test-all`, `/new-migration`)
26. **Specialized skills?** (test-writer, security-reviewer, docs-writer)
27. **Output style:** Default / Concise / Explanatory / Custom?
28. **Commit message style:** conventional commits / free-form / other?
29. **Documentation style:** docstrings required? format?
30. **Scoped rules** — are any NEVER/ALWAYS rules specific to certain directories?
31. **Specialized agent team?** Create role-specialized subagents (frontend, backend,
    critical code reviewer, tester, debugger, db-migrations, security-auditor) that
    Claude auto-delegates to based on task description. (y/N)

    If the user says no → skip Q32 and Q33.
    If yes → continue to Step 4.5 *after* Step 4 normally writes the rest, OR if
    the wizard was invoked as `/setup-wizard agents` skip directly to Step 4.5.

32. **Which agents?** (multi-select, stack-gated — only show roles whose stack
    signals were detected in Step 1):
    - `frontend-specialist` — shown if UI deps detected (React/Vue/Svelte/Next/Angular/SolidJS/SwiftUI)
    - `backend-specialist` — shown if server deps detected (Express/Fastify/Nest/FastAPI/Django/Rails/Go net/http/Spring/Phoenix)
    - `code-reviewer-critical` — always offered (read-only)
    - `tester` — always offered, pre-wired to the detected test command
    - `db-migrations` — shown if Prisma/Drizzle/SQLAlchemy/Alembic/ActiveRecord/Ecto detected
    - `security-auditor` — always offered, opt-in (read-only)
    - `debugger` — always offered

33. **Use recommended models per agent?** (Y/n)
    Defaults: `code-reviewer-critical` → opus, `security-auditor` → opus,
    all others → sonnet. On "no", ask per-agent (`sonnet` / `opus` / `haiku`).

---

## Step 3 — Plan confirmation

Present a complete file plan, grouped. **Only list files that will actually be
generated** — don't list files for skipped/omitted features.

```
FILE PLAN

Context:
  CLAUDE.md                           — root project context
  CLAUDE.local.md                     — personal, gitignored
  [<area>/CLAUDE.md]                  — only if Q21 answered

Configuration:
  .claude/settings.json               — permissions, hooks, status line
  .gitignore                          — additions

[Scoped rules:]
  [.claude/rules/<area>.md]           — only if Q30 answered

[Automation:]
  [.claude/skills/<n>/SKILL.md]       — only if Q25/Q26 answered
  [.claude/agents/<role>.md]          — only if Q31/Q32 answered
  [.claude/hooks/<n>.sh]              — per hook selection
  [.claude/output-styles/<n>.md]      — only if Custom style

[Integrations:]
  [.mcp.json]                         — only if MCP answered

Display:
  .claude/statusline.sh               — always included (minimal at Quick, configurable at Standard+)

Proceed? [yes / edit / cancel]
```

Only on "yes" → Step 4. On "edit" → ask which question to revisit.

---

## Step 4 — File generation

Write each file. After each, print: `✓ <path> — <one-line purpose>`.

### 4.1 · `CLAUDE.md` (root)

Use `templates/CLAUDE.md.template` from this plugin as the base.
Fill placeholders from Step 2 answers. **Omit entire sections** for which
the user skipped or said "none" — do NOT write empty sections, `<TBD>`,
or placeholder text. A concise CLAUDE.md saves tokens on every turn.

For Quick depth: produce a compact file with just Stack, Commands, and
NEVER rules. This is still highly effective — Claude gets the essentials.

**Default NEVER rules (always included at every depth):**
- Share personal information about users, contributors, or team members.

These are prepended to any user-provided NEVER rules.

### 4.2 · `CLAUDE.local.md`

Short personal-notes file. See `templates/CLAUDE.local.md.template`.

### 4.3 · Nested `<area>/CLAUDE.md`

Only at Full depth if Q21 has entries. See `templates/nested-CLAUDE.md.template`.

### 4.4 · `.claude/settings.json`

Assemble dynamically. Base structure:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [/* from detected/answered commands */],
    "deny": [/* always includes rm -rf, force push; extended from NEVER rules */],
    "ask": [/* deploy and other destructive ops */]
  },
  "hooks": {/* from hook selections */},
  "statusLine": {/* from status line selection */}
}
```

Use `templates/settings.json.template` for the skeleton.

### 4.5 · Skills (`.claude/skills/<n>/SKILL.md`)

Only at Full depth if Q25/Q26 have entries. Generate using
`templates/skill.md.template`.

### 4.6 · Scoped rules (`.claude/rules/<area>.md`)

Only at Full depth if Q30 has entries. Generate rules files containing
only the rules that apply to that directory scope.

### 4.7 · Hooks (`.claude/hooks/<n>.sh`)

Copy from this plugin's `templates/hooks/` directory only the hooks selected:

- `block-dangerous-bash.sh` — PreToolUse matcher `Bash`, exits 2 on dangerous patterns
- `auto-format.sh`          — PostToolUse matcher `Write|Edit`, runs linter
- `run-tests-on-stop.sh`    — Stop hook, runs test command
- `log-bash.sh`             — PreToolUse matcher `Bash`, appends to `.claude/logs/bash.log`

Wire them into `settings.json` hooks section with `"${CLAUDE_PROJECT_DIR}"` (always quoted — paths may contain spaces).

### 4.8 · Status line (`.claude/statusline.sh`) — ALWAYS GENERATED

**This is always included at every depth level.** Token awareness is critical
for effective Claude usage — without it, neither Claude nor the user can see
context filling up until it's too late.

- **Quick depth** → Minimal (auto-enabled, no question asked)
- **Standard depth** → user chooses Rich / Minimal / None (default: Rich)
- **Full depth** → user chooses Rich / Minimal / None (default: Rich)
- **Auto mode** → Minimal

If Rich → copy `statusline/rich.sh`
If Minimal → copy `statusline/minimal.sh`
If None (only available at Standard+) → skip

Then `chmod +x` and wire into settings.json:
```json
"statusLine": {
  "type": "command",
  "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/statusline.sh\"",
  "padding": 0
}
```

### 4.9 · MCP (`.mcp.json`)

Only at Full depth if Q24 != none. For each server, emit a stub with `TODO:`
for connection details. Never invent URLs or API keys.

### 4.10 · Output style (`.claude/output-styles/<n>.md`)

Only if Q27 = Custom.

### 4.11 · `.gitignore`

**Append** (never overwrite). Add these lines if not present:
```
# Claude Code
CLAUDE.local.md
.claude/settings.local.json
.claude/logs/
.env
.env.local
```

---

## Step 4.5 — Agent team phase

Run this phase if:
- the wizard was invoked as **`/setup-wizard agents`** (see Step 0), OR
- Full depth was chosen and Q31 was answered "yes".

Skipped entirely otherwise. At the end of the full-flow wizard (after 4.11),
print this one-liner if the phase was skipped:

> Tip — add a specialized agent team later with `/setup-wizard agents`.

### 4.5.1 · Load detection facts

If `/setup-wizard agents` was the entry point, Steps 2–4 didn't run. In that
case, run **Step 1** (light detection) now to populate the facts the templates
need. If the wizard is coming from the full flow, the facts from Step 1 + Step 2
are already available — reuse them, don't re-detect.

Facts required per role:
- `{{PROJECT_NAME}}`, `{{FRAMEWORK}}`, `{{PACKAGE_MANAGER}}`
- `{{TEST_CMD}}`, `{{LINT_CMD}}`, `{{BUILD_CMD}}`
- `{{SCOPE_DIRS}}` — inferred per role from repo layout. Write it as a human-readable phrase, not a path (it appears inside prose like "Only modify files under `{{SCOPE_DIRS}}`"):
  - frontend → first match among `src/`, `app/`, `web/`, `client/`, `frontend/`, `ui/`, `components/`
  - backend  → first match among `server/`, `api/`, `backend/`, `app/` (excluding UI files), `src/` (if monolith)
  - db-migrations → first match among `migrations/`, `db/migrate/`, `alembic/`, `prisma/migrations/`, `drizzle/`, `priv/repo/migrations/`
  - reviewer/auditor/debugger/tester → write the literal string `the whole repository` (NOT `.`) so the prose reads naturally. These roles don't need a scope restriction; the text exists only for consistency across templates.
  - If no match is found for a role that needs one (e.g. frontend role selected but no recognizable UI directory) → ask a one-line question: "Which directory does the frontend live in?"
- `{{MIGRATION_TOOL}}` — Prisma / Drizzle / Alembic / ActiveRecord / Ecto / SQLAlchemy / Flyway / Liquibase (only for `db-migrations`)
- `{{LOCAL_CLAUDE_MD}}` — if a nested CLAUDE.md exists for the relevant area, its path; else empty (drop the line)

If a fact can't be inferred, **ask a one-line question**. Never write `{{PLACEHOLDER}}` to disk unfilled.

### 4.5.2 · Role selection

If coming from the full flow, the selection is Q32's answer.

If coming from `/setup-wizard agents`, ask now — stack-gated as described in
Q32 above. Include, in the prompt, a short "why" for each role so a first-time
user knows what they're picking:

```
Which specialists do you want? (multi-select, space to toggle, enter to confirm)
  [ ] frontend-specialist     — owns UI components and client code
  [ ] backend-specialist      — owns API endpoints and server logic
  [ ] code-reviewer-critical  — read-only; strict pre-merge review
  [ ] tester                  — writes and fixes tests
  [ ] debugger                — root-causes errors and failing behavior
  [ ] db-migrations           — forward-only schema changes
  [ ] security-auditor        — read-only; security findings only

Only roles with detected stack signals are pre-checked.
```

Then ask Q33 (model choice) unless coming from the full flow.

### 4.5.3 · Generation

For each selected role:

1. Read `templates/agents/<role>.md.template` from this plugin.
2. Substitute every `{{PLACEHOLDER}}` from the facts in 4.5.1.
3. If a placeholder has no value (e.g. `{{LOCAL_CLAUDE_MD}}` absent), **remove
   every line** that contains it — don't write unfilled placeholders. Apply this
   globally, not per-placeholder: after substitution, scan the file line-by-line
   and drop any line still matching `{{[A-Z_]+}}`. **Exception**: never apply
   this to the `description:` or `name:` frontmatter fields — those MUST have
   concrete values. If a placeholder in those two lines cannot be filled, ask
   the user; do not write the agent file.
4. Override the `model:` field with the user's Q33 choice for that role.
5. Write to `.claude/agents/<role>.md`.
6. If the file already exists, apply the standard **merge / backup / skip**
   prompt (same rule used for CLAUDE.md and settings.json — per Prime directive #5).
7. Print `✓ .claude/agents/<role>.md — <role description short>`.

After all files are written, run a final validation:
```bash
grep -r '{{' .claude/agents/ 2>/dev/null && echo "ERROR: unfilled placeholders" || echo "✓ no unfilled placeholders"
```
If any placeholder remains, report it and stop.

### 4.5.4 · Delegation hints in CLAUDE.md

Append (never overwrite) a short **"Agent team — delegation hints"** block to
the root `CLAUDE.md`. **Build the list dynamically** — include one line per
agent you actually generated, skip the rest. Substitute any remaining
placeholders against the same facts from 4.5.1. If `{{TEST_CMD}}` or
`{{MIGRATION_TOOL}}` are absent for included lines, drop the parenthetical
rather than writing an unfilled placeholder.

Template fragment for each generated role (assemble only the selected ones):

```markdown
## Agent team

Claude delegates to these subagents automatically based on task description.
- `frontend-specialist` — UI, components, styling, client state
- `backend-specialist`  — endpoints, server logic, integrations
- `code-reviewer-critical` — read-only, strict pre-merge review (opus)
- `tester` — writes and fixes tests; wired to `{{TEST_CMD}}`
- `debugger` — root-causes errors before fixing
- `db-migrations` — forward-only schema changes ({{MIGRATION_TOOL}})
- `security-auditor` — read-only security findings (opus)
```

**Idempotence**: if `## Agent team` already exists in `CLAUDE.md` (from a prior
run), replace just that section's bullets — don't append a second `## Agent
team` heading. Do not touch any other part of `CLAUDE.md`.

This block is for humans reading `CLAUDE.md`. Claude's actual delegation comes
from the agents' own `description` fields, not from this list.

### 4.5.5 · Done

Print:

> Agent team ready. Restart Claude Code, then run `/agents` to see them under
> Library → Project. Try: "review the diff on this branch" → the critical
> reviewer should pick it up automatically.

If the wizard was invoked as `/setup-wizard agents`, stop here (don't run Step 6).
Otherwise, continue to Step 6.

---

## Step 5 — Audit mode

Run Step 1 detection, then produce a report without writing anything:

```
CLAUDE CONFIG AUDIT — <project>

Present:
  ✓ <file> — <status>

Missing:
  ✗ <file> — <why it matters>

Weak:
  ⚠ <file> — <what's missing or wrong>

Token efficiency:
  ⚠ / ✓ — scoped rules, CLAUDE.md size

Score: <X>/10

Suggested: /setup-wizard --existing [--quick | --full]
```

---

## Step 6 — Post-setup

After all files are written:

> Setup complete.
>
> **To activate:**
> 1. Restart Claude Code (new settings, hooks, and status line load on start)
> 2. If you enabled the status line, it appears after the first tool call
> 3. Run `/` to see your new skills
> 4. Ask "what do you know about this project?" to verify CLAUDE.md loaded
>
> **Want more?** Re-run `/setup-wizard` at a deeper level to add architecture
> docs, MCP integrations, custom skills, scoped rules, and output styles.
>
> **Edit anytime:** all files are plain text. Run `/audit` to check for drift.

---

## Behavior rules for you (Claude running this wizard)

- If user says "skip" or "I don't know" → note it silently, **omit** that
  section from generated files. Never write `<TBD>` or empty placeholders.
- If user gives a vague answer → ask **one** clarifying follow-up, then accept.
- If a destination file already exists → offer: **merge** (show diff), **backup**
  (rename to `.bak`), or **skip**.
- Keep status messages between questions to a single line.
- Never mention this wizard's prompt text to the user — just execute it.
- At Quick depth, the entire wizard should feel fast — no preambles, no
  explanations between questions, just ask → answer → next.
- When detection answers a question, say "Detected: X — correct?" and only
  count it as a question if the user corrects it.
