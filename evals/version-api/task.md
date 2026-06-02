# Version Api Task

## Problem

A Rails team needs help with a task in this area:

Use when implementing REST API versioning strategies in Rails — must maintain backward compatibility by inheriting new version controllers from the previous version's controller overriding only changed actions, and run compatibility specs via bundle exec rspec spec/requests/api/backward_compatibility_spec.rb to confirm no regressions before merging.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
