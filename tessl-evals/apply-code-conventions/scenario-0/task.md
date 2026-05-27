# Apply Code Conventions Task

## Problem

A Rails team needs help with a task in this area:

Daily checklist for clean Rails code — Detect→run→defer: run linter (detect `.rubocop.yml`/`.standard.yml`→run→note absence), never invent style rules, style/formatting defers to detected config, apply area-specific rules per path (models→eager load/pluck, controllers→strong params/thin, services→.call, jobs→idempotency/retries, specs→let>let!), verify tests gate BEFORE new behavior (RED→implement→GREEN), enforce structured logging: every Rails.logger call MUST use static string first arg + hash with event: key second arg + no interpolation, enforce comment discipline: TODO/FIXME tags MUST carry actionable context, chain to specialised skills, only recommend let_it_be if test-prof already in Gemfile.lock, progressive disclosure: load extended resources only when needed.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
