# Upgrade Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when making a Rails engine stable across Rails and Ruby versions — every claimed version MUST be in the CI matrix and pass (not just main), run `bundle exec rake zeitwerk:check` to verify file paths match constant names, configure Zeitwerk autoloading with explicit loader, update gemspec dependency bounds matching what CI actually tests (`>= 7.0, < 8.0`), replace `Rails.version` branching with feature detection (`defined?`/`respond_to?` checks), audit deprecated API usage, verify reload safety: check initializer behavior across boot and reload using `config.to_prepare` for reload-sensitive hooks, check optional integrations (jobs/mailers/assets/routes/generators/dummy-app mounts) per version even if absent.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
