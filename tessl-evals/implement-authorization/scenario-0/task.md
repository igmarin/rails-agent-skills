# Implement Authorization Task

## Problem

A Rails team needs help with a task in this area:

Use when implementing or testing authorization in Rails using Pundit or CanCanCan — must always verify authorization by attempting an unauthorized action in the browser or console and confirming it raises Pundit::NotAuthorizedError or CanCan::AccessDenied as expected, use policy objects rather than inline controller logic, test with multiple roles, and check specific permissions instead of presence checks alone.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
