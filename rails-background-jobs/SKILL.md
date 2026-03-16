---
name: rails-background-jobs
description: >
  Use when adding, configuring, or reviewing background jobs in Rails. Covers Active Job,
  Solid Queue (Rails 8 default), Sidekiq, recurring jobs, idempotency, retry strategies,
  discard_on, queue selection, and Mission Control Jobs. Applies to both Rails 7 and
  Rails 8 patterns.
---

# Rails Background Jobs

Use this skill when the task is to add, configure, or review background jobs in a Rails application.

**Core principle:** Design jobs for idempotency and safe retries. Prefer Active Job's unified API; choose backend based on Rails version and scale.

## HARD-GATE: Tests Gate Implementation

```
EVERY job MUST have its test written and validated BEFORE implementation.
  1. Write the job spec (idempotency, retry, error handling)
  2. Run the spec — verify it fails because the job does not exist yet
  3. ONLY THEN write the job class
See rspec-best-practices for the full gate cycle.
```

## Quick Reference

| Aspect | Rule |
|--------|------|
| Arguments | Pass IDs, not objects. Load in `perform`. |
| Idempotency | Check "already done?" before doing work |
| Retries | `retry_on` for transient, `discard_on` for permanent errors |
| Job size | One responsibility. Call services for complex logic. |
| Backend (Rails 8) | Solid Queue (database-backed, no Redis) |
| Backend (Rails 7) | Sidekiq + Redis for high throughput |
| Recurring | `config/recurring.yml` (Solid Queue) or cron/sidekiq-cron |

## HARD-GATE

```
EVERY job that performs side effects (charge, email, API call) MUST have
an idempotency check before the side effect.
```

## Rails 8 vs Rails 7

| Aspect | Rails 7 and earlier | Rails 8 |
|--------|---------------------|---------|
| Default | No default; set `queue_adapter` (often Sidekiq) | **Solid Queue** (database-backed) |
| Dev/test | `:async` or `:inline` | Same |
| Recurring | External (cron, sidekiq-cron) | `config/recurring.yml` |
| Dashboard | Third-party (Sidekiq Web) | **Mission Control Jobs** |

## Core Rules

1. **Pass serializable arguments:** Pass IDs, strings, numbers. Load records in `perform`.
2. **Design for idempotency:** Check state before doing work; use unique constraints or "already processed" checks.
3. **Use retries wisely:** `retry_on` for transient errors, `discard_on` for permanent failures.
4. **Keep jobs small:** One responsibility. Call services or POROs for complex logic.

## Examples

**Job with idempotency and retry:**

```ruby
class NotifyOrderShippedJob < ApplicationJob
  queue_as :default
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    order = Order.find(order_id)
    return if order.shipped_notification_sent?
    OrderMailer.shipped(order).deliver_now
    order.update!(shipped_notification_sent_at: Time.current)
  end
end
```

**Recurring job (Solid Queue):**

```yaml
# config/recurring.yml
production:
  nightly_cleanup:
    class: "NightlyCleanupJob"
    schedule: "0 2 * * *"
  hourly_sync:
    class: "HourlySyncJob"
    schedule: "every 1 hour"
    queue: low
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Passing ActiveRecord objects as arguments | Object may be deleted or stale by perform time. Pass IDs. |
| No idempotency check before side effects | Jobs run at-least-once. Double-charging, double-emailing. |
| `retry_on` without `attempts` limit | Infinite retries on persistent errors |
| Using `:inline` or `:async` in production | No persistence, no retry, no monitoring |
| Complex business logic in `perform` | Keep `perform` thin. Delegate to service objects. |
| Missing `discard_on` for permanent errors | Job retries forever on `RecordNotFound` |

## Red Flags

- Job performs non-idempotent side effects without "already done?" check
- Passing large or non-serializable objects as arguments
- Relying on "run once" semantics (at-least-once delivery can run a job twice)
- Using `:inline` or `:async` in production
- Recurring job defined only in code without `recurring.yml` or equivalent
- No error handling in `perform` — exceptions silently discarded or retried endlessly

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-migration-safety** | Solid Queue uses DB tables; add migrations safely |
| **rails-security-review** | Jobs receive serialized input; validate like any entry point |
| **ruby-service-objects** | Keep `perform` thin; call service objects for business logic |
| **rspec-best-practices** | Use `perform_enqueued_jobs` to test; test idempotency |
