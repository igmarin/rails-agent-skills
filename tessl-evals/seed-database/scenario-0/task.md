# Seed Database Task

## Problem

A Rails team needs help with a task in this area:

Manage development and test data in Rails — NEVER commit production data to seeds, ALWAYS make seeds idempotent with `find_or_create_by!` so re-runs are safe, run seeds with `rails db:seed` (or `rails db:setup` for fresh database), verify data by opening `rails console` and spot-checking expected records exist with correct attributes, NEVER hardcode credentials: use `ENV.fetch('KEY')` or `SecureRandom.hex(16)` for non-production, use `rails credentials:edit` for production secrets never commit them in code, use FactoryBot for test-specific scenarios in `spec/factories/`, static reference data in `db/seeds.rb`.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
