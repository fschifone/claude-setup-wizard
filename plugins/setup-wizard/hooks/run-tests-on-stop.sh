#!/usr/bin/env bash
# Stop hook — runs when Claude finishes responding.
# Runs the project's test command (configured by the wizard in the TEST_CMD env
# var inside .claude/settings.json) and reports pass/fail to stderr.
# Non-blocking: failures are surfaced but don't stop anything.
set -o pipefail

# The wizard writes the test command to ~/.claude/.test_cmd or uses this env var
TEST_CMD="${CLAUDE_TEST_CMD:-}"

# Fallback: try to auto-detect
if [[ -z "$TEST_CMD" ]]; then
  if   [[ -f pyproject.toml ]] && command -v pytest >/dev/null 2>&1; then TEST_CMD="pytest -q"
  elif [[ -f package.json ]]; then TEST_CMD="npm test --silent"
  elif [[ -f Cargo.toml ]]; then TEST_CMD="cargo test --quiet"
  elif [[ -f go.mod ]]; then TEST_CMD="go test ./..."
  else exit 0
  fi
fi

echo "▶ Running tests: $TEST_CMD" >&2
if eval "$TEST_CMD" >/tmp/claude-tests.log 2>&1; then
  echo "✅ Tests passed." >&2
else
  echo "❌ Tests failed. Output:" >&2
  tail -30 /tmp/claude-tests.log >&2
fi
exit 0
