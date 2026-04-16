---
name: setup-wizard
description: Interactive wizard that configures the complete Claude Code environment for this project (CLAUDE.md, skills, hooks, status line, MCP, output styles)
argument-hint: [--new | --existing | --audit | --quick | --full]
allowed-tools: Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(git:*) Bash(mkdir:*) Bash(chmod:*) Bash(test:*) Read Write Edit Glob Grep
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
- `--audit` → Step 1 detection, then Step 5 (report, no writes)
- `--quick` → Quick depth (same as choosing Quick below)
- `--full` → Full depth (same as choosing Full below)
- empty → ask mode first, then depth

**Mode** (if not set by argument):

> **Which mode?**
> 1. **New project** — scaffold from scratch
> 2. **Existing project** — analyze repo, fill gaps
> 3. **Audit only** — report what's missing, don't write

**Depth** (if not set by argument — ask AFTER mode):

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

## Step 2 — The questions

Questions are organized into three tiers. Ask questions for the selected depth,
**skipping any already answered by detection**. Number your questions.

If the user says "skip" or "I don't know" for any question → **silently note it
and move on**. Do NOT write `<TBD>` later — just omit that section from the
generated files.

### QUICK depth — core setup (~8 questions)

These produce a functional `CLAUDE.md` + `settings.json` + safety hook.

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
  [.claude/hooks/<n>.sh]              — per hook selection
  [.claude/output-styles/<n>.md]      — only if Custom style

[Integrations:]
  [.mcp.json]                         — only if MCP answered

[Display:]
  [.claude/statusline.sh]             — only if status line enabled

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

Copy from this plugin's `hooks/` directory only the hooks selected:

- `block-dangerous-bash.sh` — PreToolUse matcher `Bash`, exits 2 on dangerous patterns
- `auto-format.sh`          — PostToolUse matcher `Write|Edit`, runs linter
- `run-tests-on-stop.sh`    — Stop hook, runs test command
- `log-bash.sh`             — PreToolUse matcher `Bash`, appends to `.claude/logs/bash.log`

Wire them into `settings.json` hooks section with `${CLAUDE_PROJECT_DIR}`.

### 4.8 · Status line (`.claude/statusline.sh`)

If Rich → copy `statusline/rich.sh`
If Minimal → copy `statusline/minimal.sh`
Then `chmod +x` and wire into settings.json.

At Quick depth, Minimal is auto-enabled (token awareness is too useful to skip).

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
