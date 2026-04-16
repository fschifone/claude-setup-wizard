# backend

Inherits rules from `../CLAUDE.md`. This file adds context specific to the Python/FastAPI backend.

## Purpose
REST + webhook service that validates orders against business rules and routes them to fulfillment.

## Local structure
```
app/
├── domain/          ← pure business rules, no I/O, no frameworks
├── application/     ← use cases, orchestrate domain + repositories
├── infrastructure/  ← DB adapters, external API clients
├── api/             ← FastAPI routers (thin)
└── config.py
tests/
├── unit/            ← one test file per domain module
├── integration/     ← use case tests with DB fixture
└── e2e/             ← full-stack via httpx.AsyncClient
```

## Local commands
- Run a single test: `pytest tests/unit/test_order.py -q`
- Type check: `uv run mypy app/ --strict`
- DB migration: `uv run alembic revision --autogenerate -m "<msg>"`

## Local conventions
- All public functions have docstrings (Google style).
- Async everywhere — no sync DB calls in request handlers.
- Dependency injection via FastAPI `Depends`; no global state.
- One aggregate per domain module (DDD-lite).

## Gotchas specific to this area
- The domain layer must import zero third-party packages. `ruff` has a rule
  configured to enforce this — don't disable it.
- `OrderRepository.save()` is idempotent; calling it twice with the same
  `OrderID` is fine, but a different payload raises `OrderConflictError`.
- Session-scoped DB fixture in `conftest.py` resets between tests. If a test
  hangs, it's usually a missing `await` on `session.commit()`.
