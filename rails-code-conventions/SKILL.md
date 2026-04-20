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

| Principle | Apply as |
|-----------|----------|
| **DRY** | Extract when duplication carries real maintenance cost; avoid premature abstraction |
| **YAGNI** | Build for current requirements; defer generalization until a second real use case |
| **PORO** | Use plain Ruby objects when they clarify responsibility; do not wrap everything in a "pattern" |
| **Convention over Configuration** | Prefer Rails defaults and file placement; document only intentional deviations |
| **KISS** | Simplest design that meets acceptance criteria and **tests gate** |

## Comments and tagged notes

Comment **why**, not **what**. **NEVER** write a comment that paraphrases the code (`# Finds the user by email`, `# Returns the total`, `# Loops through items`) — well-named identifiers already carry that information.

**Tagged notes are MANDATORY** whenever any of the following is present in the code under review or being authored:

- An assumption that may not hold forever (rate limits, magic numbers, business-rule constants like discount caps)
- A deliberate deferral (placeholder data source, simplified logic awaiting a real implementation)
- A known limitation, edge case, or risk the reader needs to see
- A decision that has a non-obvious tradeoff (chose `find_by` over `find_by!`, swallowed an exception class on purpose)

Use **`TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:`** — uppercase, trailing colon, then **actionable context**: owner, ticket id, decision deadline, or the next concrete step. Never a naked tag (`# TODO: fix this`) — that fails review.

```ruby
# BAD — narrates the code
# Finds the user by email
def find_by_email(email)
  User.find_by(email: email)
end

# GOOD — why `find_by` vs `find_by!` matters for callers
# Uses find_by (not find_by!) so callers handle nil; auth layer may raise.
def find_by_email(email)
  User.find_by(email: email)
end

# BAD — unusable
# TODO: fix this
rate = TIER_RATES.fetch(tier, 0.0)

# GOOD — next step + dependency visible
# TODO: replace TIER_RATES with DB-backed lookup (PRI-482; blocked on legal).
rate = TIER_RATES.fetch(tier, 0.0)
```

## Structured Logging

- **First argument:** static string (message key or human-readable template without interpolated values).
- **Second argument:** hash with structured fields (`user_id:`, `order_id:`, etc.).
- **Do not** build the primary message with string interpolation; put dynamic data in the hash.
- **Always include `event:`** — the primary grouping dimension in log aggregators (Datadog, Loki, Kibana). Use dot-namespaced values like `"order.processing_started"`. No alternate key names (`:type`, `:action`, `:name`).

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

When asked to write, review, comment, or document Rails code, your output MUST satisfy each item below. They are graded independently — partial coverage drops the score.

1. **No what-comments** — never paraphrase code in a comment. If a comment would just restate the method or line, delete it. Names carry the *what*; comments carry the *why*.
2. **Tagged notes present** — any code that contains an assumption, deferred work, design tradeoff, business-rule constant, or known limitation MUST carry at least one tagged note (`TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:`). When commenting an existing file in this domain, surface at least one tagged note for the assumptions you find — silence is failure.
3. **Tagged notes are actionable** — every tag is followed by a colon and concrete next-step context (owner, ticket id, deadline, or the precise decision pending). `# TODO: fix later` is rejected.
4. **Why-comments on business rules** — constants like discount caps, rate limits, retry counts, magic numbers MUST have a comment explaining the *reason* for the value (regulation, contract, observed behavior).
5. **Structured logging** — every `Rails.logger.{info,warn,error}` call uses a static first argument and a hash second argument that includes an `event:` key. No interpolation in the message.
6. **Error logging includes backtrace** — every `rescue StandardError => e` block (or any `rescue` for an unexpected error) MUST log BOTH `e.message` AND `e.backtrace.first(5).join("\n")` (or the full backtrace) on `Rails.logger.error`. Logging only the message is graded as missing.
7. **Linter detection noted** — if asked to review or refactor, state which linter config you detected (or note its absence) before making style claims.

```ruby
# Required shape for every unexpected-error rescue block
rescue StandardError => e
  Rails.logger.error("payment.unexpected_error", event: "payment.unexpected_error", error: e.message)
  Rails.logger.error(e.backtrace.first(5).join("\n"))
  { success: false, response: { error: { message: PAYMENT_FAILED } } }
end
```

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
