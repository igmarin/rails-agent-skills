# Implement Background Job Task

## Problem

A Rails team needs help with a task in this area:

Use when adding or reviewing background jobs in Rails — must write the job spec covering idempotency, retry, and error handling and verify it FAILS before implementation, ensure the perform method only loads the record from the passed ID, guards for no-op, and delegates to a service, and run the full test suite to verify success.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
