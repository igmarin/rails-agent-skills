# Version Api Task

## Problem

A Rails team needs help with a task in this area:

Implements REST API versioning in Rails with URL path or header-based strategies — ALWAYS maintain backward compatibility for at least one major version: new version controllers MUST inherit from the previous version's controller and override only changed actions, run `bundle exec rspec spec/requests/api/backward_compatibility_spec.rb` to confirm no regressions, NEVER remove endpoints without a deprecation period, emit Sunset and Deprecation headers via a Deprecatable concern, and version in the URL path (`/api/v1/`) or Accept header — never in the request body.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
