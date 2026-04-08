---
name: rails-background-jobs
description: >
  Use when adding or reviewing background jobs in Rails. Configures Active Job
  workers, implements idempotency checks, sets up retry/discard strategies,
  selects Solid Queue (Rails 8+) or Sidekiq based on scale, and defines recurring
  jobs via recurring.yml or sidekiq-cron. Trigger words: background job, Active Job,
  Solid Queue, Sidekiq, idempotency, retry, discard, recurring job, queue.
---

# Rails Background Jobs

Use this skill when the task is to add, configure, or review background jobs in a Rails application.

**Core principle:** Design jobs for idempotency and safe retries. Prefer Active Job's unified API; choose backend based on Rails version and scale.

## HARD-GATE

```
EVERY job MUST have its test written and validated BEFORE implementation.
  1. Write the job spec (idempotency, retry, error handling)
  2. Run the spec — verify it fails because the job does not exist yet
  3. ONLY THEN write the job class

EVERY job that performs a side effect (charge, email, API call) MUST have
an idempotency check BEFORE the side effect.

After implementation: run full suite, confirm job appears in queue dashboard,
verify idempotency by enqueueing twice and checking the second run is a no-op.
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

## Rails 8 vs Rails 7

| Aspect | Rails 7 and earlier | Rails 8 |
|--------|---------------------|---------|
| Default | No default; set `queue_adapter` (often Sidekiq) | **Solid Queue** (database-backed) |
| Dev/test | `:async` or `:inline` | Same |
| Recurring | External (cron, sidekiq-cron) | `config/recurring.yml` |
| Dashboard | Third-party (Sidekiq Web) | **Mission Control Jobs** |

See [BACKENDS.md](./BACKENDS.md) for install steps, configuration, and dashboard setup for both Solid Queue and Sidekiq.

## Examples

**Pass IDs, not objects:**

```ruby
# Bad — object may be stale or deleted by perform time
SomeJob.perform_later(@order)

# Good — reload fresh inside perform
SomeJob.perform_later(@order.id)
```

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

## Pitfalls

| Problem | Correct approach |
|---------|-----------------|
| Passing ActiveRecord objects as arguments | Pass IDs — objects may be deleted or stale by perform time |
| No idempotency check before side effects | Jobs run at-least-once; double-charging and double-emailing result |
| `retry_on` without `attempts` limit | Infinite retries on persistent errors |
| Missing `discard_on` for permanent errors | Job retries forever on `RecordNotFound` |
| Complex business logic in `perform` | Keep `perform` thin — delegate to service objects |
| Using `:inline` or `:async` in production | No persistence, no retry, no monitoring |
| Recurring job defined only in code | Use `recurring.yml` or equivalent for visibility and recoverability |

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-migration-safety** | Solid Queue uses DB tables; add migrations safely |
| **rails-security-review** | Jobs receive serialized input; validate like any entry point |
| **rspec-best-practices** | TDD gate: write job spec before implementation; use `perform_enqueued_jobs` |
| **ruby-service-objects** | Keep `perform` thin; call service objects for business logic |
