#!/usr/bin/env bash
# Local validation — mirrors what CI runs in GitHub Actions.
# Run before opening a PR: ./scripts/validate.sh
set -e

cd "$(dirname "$0")/.."

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Setup Wizard — local validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# --- check tools ---
for t in jq shellcheck; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "❌ missing: $t — install it first (brew install $t / apt install $t)"
    exit 1
  fi
done
echo "✓ tools available (jq, shellcheck)"
echo

# --- validate JSON ---
echo "→ Validating JSON files"
while IFS= read -r file; do
  if jq empty "$file" >/dev/null 2>&1; then
    echo "  ✓ $file"
  else
    echo "  ❌ $file"
    jq empty "$file"
    exit 1
  fi
done < <(find . -name "*.json" -not -path "./node_modules/*" -not -path "./.git/*")
echo

# --- required files ---
echo "→ Required files"
for f in \
  .claude-plugin/marketplace.json \
  plugins/setup-wizard/.claude-plugin/plugin.json \
  plugins/setup-wizard/skills/setup-wizard/SKILL.md \
  plugins/setup-wizard/skills/audit/SKILL.md \
  plugins/setup-wizard/skills/fix/SKILL.md \
  plugins/setup-wizard/hooks/block-dangerous-bash.sh \
  plugins/setup-wizard/hooks/auto-format.sh \
  plugins/setup-wizard/hooks/run-tests-on-stop.sh \
  plugins/setup-wizard/hooks/log-bash.sh \
  plugins/setup-wizard/statusline/rich.sh \
  plugins/setup-wizard/statusline/minimal.sh \
  README.md LICENSE CLAUDE.md
do
  if [[ -f "$f" ]]; then
    echo "  ✓ $f"
  else
    echo "  ❌ missing: $f"
    exit 1
  fi
done
echo

# --- shellcheck ---
echo "→ Shellcheck"
while IFS= read -r script; do
  if shellcheck -S warning "$script"; then
    echo "  ✓ $script"
  else
    echo "  ❌ $script"
    exit 1
  fi
done < <(find plugins scripts -name "*.sh" 2>/dev/null)
echo

# --- frontmatter ---
echo "→ Skill frontmatter"
while IFS= read -r f; do
  if head -1 "$f" | grep -q '^---$'; then
    echo "  ✓ $f"
  else
    echo "  ❌ missing frontmatter: $f"
    exit 1
  fi
done < <(find plugins/setup-wizard/skills -name "SKILL.md" 2>/dev/null)
echo

# --- smoke-test hooks ---
echo "→ Hook smoke tests"

# safe command → allowed
echo '{"tool_input":{"command":"ls -la"}}' | \
  bash plugins/setup-wizard/hooks/block-dangerous-bash.sh
echo "  ✓ block-dangerous-bash allows 'ls -la'"

# dangerous command → blocked (exit 2)
set +e
echo '{"tool_input":{"command":"rm -rf /"}}' | \
  bash plugins/setup-wizard/hooks/block-dangerous-bash.sh 2>/dev/null
rc=$?
set -e
if [[ $rc -ne 2 ]]; then
  echo "  ❌ block-dangerous-bash did NOT block 'rm -rf /' (exit=$rc)"
  exit 1
fi
echo "  ✓ block-dangerous-bash blocks 'rm -rf /' (exit 2)"

# log-bash writes a line
tmpdir=$(mktemp -d)
echo '{"tool_input":{"command":"echo hi"},"session_id":"x","cwd":"."}' | \
  CLAUDE_PROJECT_DIR="$tmpdir" bash plugins/setup-wizard/hooks/log-bash.sh
test -s "$tmpdir/.claude/logs/bash.log"
rm -rf "$tmpdir"
echo "  ✓ log-bash writes to log"
echo

# --- smoke-test status line ---
echo "→ Status line smoke tests"
sample='{"model":{"display_name":"Sonnet 4.6"},"workspace":{"current_dir":"/tmp/x","project_dir":"/tmp/x"},"current_usage":{"used_percentage":42,"input_tokens":50000,"cache_read_input_tokens":20000,"cache_creation_input_tokens":10000}}'

for sl in rich minimal; do
  out=$(echo "$sample" | bash "plugins/setup-wizard/statusline/${sl}.sh")
  if echo "$out" | grep -q "Sonnet 4.6" && echo "$out" | grep -q "42%"; then
    echo "  ✓ ${sl}.sh produces model + percentage"
  else
    echo "  ❌ ${sl}.sh output looks wrong:"
    echo "     $out"
    exit 1
  fi
done
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ All validations passed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
