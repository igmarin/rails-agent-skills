# Upgrade Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when making a Rails engine stable across Rails and Ruby versions — must ensure every claimed version is in the CI matrix and passes, run bundle exec rake zeitwerk:check verifying that file paths match constant names exactly, verify gemspec dependency bounds match what CI actually tests, check initializer reloading safety using config.to_prepare, and check and state the status of optional integrations per version even if they are absent.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
