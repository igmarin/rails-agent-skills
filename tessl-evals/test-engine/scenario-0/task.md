# Test Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when creating RSpec test coverage for Rails engines — EVERY engine MUST have a dummy app, verify dummy app boots before writing specs, add the smallest integration test proving mount and boot FIRST and verify it passes before continuing (if it fails check engine.rb initializer order and mount configuration rather than adding more specs on a broken foundation), use engine named route helpers, assert namespace scoping in routing specs, assert generator idempotency (safe to run twice), test configuration seams with at least one non-default value using `around` blocks, verify: dummy app exercises real host integration, routes tested through engine namespace, configurable seams covered with non-default case, generators safe to run twice.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
