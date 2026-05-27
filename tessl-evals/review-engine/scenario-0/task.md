# Review Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when reviewing a Rails engine — confirm every row in the Quick Reference table: namespace isolation with `isolate_namespace`, no host constant leakage, configuration seams and adapters for host integration (no direct host model access), no side effects at load time (reload-safe hooks in `config.to_prepare`), migrations documented and copied via generator with no destructive/irreversible changes, dummy app present and used for integration tests exercising real mount; use severity tiers: High (production failures/host coupling), Medium (maintainability gaps), Low (style — surface after architecture); include verification commands like `grep -r "isolate_namespace" lib/` and `grep -R "remove_column\|drop_table\|change_column" db/migrate`.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
