---
name: implement-background-job
license: MIT
description: >
  Use when adding or reviewing background jobs in Rails — EVERY job MUST have its test written and validated BEFORE implementation (write job spec covering idempotency/retry/error handling→run and confirm it fails→implement→run full suite), `perform` receives IDs loads the record guards for no-op and delegates to a service, configure Active Job with Solid Queue (Rails 8+ default) or Sidekiq at scale, implement idempotency checks with database uniqueness constraints or state field locks, set up `retry_on`/`discard_on` strategies, define recurring jobs via `config/recurring.yml` or sidekiq-cron, test with `queue_adapter = :test` + `have_enqueued_job` matchers. Trigger words: background job, Active Job, Solid Queue, Sidekiq, idempotency, retry, discard, recurring job, queue.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Implement Background Job

Use this skill when the task is to add, configure, or review background jobs in a Rails application.

## HARD-GATE

```text
EVERY job MUST have its test written and validated BEFORE implementation.
  1. Write the job spec (idempotency, retry, error handling)
  2. Run the spec — verify the job does not yet exhibit the intended behavior
  3. ONLY THEN write the job class

EVERY job that performs a side effect (charge, email, API call) MUST have
an idempotency check BEFORE the side effect.

EVERY perform method should do only three things:
  1. Load the record from the passed ID
  2. Guard for idempotency / permanent no-op conditions
  3. Delegate the side effect or orchestration to a service object

If perform needs more than that, extract a service.
```

## Core Rules

| Aspect | Rule |
|--------|------|
| Arguments | Pass IDs, not objects. Load in `perform`. |
| Idempotency | Check "already done?" before doing work |
| Retries | `retry_on` (explicit `attempts:`) for transient; `discard_on` for permanent errors |
| Backend (Rails 8) | Solid Queue (database-backed, no Redis) |
| Backend (Rails 7) | Sidekiq + Redis for high throughput |
| Recurring | `config/recurring.yml` (Solid Queue) or cron/sidekiq-cron |
| Anti-patterns | No ActiveRecord objects as args; no `:inline`/`:async` in production; no business logic in `perform` |

## Core Process

1. Write the job spec first — idempotency, retry, and error handling.
2. Run the spec to confirm it fails.
3. Write the job class: `perform` receives IDs, loads the record, guards for no-op, delegates to a service.
4. Add `retry_on` with explicit `attempts:` limit and `discard_on` for at least one permanent error.
5. Run the full test suite.
6. Enqueue or perform the job twice — confirm the second run is a no-op.
7. For recurring jobs, define them in `config/recurring.yml` (Rails 8) or the chosen scheduler config.

## Extended Resources

**Rails 8 vs Rails 7**
| Aspect | Rails 7 and earlier | Rails 8 |
|--------|---------------------|---------|
| Default | No default; set `queue_adapter` (often Sidekiq) | **Solid Queue** (database-backed) |
| Dev/test | `:async` or `:inline` | Same |
| Recurring | External (cron, sidekiq-cron) | `config/recurring.yml` |
| Dashboard | Third-party (Sidekiq Web) | **Mission Control Jobs** |

**Examples**

**Thin job with idempotency and retry:**
```ruby
class SendInvoiceReminderJob < ApplicationJob
  queue_as :default
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    return if invoice.reminder_sent_at?

    InvoiceReminders::Send.call(invoice:)
  end
end
```

**Service owns the side effect and state update:**
```ruby
module InvoiceReminders
  class Send
    def self.call(invoice:)
      InvoiceMailer.overdue(invoice).deliver_now
      invoice.update!(reminder_sent_at: Time.current)
    end
  end
end
```

- [BACKENDS.md](./BACKENDS.md)
- [assets/job_patterns.md](assets/job_patterns.md)
- [assets/retry_examples.md](assets/retry_examples.md)

## Output Checklist

- [ ] Backend decision stated (Rails version/scale → Solid Queue or Sidekiq)
- [ ] Job spec shown first; command run; confirms failure before implementation
- [ ] `perform` receives IDs, loads record, guards idempotency, delegates to service
- [ ] `retry_on` with `attempts:` limit and `discard_on` for permanent error
- [ ] Double-run verification confirms second run is a no-op
- [ ] Recurring job (if any) defined in `config/recurring.yml` or scheduler config
- [ ] If ops docs requested: record backend, retry, recurring schedule, and idempotency decisions in `process_log.md`

## Integration

| Skill | When to chain |
|-------|---------------|
| **review-migration** | Solid Queue uses DB tables; add migrations safely |
| **security-check** | Jobs receive serialized input; validate like any entry point |
| **write-tests** | TDD gate: write job spec before implementation; use `perform_enqueued_jobs` |
| **create-service-object** | Keep `perform` thin; call service objects for business logic |
