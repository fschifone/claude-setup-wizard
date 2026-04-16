#!/usr/bin/env bash
# Claude Code rich status line
# Displays: model · context bar · tokens · git branch · cwd · cost
# Reads JSON from stdin (Claude Code passes session state via stdin)
# Requires: jq (widely available; falls back gracefully if missing)

set -o pipefail

input=$(cat)

# --- Colors (ANSI; respected by most terminals) ---
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
MAGENTA='\033[35m'
BLUE='\033[34m'

# --- jq fallback ---
if ! command -v jq >/dev/null 2>&1; then
  # Minimal fallback without jq
  model=$(printf '%s' "$input" | grep -o '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4)
  printf "%b %s %b(install jq for full status line)%b" "$CYAN" "${model:-Claude}" "$DIM" "$RESET"
  exit 0
fi

# --- Parse stdin ---
model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
project_dir=$(printf '%s' "$input" | jq -r '.workspace.project_dir // ""')

# Context usage (input-only, matching Claude Code's own calculation)
used_pct=$(printf '%s' "$input" | jq -r '.current_usage.used_percentage // empty')
input_tokens=$(printf '%s' "$input" | jq -r '.current_usage.input_tokens // 0')
cache_read=$(printf '%s' "$input" | jq -r '.current_usage.cache_read_input_tokens // 0')
cache_create=$(printf '%s' "$input" | jq -r '.current_usage.cache_creation_input_tokens // 0')
total_input=$((input_tokens + cache_read + cache_create))

# Cost (if exposed)
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')

# --- Build directory short-path ---
dir_display="$cwd"
if [[ -n "$project_dir" && "$cwd" == "$project_dir"* ]]; then
  rel="${cwd#$project_dir}"
  dir_display="$(basename "$project_dir")${rel}"
fi
# Tilde-shorten home
dir_display="${dir_display/#$HOME/~}"

# --- Git branch ---
git_branch=""
if [[ -n "$cwd" ]] && cd "$cwd" 2>/dev/null; then
  git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
  if [[ -n "$git_branch" ]]; then
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      git_branch="${git_branch}*"  # dirty marker
    fi
  fi
fi

# --- Context progress bar (10 chars) ---
context_segment=""
if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
  # Round to integer
  pct_int=$(printf '%.0f' "$used_pct")
  filled=$((pct_int / 10))
  (( filled > 10 )) && filled=10
  (( filled < 0 )) && filled=0
  empty=$((10 - filled))

  # Color by threshold
  if (( pct_int < 50 )); then
    ctx_color="$GREEN"
  elif (( pct_int < 75 )); then
    ctx_color="$YELLOW"
  else
    ctx_color="$RED"
  fi

  bar=$(printf '%.0s▓' $(seq 1 $filled 2>/dev/null))$(printf '%.0s░' $(seq 1 $empty 2>/dev/null))
  # Fallback if seq produces nothing
  [[ -z "$bar" ]] && bar="$(head -c "$filled" < /dev/zero | tr '\0' '▓')$(head -c "$empty" < /dev/zero | tr '\0' '░')"

  # Token count humanized
  if (( total_input > 1000000 )); then
    tokens_human=$(awk "BEGIN{printf \"%.1fM\", $total_input/1000000}")
  elif (( total_input > 1000 )); then
    tokens_human=$(awk "BEGIN{printf \"%.0fk\", $total_input/1000}")
  else
    tokens_human="$total_input"
  fi

  context_segment=" ${ctx_color}[${bar}]${RESET} ${ctx_color}${pct_int}%${RESET} ${DIM}(${tokens_human})${RESET}"
fi

# --- Cost segment ---
cost_segment=""
if [[ -n "$cost" && "$cost" != "null" ]]; then
  cost_segment=" ${DIM}\$${cost}${RESET}"
fi

# --- Git segment ---
git_segment=""
if [[ -n "$git_branch" ]]; then
  git_segment=" ${MAGENTA}⎇ ${git_branch}${RESET}"
fi

# --- Assemble ---
printf "%b%s%b%b %b%s%b%b%b" \
  "$CYAN$BOLD" "$model" "$RESET" \
  "$context_segment" \
  "$BLUE" "$dir_display" "$RESET" \
  "$git_segment" \
  "$cost_segment"
