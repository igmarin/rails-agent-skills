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
| Comments | Explain **why**, not **what**; use tagged notes with context |
| Logging | First arg string, second arg hash; no string interpolation; `event:` when useful for dashboards |
| Deep stacks | Chain **rails-stack-conventions** → domain skills (services, jobs, RSpec) |

## Design Principles

| Principle | Apply as |
|-----------|----------|
| **DRY** | Extract when duplication carries real maintenance cost; avoid premature abstraction |
| **YAGNI** | Build for current requirements; defer generalization until a second real use case |
| **PORO** | Use plain Ruby objects when they clarify responsibility; do not wrap everything in a "pattern" |
| **Convention over Configuration** | Prefer Rails defaults and file placement; document only intentional deviations |
| **KISS** | Simplest design that meets acceptance criteria and **tests gate** |

## Comments

- Comment the **why**, not the **what** (the code shows what).
- Use tags with **enough context** that a future reader can act: `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `OPTIMIZE:`.

```ruby
# BAD — restates the method name, adds zero value
# Finds the user by email
def find_by_email(email)
  User.find_by(email: email)
end

# GOOD — explains intent and tradeoff
# Uses find_by (not find_by!) so callers can handle nil explicitly;
# downstream auth layer is responsible for raising on missing user.
def find_by_email(email)
  User.find_by(email: email)
end
```

## Structured Logging

- **First argument:** static string (message key or human-readable template without interpolated values).
- **Second argument:** hash with structured fields (`user_id:`, `order_id:`, etc.).
- **Do not** build the primary message with string interpolation; put dynamic data in the hash.
- Include **`event:`** (or equivalent) for error or ops dashboards when the team uses tagged events.

```ruby
# BAD — interpolation loses structure; cannot filter by user_id in log aggregators
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
| **ActiveRecord performance** | `app/models/**/*.rb` | Eager load in loops; prefer `pluck`, `exists?`, `find_each` over loading full records. Verify N+1 fixes with the `bullet` gem or query logs after applying |
| **Background jobs** | `app/workers/**/*.rb`, `app/jobs/**/*.rb` | Clear worker/job structure, queue selection, idempotency, structured error logging (see **rails-background-jobs** for Active Job / Solid Queue / Sidekiq depth) |
| **Error handling** | `app/services/**/*.rb`, `app/lib/**/*.rb`, `app/exceptions/**/*.rb` | Domain exceptions with prefixed codes where the team uses them; `rescue_from` or base handlers for API layers as conventions dictate |
| **Logging / tracing** | `app/services/**/*.rb`, `app/workers/**/*.rb`, `app/jobs/**/*.rb`, `app/controllers/**/*.rb`, `app/repositories/**/*.rb` | Structured logging; add APM trace spans and tags (e.g. Datadog) for key operations when the stack includes them |
| **Controllers** | `app/controllers/**/*_controller.rb` | Strong params; thin actions delegating to services; watch IDOR and PII exposure (see **rails-security-review**) |
| **Repositories** | `app/repositories/**/*.rb` | Avoid new repository objects unless raw SQL, caching, a clear domain boundary, or external service isolation justifies it; document **why** in code |
| **RSpec** | `spec/**/*_spec.rb` | FactoryBot; prefer request specs over controller specs; use `env:` metadata (or project equivalent) for ENV changes; **prefer `let` over `let!`** unless the example requires eager setup; avoid `before` for data when `let` or inline factories are clearer |
| **Serializers** | `app/serializers/**/*.rb` | If using ActiveModel::Serializer (or similar): explicit `key:` mapping; avoid N+1; pass preloaded associations via options when applicable |
| **Service objects** | `app/services/**/*.rb` | Single responsibility; class methods for stateless entry points, instance API when dependencies are injected; public methods first; bang (`!`) / predicate (`?`) naming as appropriate (see **ruby-service-objects**) |
| **SQL security** | Raw SQL anywhere | No string interpolation of user input; use `sanitize_sql_array` / bound parameters; whitelist dynamic ORDER BY; document **why** raw SQL is needed |

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
