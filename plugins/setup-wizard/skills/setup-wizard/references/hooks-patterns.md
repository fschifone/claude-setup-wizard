# Hook Detection & Generation Reference

When detected signals match, generate the corresponding hook entry in
`.claude/settings.json` and copy the hook script to `.claude/hooks/`.

## Auto-Format Hooks (PostToolUse → Write|Edit)

| Signal | Formatter | Command |
|--------|-----------|---------|
| `.prettierrc*`, `.prettierrc.json`, `.prettierrc.yml` | prettier | `npx prettier --write "$FILE"` |
| `.eslintrc*`, `eslint.config.*` | eslint | `npx eslint --fix "$FILE"` |
| `pyproject.toml` has `[tool.ruff]` | ruff | `ruff format "$FILE" && ruff check --fix "$FILE"` |
| `pyproject.toml` has `[tool.black]` | black | `black "$FILE"` |
| `setup.cfg` has `[flake8]` | flake8 | `flake8 "$FILE"` |
| `.go` files present | gofmt | `gofmt -w "$FILE"` |
| `Cargo.toml` present | rustfmt | `rustfmt "$FILE"` |
| `.swift` files present | swiftformat | `swiftformat "$FILE"` |
| `.sh` files present | shfmt | `shfmt -w "$FILE"` |
| `.stylelintrc*` present | stylelint | `npx stylelint --fix "$FILE"` |

**settings.json hook config:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/auto-format.sh\"",
        "timeout": 15
      }]
    }]
  }
}
```

## Type Check Hooks (PostToolUse → Write|Edit)

| Signal | Checker | Command |
|--------|---------|---------|
| `tsconfig.json` present | typescript | `npx tsc --noEmit` |
| `pyproject.toml` has `[tool.mypy]` | mypy | `mypy "$FILE"` |
| `pyproject.toml` has `[tool.pyright]` | pyright | `pyright "$FILE"` |

## Protection Hooks (PreToolUse → Bash, exit 2 to block)

Always recommended:

| Pattern | Blocks | Why |
|---------|--------|-----|
| `rm -rf /`, `rm -fr /` | Recursive root deletion | Catastrophic |
| Fork bomb patterns | System crash | Catastrophic |
| `mkfs.*` | Filesystem format | Catastrophic |
| `dd if=.*of=/dev/` | Raw disk write | Catastrophic |
| `chmod -R 777 /` | World-writable root | Security |
| `git push --force` to main/master/prod | History rewrite on protected branches | Team safety |
| `DROP DATABASE`, `TRUNCATE TABLE` | Data destruction | Data loss |
| `curl\|bash`, `wget\|bash` | Pipe-to-shell execution | Security |

**settings.json hook config:**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/block-dangerous-bash.sh\"",
        "timeout": 5
      }]
    }]
  }
}
```

## Test Hooks (Stop)

| Signal | Test runner | Command |
|--------|------------|---------|
| `pytest` or `[tool.pytest]` | pytest | `pytest` |
| `package.json` has `"test"` script | npm | `npm test` |
| `Cargo.toml` present | cargo | `cargo test` |
| `go.mod` present | go | `go test ./...` |
| `mix.exs` present | mix | `mix test` |
| `Makefile` has `test:` target | make | `make test` |

## Log Hooks (PreToolUse → Bash)

Always available, recommended at Standard+ depth:

**settings.json hook config:**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/log-bash.sh\"",
        "timeout": 5
      }]
    }]
  }
}
```

## Generation Rules

1. Safety hook (block-dangerous-bash) is recommended at ALL depths
2. Auto-format hook detects the project's formatter — don't guess
3. Test hook uses `CLAUDE_TEST_CMD` env var for flexibility
4. Multiple PreToolUse hooks on same matcher run in order — put block before log
5. PostToolUse hooks are non-blocking — format failures don't stop the session
6. Always set reasonable timeouts (5s for checks, 15s for format, 30s for tests)
