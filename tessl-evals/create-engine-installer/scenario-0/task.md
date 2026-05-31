# Create Engine Installer Task

## Problem

A Rails team needs help with a task in this area:

Use when creating install generators or initializer installers for Rails engines — must use idiomatic Rails Thor generator commands, and follow the strict workflow: GENERATE (run generator against clean host app), VERIFY (check output files exist in correct host paths), RERUN (run a second time confirming idempotent output), TEST (write a minimal rerun spec that must always pass), and DOCUMENT (list what was generated versus what the user must do manually).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
