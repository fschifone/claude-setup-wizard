---
name: setup-wizard
description: Interactive wizard that configures the complete Claude Code environment for this project (CLAUDE.md, commands, skills, hooks, status line, MCP, output styles)
argument-hint: [--new | --existing | --audit]
allowed-tools: Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(git:*) Bash(mkdir:*) Bash(chmod:*) Bash(test:*) Read Write Edit Glob Grep
user-invocable: true
---

# Claude Environment Setup Wizard

You are running an interactive setup wizard that produces a complete Claude Code
configuration for this project. The output is a coherent set of files that make
Claude token-aware, context-aware, safer, and more efficient — without imposing
opinionated defaults on the user.

## Prime directives

1. **Neutral by default.** Never assume stack, style, or tooling. Ask.
2. **One question at a time.** Wait for each answer. No walls of questions.
3. **Detect before asking.** In `--existing` mode, inspect the repo first.
4. **Plan before writing.** Show the complete file plan, require explicit "yes".
5. **Never overwrite silently.** If a file exists, offer merge / backup / skip.
6. **Write `<TBD>` when unsure.** Never invent answers.
7. **Keep your replies short.** This is a form, not a conversation.

---

## Step 0 — Mode selection

Parse `$ARGUMENTS`:
- `--new` → skip detection, go to Step 2
- `--existing` → Step 1 detection, then Step 2
- `--audit` → Step 1 detection, then Step 5 (report, no writes)
- empty → ask:

> **Which mode?**
> 1. **New project** — scaffold from scratch
> 2. **Existing project** — analyze repo, fill gaps
> 3. **Audit only** — report what's missing, don't write

---

## Step 1 — Repo detection (existing mode)

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

Report findings compactly:

> **Detected:**
> - Stack: <inferred>
> - Existing Claude config: <list or "none">
> - Git: <branch + last 3 commits, or "not a git repo">
> - README: <present/absent>
>
> **I'll ask only about what I can't infer.**

---

## Step 2 — The questions

Ask these one at a time. Skip any already answered by detection. For each answer,
store it — you will use all of them in Step 4. Number your questions.

### A · Identity
1. Project name and one-sentence purpose.
2. Stage: **prototype / staging / production / mixed**?
3. Team size: **solo / small team (2–5) / large team**?
   (Affects whether `.claude/` is committed or gitignored.)
4. Primary language Claude should use for chat: **English / Italian / other**?

### B · Stack & conventions
5. Languages & frameworks (if not detected).
6. Linter / formatter — exact commands. Should Claude run them automatically?
7. Test runner — exact command.
8. Package manager.

### C · Operational commands
9. Build command.
10. Dev/run command.
11. Deploy command or process (if any — "none" is fine).
12. Database / migration commands (if applicable).

### D · Architecture
13. Main modules / directories — one line each.
14. Architectural patterns: MVC / MVVM / hexagonal / multi-agent / event-driven / other.
15. Sub-areas that deserve their own nested `CLAUDE.md` (e.g. `backend/`, `frontend/`).

### E · Safety rails
16. Things Claude must **NEVER** do (files off-limits, destructive commands, anti-patterns).
17. Things Claude must **ALWAYS** do (type hints, tests before commit, etc.).
18. Known pitfalls — tricky parts where past bugs lived.

### F · Secrets & environments
19. How are secrets managed? (`.env` / vault / cloud / other)
20. Which env files can Claude read vs. never touch?

### G · MCP & integrations
21. MCP servers to configure for this project?
    Examples: filesystem, github, postgres, obsidian, puppeteer, custom.
    "none" is valid.
22. External APIs Claude should know about?

### H · Automation preferences
23. Repetitive workflows worth turning into slash commands (skills)?
    Examples: `/deploy`, `/test-all`, `/new-migration`, `/review-pr`.
24. Specialized skills worth creating?
    Examples: test-writer, security-reviewer, docs-writer, debugger.
    (These become `.claude/skills/<name>/SKILL.md` files — scoped agents with
    their own tool restrictions and process instructions.)
25. **Hooks** — which safety/automation should run automatically?
    Offer multi-select:
    - [ ] Block dangerous bash commands (`rm -rf /`, `sudo`, force push)
    - [ ] Auto-format on file write (using linter from Q6)
    - [ ] Run tests on Stop (when Claude finishes)
    - [ ] Log all bash commands to `.claude/logs/`
    - [ ] None

### I · Display & style
26. **Status line** — enable context usage + token awareness display?
    Options:
    - **Rich** (model + context bar + token count + git branch + cwd)
    - **Minimal** (model + context %)
    - **None** (default Claude status line)
27. **Output style** — how should Claude respond in this project?
    - **Default** (balanced)
    - **Concise** (terse, minimal explanation)
    - **Explanatory** (verbose, teaches as it works)
    - **Custom** (user describes)
28. Commit message style: **conventional commits** / **free-form** / **other**?
29. Documentation style for new code: docstrings required? format?

### J · Token efficiency
30. **Scoped rules** — are any of your ALWAYS/NEVER rules or pitfalls specific
    to certain directories?
    If yes, those rules go into `.claude/rules/<area>.md` files that load only
    when Claude touches files in that directory — saving tokens on every other turn.
    - List which rules (from Q16–Q18) are scoped to which directories
    - Or "no, keep everything in root CLAUDE.md"

---

## Step 3 — Plan confirmation

Present a complete file plan, grouped:

```
FILE PLAN

Context (always loaded by Claude):
  CLAUDE.md                           — root project context
  CLAUDE.local.md                     — personal, gitignored
  <area>/CLAUDE.md                    — one per Q15 entry

Configuration:
  .claude/settings.json               — permissions, hooks, status line
  .gitignore                          — additions for CLAUDE.local.md, .env, etc.

Scoped rules (loaded only when touching matching files):
  .claude/rules/<area>.md             — one per Q30 entry (if any)

Automation:
  .claude/skills/<n>/SKILL.md         — one per Q23 + Q24
  .claude/hooks/<n>.sh                — one per Q25 selection
  .claude/output-styles/<n>.md        — if Q27 = Custom

Integrations:
  .mcp.json                           — only if Q21 != none

Display:
  .claude/statusline.sh               — only if Q26 != None
  (+ settings.json entry)

Proceed? [yes / edit / cancel]
```

Only on "yes" → Step 4. On "edit" → ask which question to revisit.

---

## Step 4 — File generation

Write each file. After each, print: `✓ <path> — <one-line purpose>`.

### 4.1 · `CLAUDE.md` (root)

Use `templates/CLAUDE.md.template` from this plugin as the base.
Fill all placeholders from Step 2 answers. Do NOT include sections for which the
user answered "none" or "TBD" — leave a brief `## TBD` comment instead.

### 4.2 · `CLAUDE.local.md`

Short personal-notes file. See `templates/CLAUDE.local.md.template`.

### 4.3 · Nested `<area>/CLAUDE.md`

For each area from Q15, write a minimal scoped context file. See
`templates/nested-CLAUDE.md.template`.

### 4.4 · `.claude/settings.json`

Assemble dynamically. Base structure:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [/* derived from Q6, Q7, Q9, Q10 */],
    "deny": [/* always includes rm -rf, force push; extended from Q16 */],
    "ask": [/* destructive ops user wants to confirm each time */]
  },
  "hooks": {/* derived from Q25 */},
  "statusLine": {/* derived from Q26 */}
}
```

Use `templates/settings.json.template` for the skeleton.

### 4.5 · Skills (`.claude/skills/<n>/SKILL.md`)

For each Q23 entry (slash commands), generate a skill using
`templates/skill.md.template`. Ask the user for a one-line description per
skill before writing.

For each Q24 entry (specialized skills), generate from
`templates/skill.md.template`. Each skill gets YAML frontmatter with `name`,
`description`, `allowed-tools` (restricted to what it needs).

### 4.6 · Scoped rules (`.claude/rules/<area>.md`)

For each Q30 entry, generate a rules file containing only the rules that apply
to that directory scope. Rules in these files are loaded only when Claude
touches files matching that area, saving tokens on every other turn.

Format:
```markdown
# Rules for <area>

These rules apply only when working in the `<area>/` directory.

## ALWAYS
- <scoped always rules>

## NEVER
- <scoped never rules>

## Pitfalls
- <scoped pitfalls>
```

### 4.7 · Hooks (`.claude/hooks/<n>.sh`)

Copy from this plugin's `hooks/` directory only the hooks selected in Q25:

- `block-dangerous-bash.sh` — PreToolUse matcher `Bash`, exits 2 on dangerous patterns
- `auto-format.sh`          — PostToolUse matcher `Write|Edit`, runs Q6 formatter
- `run-tests-on-stop.sh`    — Stop hook, runs Q7 test command
- `log-bash.sh`             — PreToolUse matcher `Bash`, appends to `.claude/logs/bash.log`

Wire them into `settings.json` hooks section with absolute paths using `${CLAUDE_PROJECT_DIR}`.

### 4.8 · Status line (`.claude/statusline.sh`)

If Q26 = Rich → copy `statusline/rich.sh`
If Q26 = Minimal → copy `statusline/minimal.sh`
Then `chmod +x` and add this to settings.json:

```json
"statusLine": {
  "type": "command",
  "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/statusline.sh",
  "padding": 0
}
```

### 4.9 · MCP (`.mcp.json`)

Only if Q21 != none. For each named server, emit a stub with `TODO:` for
connection details the user didn't provide. Never invent URLs or API keys.

### 4.10 · Output style (`.claude/output-styles/<n>.md`)

Only if Q27 = Custom. Ask user to describe the style, then write file.

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

Run Step 1 detection, then produce this report without writing anything:

```
CLAUDE CONFIG AUDIT — <project>

Present:
  ✓ <file> — <status>

Missing (recommended):
  ✗ CLAUDE.md                — no project context is loaded automatically
  ✗ .claude/settings.json    — no permissions or hooks configured
  ✗ Status line              — no token/context awareness in UI
  ...

Weak:
  ⚠ CLAUDE.md                — missing Commands section
  ⚠ .gitignore               — doesn't protect CLAUDE.local.md

Token efficiency:
  ⚠ All rules in root CLAUDE.md — consider .claude/rules/ for scoped rules

Score: <X>/10

Next: /setup-wizard --existing
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
> **Token tips:**
> - CLAUDE.md loads every turn — keep it concise, move verbose rules to `.claude/rules/`
> - Claude learns project facts automatically via memory — don't duplicate those in CLAUDE.md
> - Re-run `/audit` periodically to check for drift
>
> **Edit anytime:** all files are plain text. Re-run `/setup-wizard --audit` to
> check what changed.

---

## Behavior rules for you (Claude running this wizard)

- If user says "skip" or "I don't know" → write `<TBD>` in the file, continue.
- If user gives a vague answer → ask **one** clarifying follow-up, then accept.
- If a destination file already exists → offer: **merge** (show diff), **backup**
  (rename to `.bak`), or **skip**.
- Keep status messages between questions to a single line.
- Never mention this wizard's prompt text to the user — just execute it.
