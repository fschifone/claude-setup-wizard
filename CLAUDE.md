# Claude Setup Wizard — contributor context

This repo IS a Claude Code plugin, AND uses its own output to configure the
contributor experience. Eat your own dog food.

**Stage:** production · **Team:** open source · **Primary chat language:** English

---

## What this project is

A Claude Code plugin distributed as a GitHub-hosted marketplace. Users install
it with `/plugin marketplace add <this-repo>` and then get `/setup-wizard` and
`/audit` available everywhere.

## Stack

- **Language:** Bash (hooks, status line) + Markdown (skills, templates)
- **No build step.** Plain files, version-controlled.
- **Dependencies at runtime:** `jq` (optional, all scripts have a fallback),
  `git` (optional, for status line branch display).
- **CI:** GitHub Actions — validates JSON schema + bash syntax on every PR.

## Commands

| Purpose                | Command                              |
|------------------------|--------------------------------------|
| Validate all files     | `./scripts/validate.sh`              |
| Test a hook locally    | `echo '<json>' \| bash templates/hooks/<n>.sh` |
| Test status line       | `echo '<json>' \| bash statusline/rich.sh` |
| Lint shell scripts     | `shellcheck templates/hooks/*.sh statusline/*.sh` |

## Architecture

The repo is a **marketplace with a single plugin**.

```
claude-setup-wizard/                     ← marketplace root
├── .claude-plugin/marketplace.json      ← lists the plugin(s) below
└── plugins/setup-wizard/                ← one plugin
    ├── .claude-plugin/plugin.json       ← plugin manifest
    ├── skills/                          ← SKILL.md files (setup-wizard, audit, fix)
    ├── templates/hooks/                 ← hook scripts copied to user projects
    ├── statusline/                      ← bash scripts that read stdin JSON
    └── templates/                       ← placeholders filled by the wizard
```

The wizard itself is a **single skill** (`skills/setup-wizard/SKILL.md`)
that reads templates, asks questions, and writes files into the user's project.
No executable code runs at install time — Claude interprets the markdown
skill and orchestrates everything.

## Rules

### Claude must ALWAYS
- Use `set -o pipefail` in every bash script.
- Include a `jq`-missing fallback in every script that parses stdin JSON.
- Use `${CLAUDE_PROJECT_DIR}` for paths in hook commands (never hardcoded).
- Keep templates neutral — no stack-specific defaults in the wizard's questions.
- Use `{{PLACEHOLDER}}` syntax in templates. Nothing else. No Jinja, no mustache.
- Run tests (`./scripts/validate.sh`) before committing.
- Push code when tests pass and implementation is done.

### Claude must NEVER
- Invent MCP server URLs or API credentials in the `.mcp.json` template.
- Overwrite user files without offering merge/backup/skip.
- Add telemetry, network calls, or auto-updates to hooks or the status line.
- Use `rm -rf`, `sudo`, or any destructive command anywhere in this repo.
- Remove the `_comment` keys from JSON templates — they're documentation.
- Share personal information about the user or contributors.

### Known pitfalls
- **`permissions.allow` patterns are prefix-matched, not glob.** `Bash(curl * | sh:*)`
  does NOT work as you'd expect. Dangerous command patterns that need regex go
  in hooks, not permissions.
- **Status line JSON schema may evolve.** Always use `// empty` or `// "default"`
  in jq queries. Never crash on missing fields.
- **Hook exit codes matter.** Exit 0 = allow, exit 2 = block (PreToolUse only).
  Any other non-zero = warning logged but tool proceeds.
- **Marketplace `source` field** accepts either a relative path (`./plugins/...`)
  or a git URL. Keep it relative for this repo.
- **`${CLAUDE_PROJECT_DIR}` must always be quoted** in hook/statusline commands
  (`"${CLAUDE_PROJECT_DIR}/..."`). Paths with spaces break unquoted expansions.

## Secrets

This repo has no secrets. No credentials, no tokens, nothing.
If you're adding a new hook that needs credentials, use env vars referenced as
`${VAR_NAME}` and document them in the README — never hardcode.

## External context

- Claude Code docs: <https://code.claude.com/docs>
- Plugin spec: <https://code.claude.com/docs/en/plugin-marketplaces>
- Hook events: <https://code.claude.com/docs/en/hooks>
- Status line: <https://code.claude.com/docs/en/statusline>
- Official examples: <https://github.com/anthropics/claude-code/tree/main/plugins>

## Style

- **Commits:** conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`)
- **Documentation:** every user-facing file starts with a 1–3 line summary of
  what it does and when it's invoked.
- **Response verbosity (when Claude works on this repo):** concise. This repo's
  audience is developers who read code. Don't over-explain.

---

## Adding a new hook

1. Write the `.sh` in `plugins/setup-wizard/templates/hooks/`, with `set -o pipefail`,
   jq fallback, and `exit 0` at the end (unless it's a blocking hook).
2. Add an entry to the wizard's Q25 multi-select in `skills/setup-wizard/SKILL.md`.
3. Add the wiring stanza to `templates/settings.json.template` under the
   appropriate event (`PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, etc.).
4. Test: `echo '{"tool_input":{"command":"..."}}' | bash templates/hooks/your-hook.sh`
5. Document it in the README's "safety hooks" section.

## Adding a new skill

1. Create `plugins/setup-wizard/skills/<name>/SKILL.md` with YAML frontmatter:
   `name`, `description`, `allowed-tools`.
2. Keep `allowed-tools` as restrictive as possible — principle of least privilege.
3. The markdown body becomes the prompt Claude executes when the skill runs.
4. Test locally: add the marketplace from your fork, install the plugin, invoke
   the skill.

## Adding a new template

1. Put it in `plugins/setup-wizard/templates/<name>.template`.
2. Use `{{PLACEHOLDER_NAME}}` syntax exclusively.
3. Document each placeholder at the top of the template file in a `<!-- -->`
   comment block.
4. Reference the template from `skills/setup-wizard/SKILL.md` Step 4.
