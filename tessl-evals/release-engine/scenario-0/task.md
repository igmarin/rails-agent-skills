# Release Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when shipping a Rails engine gem — FIRST run full test suite (`bundle exec rspec`) and fix ALL failures, verify gemspec metadata and dependencies match tested Rails/Ruby versions, dry-run: `gem build *.gemspec && gem push --dry-run *.gem` and verify contents, generate CHANGELOG.md organized by category (added/changed/deprecated/removed/fixed), produce step-by-step upgrade notes with before/after code, set semantic version in `lib/<engine>/version.rb`, document deprecations with migration paths, load release assets conditionally and state which one informed the output.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
