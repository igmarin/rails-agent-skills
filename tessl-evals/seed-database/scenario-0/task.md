# Seed Database Task

## Problem

A Rails team needs help with a task in this area:

Use when managing development and test data in Rails — must write idempotent seeds using find_or_create_by!, run seeds with rails db:seed or rails db:setup, verify data by opening rails console and spot-checking records, use ENV variables or SecureRandom for non-production data without committing secrets in code, and use rails credentials:edit for production secrets.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
