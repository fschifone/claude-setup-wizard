# MCP Server Detection & Generation Reference

When detected signals match, generate the corresponding `.mcp.json` entry.
Never invent URLs or credentials — use `${ENV_VAR}` placeholders.

## Detection → Generation Matrix

### Databases

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `@supabase/supabase-js` in package.json | supabase | `{"command":"npx","args":["-y","@supabase/mcp-server"],"env":{"SUPABASE_URL":"${SUPABASE_URL}","SUPABASE_KEY":"${SUPABASE_KEY}"}}` |
| `pg`, `postgres`, `knex`, `prisma` in deps | postgres | `{"command":"npx","args":["-y","@modelcontextprotocol/server-postgres"],"env":{"DATABASE_URL":"${DATABASE_URL}"}}` |
| `sqlite3`, `better-sqlite3` in deps | sqlite | `{"command":"npx","args":["-y","@modelcontextprotocol/server-sqlite","${SQLITE_DB_PATH}"]}` |
| `@neondatabase/serverless` in deps | neon | `{"command":"npx","args":["-y","@neondatabase/mcp-server-neon"],"env":{"NEON_API_KEY":"${NEON_API_KEY}"}}` |
| `@libsql/client`, `drizzle-orm` + turso | turso | `{"command":"npx","args":["-y","@tursodatabase/mcp-server"],"env":{"TURSO_DATABASE_URL":"${TURSO_DATABASE_URL}","TURSO_AUTH_TOKEN":"${TURSO_AUTH_TOKEN}"}}` |
| `pymongo`, `mongoose` in deps | mongodb | `{"command":"npx","args":["-y","mcp-mongo-server"],"env":{"MONGODB_URI":"${MONGODB_URI}"}}` |
| `redis`, `ioredis` in deps | redis | `{"command":"npx","args":["-y","@modelcontextprotocol/server-redis"],"env":{"REDIS_URL":"${REDIS_URL}"}}` |

### Version Control & DevOps

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `.git` directory + `github.com` remote | github | `{"command":"npx","args":["-y","@modelcontextprotocol/server-github"],"env":{"GITHUB_TOKEN":"${GITHUB_TOKEN}"}}` |
| `.git` directory + `gitlab.com` remote | gitlab | `{"command":"npx","args":["-y","@modelcontextprotocol/server-gitlab"],"env":{"GITLAB_TOKEN":"${GITLAB_TOKEN}"}}` |
| `.linear` references or Linear URLs in docs | linear | `{"command":"npx","args":["-y","@linear/mcp-server"],"env":{"LINEAR_API_KEY":"${LINEAR_API_KEY}"}}` |

### Cloud Infrastructure

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `@aws-sdk/*` in deps | aws | `{"command":"npx","args":["-y","@aws/mcp-server"],"env":{"AWS_PROFILE":"${AWS_PROFILE}"}}` |
| `wrangler.toml` or `@cloudflare/*` in deps | cloudflare | `{"command":"npx","args":["-y","@cloudflare/mcp-server"],"env":{"CLOUDFLARE_API_TOKEN":"${CLOUDFLARE_API_TOKEN}"}}` |
| `vercel.json` or `@vercel/*` in deps | vercel | `{"command":"npx","args":["-y","@vercel/mcp-server"],"env":{"VERCEL_TOKEN":"${VERCEL_TOKEN}"}}` |

### Monitoring

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `@sentry/*` in deps | sentry | `{"command":"npx","args":["-y","@sentry/mcp-server"],"env":{"SENTRY_AUTH_TOKEN":"${SENTRY_AUTH_TOKEN}"}}` |

### Browser & Testing

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `playwright` in deps or devDeps | playwright | `{"command":"npx","args":["-y","@playwright/mcp-server"]}` |
| `puppeteer` in deps | puppeteer | `{"command":"npx","args":["-y","@anthropic/mcp-puppeteer"]}` |

### Communication

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| `@slack/bolt` or `.slack` config | slack | `{"command":"npx","args":["-y","@anthropic/mcp-slack"],"env":{"SLACK_BOT_TOKEN":"${SLACK_BOT_TOKEN}"}}` |
| `@notionhq/client` in deps | notion | `{"command":"npx","args":["-y","@notionhq/mcp-server"],"env":{"NOTION_API_KEY":"${NOTION_API_KEY}"}}` |

### Utility

| Signal | MCP Server | Generate |
|--------|-----------|----------|
| Any project (always useful) | filesystem | `{"command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","./"]}` |
| Any project (persistent memory) | memory | `{"command":"npx","args":["-y","@modelcontextprotocol/server-memory"]}` |

## Generation Rules

1. Only generate entries for servers whose detection signals are present
2. Always use `${ENV_VAR}` for credentials — never hardcode
3. Add a `_comment` field explaining what credential is needed
4. If multiple database clients detected, pick the primary one (most imports)
5. `filesystem` and `memory` are always good suggestions but not auto-added — only if user chose Full depth or --auto detected complex project
