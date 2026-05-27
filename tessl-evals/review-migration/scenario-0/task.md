# Review Migration Task

## Problem

A Rails team needs help with a task in this area:

Use when reviewing production database migrations — DO NOT combine schema change and data backfill in one migration, DO NOT add NOT NULL before backfill completes, DO NOT drop columns before removing all code references, add nullable-first then backfill then enforce NOT NULL, add indexes with `algorithm: :concurrently` + `disable_ddl_transaction!` on large tables, check lock behavior for indexes/constraints/defaults/rewrites, use multi-step rollouts for renames/type changes/unique constraints, list risks first with explicit phased patterns per finding, mark patterns "Not applicable" with explanation when unused, backfill in batches outside migration transaction, deploy code tolerating both old and new schemas during transitions.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
