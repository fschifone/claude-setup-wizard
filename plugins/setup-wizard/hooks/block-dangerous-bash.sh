#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# Blocks dangerous commands before they execute.
# Exit 0 = allow, Exit 2 = block (Claude Code sees stderr as the reason).
set -o pipefail

input=$(cat)

# Extract the command being run (works with or without jq)
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$(printf '%s' "$input" | grep -o '"command"[^,}]*' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
fi

[[ -z "$cmd" ]] && exit 0

# Dangerous patterns — each is a justified block.
# Extend this list by editing the array below; do not relax defaults.
declare -a DANGER_PATTERNS=(
  'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+/([[:space:]]|$)'   # rm -rf /
  'rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r?[[:space:]]+/([[:space:]]|$)'   # rm -fr /
  ':\(\)\{[[:space:]]*:\|:&[[:space:]]*\};:'                            # fork bomb
  'mkfs\.'                                                              # format filesystem
  'dd[[:space:]]+if=.*of=/dev/(sd|nvme|hd|disk)'                        # dd to raw disk
  '>[[:space:]]*/dev/(sda|nvme|hd|disk)'                                # redirect to raw disk
  'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/([[:space:]]|$)'      # chmod 777 /
  'git[[:space:]]+push[[:space:]]+.*--force(-with-lease)?[[:space:]]+.*(main|master|prod)' # force push prod
  'git[[:space:]]+push[[:space:]]+.*-f[[:space:]]+.*(main|master|prod)'
  'DROP[[:space:]]+DATABASE'                                            # drop db (case-insensitive check below)
  'TRUNCATE[[:space:]]+TABLE'
  'curl[[:space:]]+.*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)'    # curl | bash
  'wget[[:space:]]+.*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)'    # wget | bash
)

# Case-insensitive SQL patterns
cmd_upper=$(printf '%s' "$cmd" | tr '[:lower:]' '[:upper:]')

for pattern in "${DANGER_PATTERNS[@]}"; do
  if [[ "$cmd" =~ $pattern ]] || [[ "$cmd_upper" =~ $pattern ]]; then
    echo "🛑 BLOCKED: command matches dangerous pattern." >&2
    echo "   Command: $cmd" >&2
    echo "   Pattern: $pattern" >&2
    echo "   If this is intentional, run it manually in a terminal — not through Claude." >&2
    exit 2
  fi
done

exit 0
