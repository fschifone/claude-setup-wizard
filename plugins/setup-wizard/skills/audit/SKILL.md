---
name: audit
description: Audit the current Claude Code configuration and report gaps without writing any files
allowed-tools: Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(test:*) Read Glob
user-invocable: true
---

# Claude Config Audit

Run a read-only audit of this project's Claude Code configuration and report
gaps. Do not write any files.

## Checks

Inspect the filesystem and report the status of each item:

### Context files
- [ ] `CLAUDE.md` — project context (required)
- [ ] `CLAUDE.local.md` — personal overrides (gitignored)
- [ ] `<area>/CLAUDE.md` — nested context for sub-modules

### Configuration
- [ ] `.claude/settings.json` — permissions, hooks, statusLine
- [ ] `.claude/settings.json` has `permissions.allow` entries
- [ ] `.claude/settings.json` has `permissions.deny` entries (safety)
- [ ] `.claude/settings.json` has `statusLine` configured
- [ ] `.claude/settings.json` has `hooks` configured

### Automation
- [ ] `.claude/skills/*/SKILL.md` — custom skills (slash commands, subagents)
- [ ] `.claude/hooks/*.sh` — executable hook scripts
- [ ] `.claude/statusline.sh` — executable status line script

### Safety
- [ ] `.gitignore` protects `CLAUDE.local.md`
- [ ] `.gitignore` protects `.env*`
- [ ] `.gitignore` protects `.claude/settings.local.json`
- [ ] `.gitignore` protects `.claude/logs/`

### Token efficiency
- [ ] `.claude/rules/*.md` — scoped rules (load only when relevant files touched)
- [ ] `CLAUDE.md` is under 150 lines (larger files waste tokens every turn)
- [ ] No duplicated rules between root CLAUDE.md and nested CLAUDE.md files

### Integrations
- [ ] `.mcp.json` — MCP server config (optional)

## Output format

Print a single report like this:

```
CLAUDE CONFIG AUDIT

Present:
  ✓ CLAUDE.md
  ✓ .claude/settings.json

Missing:
  ✗ .claude/settings.json — no permissions or hooks; Claude runs ungated
  ✗ Status line — no context/token visibility during sessions

Weak:
  ⚠ CLAUDE.md — missing "Commands" section; Claude will guess how to build/test
  ⚠ .gitignore — doesn't protect CLAUDE.local.md (secrets risk)

Token efficiency:
  ⚠ CLAUDE.md is 210 lines — consider moving scoped rules to .claude/rules/
  ✓ Scoped rules in .claude/rules/ — good separation

Score: <X>/10

Next: /setup-wizard --existing
```

Compute score as: (present_count / total_checks) * 10, rounded.

## Rules

- Read-only. Never write anything.
- If a file is present but empty or near-empty, mark it ⚠ (weak), not ✓.
- If `.claude/settings.json` exists but has no `hooks` or `statusLine`, list
  those specifically as weak.
- Be specific in the "why it matters" one-liner for each gap.
