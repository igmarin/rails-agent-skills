# Create Engine Installer Task

## Problem

A Rails team needs help with a task in this area:

Use when creating install generators or initializer installers for Rails engines — GENERATE: run the generator against a clean host app, VERIFY: check output files exist in correct host paths, RERUN: run the generator a second time confirming idempotent output (no duplicate routes/initializers, write a minimal rerun spec that must always pass), DOCUMENT: list what was generated vs what the user must do manually (mount route in host routes, run install, configure initializers), use idiomatic Rails Thor generator commands, copied migrations must be safe to run multiple times.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
