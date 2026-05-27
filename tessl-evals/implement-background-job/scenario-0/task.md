# Implement Background Job Task

## Problem

A Rails team needs help with a task in this area:

Use when adding or reviewing background jobs in Rails — EVERY job MUST have its test written and validated BEFORE implementation (write job spec covering idempotency/retry/error handling→run and confirm it fails→implement→run full suite), `perform` receives IDs loads the record guards for no-op and delegates to a service, configure Active Job with Solid Queue (Rails 8+ default) or Sidekiq at scale, implement idempotency checks with database uniqueness constraints or state field locks, set up `retry_on`/`discard_on` strategies, define recurring jobs via `config/recurring.yml` or sidekiq-cron, test with `queue_adapter = :test` + `have_enqueued_job` matchers.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
