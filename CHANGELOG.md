# Changelog

All notable changes to this plugin are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-04-16

### Added
- Initial public release.
- `/setup-wizard` slash command — interactive 29-question wizard with three
  modes: `--new`, `--existing`, `--audit`.
- `/audit` slash command — read-only configuration gap report.
- Four safety & automation hooks:
  - `block-dangerous-bash.sh` — PreToolUse, blocks 13+ catastrophic command
    patterns (rm -rf /, force push on main, curl|bash, fork bombs, mkfs, dd to
    raw disk, DROP DATABASE, TRUNCATE TABLE, and more).
  - `auto-format.sh` — PostToolUse, auto-formats Python, JS/TS, Go, Rust,
    Swift, and shell after Write/Edit/MultiEdit.
  - `run-tests-on-stop.sh` — Stop hook, runs configured test command when
    Claude finishes.
  - `log-bash.sh` — PreToolUse, appends every bash command to
    `.claude/logs/bash.log`.
- Two status line scripts:
  - `rich.sh` — model · context bar · tokens · cwd · git branch · cost.
  - `minimal.sh` — model · context %.
  - Both read `current_usage.used_percentage` from Claude Code's stdin JSON
    and colorize by threshold (green <50%, yellow <75%, red ≥75%).
- Eight templates for generated files: root CLAUDE.md, nested CLAUDE.md,
  CLAUDE.local.md, settings.json, commands, agents, output styles, and MCP.
- GitHub Actions CI that validates JSON, shell syntax (shellcheck), YAML
  frontmatter, hook behavior, and status line output on every push and PR.
- Local validation script `scripts/validate.sh` mirroring CI.
- MIT license.

### Security
- All dangerous command patterns that require regex matching (e.g.
  `curl ... | bash`) are handled in hooks rather than `permissions.deny`,
  because Claude Code's permission system matches command prefixes, not
  arbitrary regex.
- PreToolUse hooks exit with code 2 to actually block execution, not just log.

### Documentation
- `README.md` — public-facing installation, usage, and philosophy.
- `CLAUDE.md` — contributor context (the plugin eats its own dog food).
- `CONTRIBUTING.md` — PR checklist, local testing, release process.

## [Unreleased]

Nothing yet.

---

[1.0.0]: https://github.com/YOUR_USERNAME/claude-setup-wizard/releases/tag/v1.0.0
