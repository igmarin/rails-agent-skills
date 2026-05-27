# Apply Stack Conventions Task

## Problem

A Rails team needs help with a task in this area:

Use when writing new Rails code for a PostgreSQL + Hotwire + Tailwind CSS stack — ALL new code MUST have test written BEFORE implementation (write spec file content not just path: `bundle exec rspec spec/[path]_spec.rb`→verify RED failure with observed output→implement→verify GREEN with observed result, use Observed RED/GREEN labels as proof, never use illustrative `e.g.` comments as evidence), output MUST include tests-first proof before implementation with actual spec code + exact command + Observed RED/GREEN output per layer, layers testable in isolation (model/query→service→controller/request→view/Turbo→Stimulus→Tailwind, Layer isolation section with focused spec per layer, "not applicable" for unchanged), apply Devise+Pundit on access-controlled resources.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
