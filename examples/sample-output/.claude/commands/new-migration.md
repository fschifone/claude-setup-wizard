---
description: Create a new Alembic migration with auto-generated diff and safety checks
argument-hint: "<migration message>"
allowed-tools: Bash(uv run alembic:*), Bash(git status:*), Bash(git diff:*), Read, Edit
---

# New migration

Create a new Alembic migration, review the auto-generated diff, and flag any
risky operations before the user commits.

## When to use
Run `/new-migration "add orders.fulfilled_at column"` whenever a schema change
is needed. The argument becomes the migration's description.

## Steps

1. Verify the working tree is clean (warn but don't block if not).
2. Run `uv run alembic revision --autogenerate -m "$ARGUMENTS"`.
3. Read the generated file under `backend/alembic/versions/`.
4. Scan for risky operations:
   - `DROP TABLE` / `DROP COLUMN` → flag as destructive.
   - `ALTER COLUMN ... NOT NULL` without a default → flag as blocking on
     existing data.
   - Missing `downgrade()` body → flag.
5. Report findings. Do NOT auto-apply the migration.

## Guardrails
- Never run `alembic upgrade head` automatically — user decides when.
- Never delete a migration file; if rollback is needed, tell the user to
  remove it manually.
- If the diff is empty, delete the empty revision file and inform the user
  that no schema changes were detected.
