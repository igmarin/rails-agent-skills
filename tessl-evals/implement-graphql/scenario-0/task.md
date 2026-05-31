# Implement Graphql Task

## Problem

A Rails team needs help with a task in this area:

Use when building or reviewing GraphQL APIs in Rails with graphql-ruby — must follow the TDD gates by writing a failing spec in spec/graphql/ using AppSchema.execute rather than HTTP controller dispatch, define arguments/return types without leaking internal model names (use connection_type for pagination), implement resolver/mutation classes that delegate to services, prevent N+1 queries by using and priming the dataloader on association loads, and ensure mutations return result and errors shapes on failure.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
