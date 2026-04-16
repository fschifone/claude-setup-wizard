#!/usr/bin/env bash
# Claude Code minimal status line — model + context %
# Reads JSON from stdin.
set -o pipefail

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | grep -o '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4)
  printf "%s" "${model:-Claude}"
  exit 0
fi

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(printf '%s' "$input" | jq -r '.current_usage.used_percentage // empty')

RESET='\033[0m'; BOLD='\033[1m'; CYAN='\033[36m'
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'

if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if   (( pct_int < 50 )); then color="$GREEN"
  elif (( pct_int < 75 )); then color="$YELLOW"
  else                           color="$RED"
  fi
  printf "%b%s%b %b%d%%%b" "$CYAN$BOLD" "$model" "$RESET" "$color" "$pct_int" "$RESET"
else
  printf "%b%s%b" "$CYAN$BOLD" "$model" "$RESET"
fi
