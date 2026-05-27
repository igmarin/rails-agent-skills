# Implement Graphql Task

## Problem

A Rails team needs help with a task in this area:

Use when building GraphQL APIs in Rails with graphql-ruby — gates: SPEC (write failing spec with happy path+auth+validation error cases in `spec/graphql/` using `AppSchema.execute`, never HTTP dispatch)→TYPE (define arguments/return types, use `connection_type` for pagination, don't leak internal model names)→IMPLEMENT (dedicated resolver/mutation classes delegating to services)→N+1 CHECK (dataloader on every association load, prime dataloader in collection resolvers)→FINAL CHECK (verify every HARD-GATE item: field-level auth, mutations return `{result, errors}`, max_depth/max_complexity set, introspection disabled in production, description on every field, error handling with rescue blocks).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
