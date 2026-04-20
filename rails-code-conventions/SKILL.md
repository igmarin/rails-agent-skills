---
name: rails-code-conventions
description: >
  A daily checklist for writing clean Rails code, covering design principles
  (DRY, YAGNI, PORO, CoC, KISS), per-path rules (models, services, workers,
  controllers), structured logging, and comment discipline. Defers style and
  formatting to the project's configured linter(s). Use when writing, reviewing,
  or refactoring Ruby on Rails code, or when asked about Rails best practices,
  clean code, or code quality. Trigger words: code review, refactor, RoR,
  clean code, best practices, Ruby on Rails conventions.
---

# Rails Code Conventions

**Style source of truth:** Style and formatting defer to the project's configured linter(s). This skill adds **non-style behavior** and **architecture guidance** only. For Hotwire + Tailwind specifics, see **rails-stack-conventions**.

## Linter — initial analysis

Detect → run → defer. Do not invent style rules.

- Ruby: check for `.rubocop.yml` / `standard` gem → `bundle exec rubocop` or `bundle exec standardrb`
- Frontend: check for `eslint.config.*`, `.eslintrc*`, `biome.json`, or `package.json` lint script → run accordingly
- **If no config is found:** note this to the user — do not default to any tool.

## Quick Reference

| Topic | Rule |
|-------|------|
| Style/format | Project linter(s) — detect and run as above; do not invent style rules here |
| Principles | DRY, YAGNI, PORO where it helps, CoC, KISS |
| Comments / tags | Explain **why**; tagged notes need actionable context |
| Logging | First arg string, second arg hash; no string interpolation; `event:` when useful for dashboards |
| Deep stacks | Chain **rails-stack-conventions** → domain skills (services, jobs, RSpec) |

## Code Review / Refactoring Workflow

When reviewing or refactoring Rails code, follow this sequence:

1. **Run linter** — detect config, run the appropriate tool, note absence if none found.
2. **Check area-specific rules** — apply the "Apply by area" table below to each changed path.
3. **Verify tests gate** — confirm failing tests exist before any new behavior; run specs and checkpoints.
4. **Chain to specialised skills** — use the Integration table to pull in deeper guidance (security, jobs, specs, etc.) as needed.

## Design Principles

DRY, YAGNI, PORO, CoC, KISS — applied with judgment, not as rituals. Extract on real duplication; defer generalization until the second use case; prefer Rails defaults and document intentional deviations only.

## Comments and tagged notes

Comment **why**, not **what**. Tagged notes — `TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:` — are MANDATORY on assumptions, deferrals, business-rule constants, known limitations, and non-obvious tradeoffs. Each tag is followed by actionable context (owner, ticket id, deadline, or next step). Naked tags (`# TODO: fix this`) fail review.

```ruby
# BAD — unusable
# TODO: fix this
rate = TIER_RATES.fetch(tier, 0.0)

# GOOD — next step + dependency visible
# TODO: replace TIER_RATES with DB-backed lookup (PRI-482; blocked on legal).
rate = TIER_RATES.fetch(tier, 0.0)
```

## Structured Logging

- **First arg:** static string. **Second arg:** hash of structured fields (`user_id:`, `order_id:`, …). Never interpolate values into the message.
- **Always include `event:`** — the grouping dimension in log aggregators. Use dot-namespaced values like `"order.processing_started"`. No alternate keys (`:type`, `:action`, `:name`).
- **Errors log the backtrace.** Every rescue for an unexpected error calls `Rails.logger.error` with BOTH `e.message` AND `e.backtrace.first(5).join("\n")`.

```ruby
# BAD — interpolation loses structure; cannot filter by field in log aggregators
Rails.logger.info("Processing order #{order.id} for user #{user.id}")

# GOOD — static message, structured data, filterable fields
Rails.logger.info("order.processing_started", {
  event: "order.processing_started",
  order_id: order.id,
  user_id: user.id,
  amount_cents: order.total_cents
})
```

## Apply by area (path patterns)

Rules below apply **when those paths exist** in the project. If a path is absent, skip that row.

| Area | Path pattern | Guidance |
|------|--------------|----------|
| **ActiveRecord performance** | `app/models/**/*.rb` | Eager load in loops; prefer `pluck` / `exists?` / `find_each`. N+1: run `bullet` → fix eager loads → re-run clean |
| **Background jobs** | `app/workers/**/*.rb`, `app/jobs/**/*.rb` | Clear job shape, queues, idempotency, structured errors — depth: **rails-background-jobs** |
| **Error handling** | `app/services/**/*.rb`, `app/lib/**/*.rb`, `app/exceptions/**/*.rb` | Domain exceptions + layer `rescue_from` as the app does today; after changes, specs must cover rescue paths |
| **Logging / tracing** | `app/services/**/*.rb`, `app/workers/**/*.rb`, `app/jobs/**/*.rb`, `app/controllers/**/*.rb`, `app/repositories/**/*.rb` | Structured logs; APM spans/tags on hot paths when the stack has APM |
| **Controllers** | `app/controllers/**/*_controller.rb` | Strong params; thin actions → services; IDOR / PII → **rails-security-review** |
| **Repositories** | `app/repositories/**/*.rb` | New repos only for SQL, caching, clear boundary, or external I/O — document **why** |
| **RSpec** | `spec/**/*_spec.rb` | FactoryBot; request over controller specs; `env:` (or project pattern) for ENV; **`let` > `let!`** unless eager setup required; avoid heavy `before` when `let` is clearer |
| **Serializers** | `app/serializers/**/*.rb` | Explicit keys; no N+1; preload associations passed in |
| **Service objects** | `app/services/**/*.rb` | Single responsibility; `.call` / injected deps per **ruby-service-objects**; after extract, specs + caller still green |
| **SQL security** | Raw SQL anywhere | Bind params / `sanitize_sql_array`; whitelist dynamic `ORDER BY`; document **why** raw SQL |

## RSpec and `let_it_be` (test-prof)

- **Only use `let_it_be` if the project already depends on the `test-prof` gem** (check `Gemfile` / `Gemfile.lock`). Search before recommending it.
- If **`test-prof` is not present**, follow **rspec-best-practices** with **`let` as the default**; use **`let!` only when lazy evaluation would break the example** (e.g. callbacks, DB constraints that must exist before the action). Explicit setup is fine when clearer. Do **not** require adding `test-prof` / `let_it_be` unless the user asks to introduce it.

## HARD-GATE: Tests Gate Implementation

When this skill guides **new behavior**, the **tests gate** still applies:

```text
PRD → TASKS → TEST (write, run, fail) → IMPLEMENTATION → …
```

No implementation code before a failing test. See **rspec-best-practices** and **rails-agent-skills**.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Inventing style rules when a linter config exists | The project's configured linter is authoritative for style — do not add prose style rules |
| Assuming RuboCop when no config is checked | Detect first; note the absence to the user if no config is found |
| `let_it_be` in every project | Use only when `test-prof` is already a dependency |
| New `app/repositories` for every query | ActiveRecord is the default data boundary unless there's a documented reason |

## Output Style

Every Rails-code task lands these:

1. **Comments** follow the **Comments and tagged notes** section: no what-comments; tagged notes (`TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:`) on every assumption, deferred work, or business-rule constant; every tag carries actionable context (owner, ticket id, deadline).
2. **Logging** follows **Structured Logging** above — static first arg, hash second arg with `event:`, and a backtrace line on every error rescue.
3. **Linter detection noted** — when reviewing or refactoring, state which linter config you detected (or its absence) before any style claim.

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-stack-conventions** | Stack-specific: PostgreSQL, Hotwire, Tailwind |
| **ddd-rails-modeling** | When domain concepts and invariants need clearer Rails-first modeling choices |
| **ruby-service-objects** | Implementing or refining service objects |
| **rails-background-jobs** | Workers, queues, retries, idempotency |
| **rspec-best-practices** | Spec style, **tests gate** (red/green/refactor), request vs controller specs |
| **rails-security-review** | Controllers, params, IDOR, PII |
| **rails-code-review** | Full PR pass before merge |
