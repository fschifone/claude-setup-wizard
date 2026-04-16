# Contributing

Thanks for considering a contribution. This project aims to stay small, neutral,
and safe — so the bar for changes that broaden scope is deliberately high.

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/claude-setup-wizard.git
cd claude-setup-wizard
bash scripts/validate.sh    # should pass
```

That's it. There's no build step, no package.json, no virtualenv.

## What we accept

- **Bug fixes** in hooks, status line, or templates (always welcome).
- **Additional dangerous-command patterns** in `block-dangerous-bash.sh` —
  each one must come with a test case in `scripts/validate.sh`.
- **Additional language support** in `auto-format.sh` — add a case branch,
  document it in README.
- **New hooks** — must be opt-in (user selects them in Q25), never auto-enabled.
- **New templates** — must use `{{PLACEHOLDER}}` syntax, nothing else.
- **Documentation improvements** — always welcome.

## What we avoid

- **New slash commands in the wizard plugin itself.** Keep it to `/setup-wizard`
  and `/audit`. If you have a useful command, consider publishing it as a
  separate plugin in a new marketplace entry.
- **Network calls from hooks or the status line.** Everything must work offline.
- **Telemetry or auto-updates.** The plugin is text files; users read them.
- **Dependencies beyond `bash`, `jq` (optional), and `git` (optional).**
- **Opinionated defaults in the wizard's questions.** Neutrality is a feature.
- **Changes that could lock users into this plugin.** All generated files
  must remain editable and work without the plugin installed.

## PR checklist

Before opening a PR:

- [ ] `bash scripts/validate.sh` passes locally
- [ ] New shell scripts have `set -o pipefail` and a `jq`-missing fallback
- [ ] New JSON files validate with `jq empty`
- [ ] New templates use `{{PLACEHOLDER}}` syntax only
- [ ] New dangerous-command patterns have a matching test in `validate.sh`
- [ ] README updated if user-facing behavior changed
- [ ] CLAUDE.md updated if contributor-facing behavior changed
- [ ] Commit messages follow conventional commits
  (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `refactor:`, `test:`)

## Testing a hook locally

```bash
# Simulate a PreToolUse Bash event
echo '{"tool_input":{"command":"YOUR TEST COMMAND"}}' | \
  bash plugins/setup-wizard/templates/hooks/block-dangerous-bash.sh
echo "exit: $?"   # 0 = allow, 2 = block
```

## Testing the status line locally

```bash
cat > /tmp/sample.json <<'EOF'
{
  "model": {"display_name": "Sonnet 4.6"},
  "workspace": {"current_dir": "/tmp/x", "project_dir": "/tmp/x"},
  "current_usage": {
    "used_percentage": 42,
    "input_tokens": 50000,
    "cache_read_input_tokens": 20000,
    "cache_creation_input_tokens": 10000
  },
  "cost": {"total_cost_usd": 0.23}
}
EOF

cat /tmp/sample.json | bash plugins/setup-wizard/statusline/rich.sh; echo
cat /tmp/sample.json | bash plugins/setup-wizard/statusline/minimal.sh; echo
```

## Testing the plugin end-to-end

```bash
# In Claude Code, from this repo's root:
/plugin marketplace add .
/plugin install setup-wizard@claude-setup-wizard

# Then in any throwaway directory:
mkdir /tmp/test-wizard && cd /tmp/test-wizard
# Open Claude Code here, run:
/setup-wizard --new
```

## Releasing

Maintainers only:

1. Bump `version` in both `.claude-plugin/marketplace.json` and
   `plugins/setup-wizard/.claude-plugin/plugin.json` (keep them in sync).
2. Update `CHANGELOG.md`.
3. Tag: `git tag v1.x.y && git push origin v1.x.y`.
4. Users refresh with `/plugin marketplace update claude-setup-wizard`.

## Code of conduct

Be kind. Assume good faith. Prefer small, reviewable PRs over large ones.
