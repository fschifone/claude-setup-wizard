# Skills Detection & Generation Reference

When project patterns are detected, suggest and generate matching skills
as `.claude/skills/<name>/SKILL.md` files.

## Detection → Skill Matrix

### Deployment Skills

| Signal | Skill name | Description |
|--------|-----------|-------------|
| `fly.toml` or `flyctl` in scripts | deploy | Run `fly deploy` with pre-flight checks |
| `vercel.json` or `vercel` in deps | deploy | Deploy to Vercel with build verification |
| `netlify.toml` | deploy | Deploy to Netlify |
| `heroku` in Procfile or scripts | deploy | Deploy to Heroku with maintenance mode |
| `docker-compose.yml` + deploy scripts | deploy | Docker-based deployment workflow |
| `serverless.yml` or `serverless` in deps | deploy | Serverless framework deploy |
| `terraform/` or `*.tf` files | infra | Run Terraform plan/apply with review |
| `Makefile` has `deploy:` | deploy | Run make deploy with confirmation |

### Database Skills

| Signal | Skill name | Description |
|--------|-----------|-------------|
| `alembic/` or `alembic` in deps | new-migration | Create Alembic migration with safety checks |
| `prisma/` or `prisma` in deps | new-migration | Run `prisma migrate dev` with review |
| `db/migrate/` (Rails) | new-migration | Rails migration generator |
| `migrations/` + Django | new-migration | Django makemigrations + migrate |
| `drizzle.config.*` | new-migration | Drizzle migration workflow |
| SQL files or ORM detected | db-query | Safe database query helper (read-only by default) |

### Testing Skills

| Signal | Skill name | Description |
|--------|-----------|-------------|
| `pytest` + `tests/` | test-writer | Generate pytest tests following project patterns |
| `jest` or `vitest` + `__tests__/` | test-writer | Generate JS/TS tests matching project style |
| `cypress/` or `playwright/` e2e dirs | e2e-test | Generate end-to-end test scenarios |
| Low test/source ratio (< 0.3) | test-writer | Prioritize untested modules |

### Code Quality Skills

| Signal | Skill name | Description |
|--------|-----------|-------------|
| `.github/PULL_REQUEST_TEMPLATE*` | review-pr | PR review following team checklist |
| Large codebase (>200 files) | review-pr | Code review with architecture awareness |
| `CHANGELOG.md` present | release-notes | Generate changelog entries from git diff |
| `openapi.*` or `swagger.*` | api-docs | Update API documentation from code changes |

### Component/Code Generation Skills

| Signal | Skill name | Description |
|--------|-----------|-------------|
| `components/` + React/Vue/Svelte | new-component | Generate component with tests + story |
| `src/api/` or `routes/` | new-endpoint | Scaffold API endpoint with validation + tests |
| `cmd/` (Go) or `bin/` patterns | new-command | Scaffold CLI command |

## Skill Template

Generated skills use this structure:

```yaml
---
name: {{name}}
description: {{description}}
allowed-tools: {{tools}}
---

# {{title}}

{{purpose}}

## Steps
1. {{step}}

## Guardrails
- {{guardrail}}
- Never modify files outside the scope of this skill.
```

## Generation Rules

1. Only suggest skills for patterns actually detected in the project
2. Keep `allowed-tools` minimal — principle of least privilege
3. Match existing project conventions (detected from source files)
4. At Quick depth: no skills generated
5. At Standard depth: suggest but don't generate (mention in post-setup)
6. At Full depth or --auto: generate top 2-3 most relevant skills
7. `/fix` mode: suggest skills as SUGGESTIONS (lowest priority)

## Tool Restriction Guide

| Skill type | Recommended allowed-tools |
|-----------|--------------------------|
| Read-only (review, audit) | `Read Glob Grep` |
| Code generation | `Read Write Glob Grep` |
| Deployment | `Bash(git:*) Bash(fly:*) Read` (scope to specific commands) |
| Database migration | `Bash(alembic:*) Read Write Glob` |
| Testing | `Read Write Glob Grep Bash(pytest:*)` |
