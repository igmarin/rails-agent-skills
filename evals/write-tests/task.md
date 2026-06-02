# Write Tests Task

## Problem

A Rails team needs help with a task in this area:

Use when writing, reviewing, or configuring RSpec tests in Ruby on Rails — must execute the spec via `bundle exec rspec` and capture the actual test output (failure message or stack trace) rather than describing expected behavior, prefer behavioral confidence over implementation coupling, pick the smallest spec type exercising the behavior (model > service > request > system), mirror the file paths of the source, use # frozen_string_literal: true, define subject(:result) for service specs, and consult `assets/tdd_proof_checklist.md` when the task involves new behavior.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
