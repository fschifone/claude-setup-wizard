#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# Logs every bash command Claude runs, with timestamp, to .claude/logs/bash.log
# Never blocks. Safe to combine with block-dangerous-bash.sh.
set -o pipefail

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  session=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
  cwd=$(printf '%s' "$input" | jq -r '.cwd // "."')
else
  cmd=$(printf '%s' "$input" | grep -o '"command"[^,}]*' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
  session="unknown"
  cwd="."
fi

[[ -z "$cmd" ]] && exit 0

log_dir="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$log_dir"
printf '[%s] session=%s cwd=%s cmd=%s\n' "$(date -Iseconds)" "$session" "$cwd" "$cmd" >> "$log_dir/bash.log"

exit 0
