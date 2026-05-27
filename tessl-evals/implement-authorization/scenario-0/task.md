# Implement Authorization Task

## Problem

A Rails team needs help with a task in this area:

Implement and test authorization in Rails using Pundit or CanCanCan — ALWAYS test with multiple roles (admin/user/guest), NEVER rely on presence checks alone (check specific permissions), use policy objects never inline logic in controllers, Pundit uses `authorize @record` + `policy_scope(Model)`, CanCanCan uses `authorize!

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
