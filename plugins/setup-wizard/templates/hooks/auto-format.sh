#!/usr/bin/env bash
# PostToolUse hook — matcher: Write|Edit|MultiEdit
# Auto-formats the file Claude just wrote, using the project's configured formatter.
# Non-blocking: formatter failures are logged but do not fail the session.
set -o pipefail

input=$(cat)

# Extract the edited file path
if command -v jq >/dev/null 2>&1; then
  file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
else
  file_path=$(printf '%s' "$input" | grep -o '"file_path"[^,}]*' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

# Detect format by extension — pick the right tool.
# Customize this block per-project; the wizard writes a project-appropriate default.
case "$file_path" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$file_path" >/dev/null 2>&1 || true
      ruff check --fix "$file_path" >/dev/null 2>&1 || true
    elif command -v black >/dev/null 2>&1; then
      black --quiet "$file_path" 2>/dev/null || true
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.yaml|*.yml)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write --log-level=silent "$file_path" 2>/dev/null || true
    fi
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$file_path" 2>/dev/null || true
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt --quiet "$file_path" 2>/dev/null || true
    ;;
  *.swift)
    command -v swiftformat >/dev/null 2>&1 && swiftformat --quiet "$file_path" 2>/dev/null || true
    ;;
  *.sh)
    command -v shfmt >/dev/null 2>&1 && shfmt -w "$file_path" 2>/dev/null || true
    ;;
esac

exit 0
