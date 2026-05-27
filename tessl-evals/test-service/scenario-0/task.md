# Test Service Task

## Problem

A Rails team needs help with a task in this area:

Use when writing RSpec tests for service objects in `spec/services/` — write spec FIRST and verify it fails for the right reason, use `subject(:service_call) { described_class.call(params) }` with `describe '.call'`, test the public contract not internal implementation, use `instance_double` for isolation and `create` for integration, cover happy path + error/edge cases + blank/invalid input, use `aggregate_failures` for multi-assertion tests, `change` matchers for state verification, `travel_to` for time-dependent logic, FactoryBot hash factories (`class: Hash` with `initialize_with`) for API responses.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
