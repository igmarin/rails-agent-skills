# Extract Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when extracting existing Rails app code into a reusable engine — DO NOT extract and change behavior in the same step, preserve existing behavior first then refactor separately, move stable domain logic first (POROs/services/value objects), add adapters or configuration seams for host dependencies before moving controllers/routes/views, keep regression coverage green throughout each slice, one bounded slice per step with one coherent responsibility and minimal new public API.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
