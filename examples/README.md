# Sample output

This directory shows exactly what `/setup-wizard` generates for a fictional
project — "ordergate", a hexagonal-architecture order validation service with
a Python/FastAPI backend and SwiftUI iOS client.

Use these files as:
- **Reference** — "what does a complete setup actually look like?"
- **Starting point** — copy and adapt if your project is similar.
- **Verification** — diff your wizard output against these to spot gaps.

## What's here

```
sample-output/
├── CLAUDE.md                         ← root project context
├── CLAUDE.local.md                   ← personal, gitignored
├── .claude/
│   ├── settings.json                 ← permissions + hooks + statusLine wired
│   ├── commands/
│   │   └── new-migration.md          ← generated slash command
│   └── agents/
│       └── test-writer.md            ← generated subagent
├── backend/CLAUDE.md                 ← nested context
└── ios-app/CLAUDE.md                 ← nested context
```

Missing from this sample (would be copied by the wizard into `.claude/hooks/`
and `.claude/statusline.sh`):
- the 4 hook scripts — see `plugins/setup-wizard/templates/hooks/` in the repo root
- the status line script — see `plugins/setup-wizard/statusline/`

## Notes on what's intentionally NOT here

- **`.mcp.json`** — the sample project doesn't use MCP servers.
- **`.claude/output-styles/`** — the sample uses the default output style.
- **`.claude/logs/`** — created at runtime by the `log-bash` hook; gitignored.
- **Real secrets** — every value that looks like a secret is a template
  reference to an env var. No credentials are embedded.

## Token awareness preview

With the rich status line installed, here's what a session on this project
looks like:

```
Sonnet 4.6  [▓▓▓▓░░░░░░] 42% (80k)  ordergate/backend  ⎇ feature/sig-rotation-v2*  $0.23
```

Colors: green <50%, yellow <75%, red ≥75%. The `*` marks a dirty git tree.
