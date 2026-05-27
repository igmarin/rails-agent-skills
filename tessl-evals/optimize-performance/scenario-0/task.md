# Optimize Performance Task

## Problem

A Rails team needs help with a task in this area:

Optimizes Rails performance with a mandated workflow — measure baseline FIRST, write a regression spec asserting query count with a `make_database_queries` matcher and show it FAILING BEFORE any fix, apply the minimal optimization (eager load/index/cache), re-run the spec to confirm PASSES at the new count, then verify with EXPLAIN ANALYZE confirming plan change (Seq Scan→Index Scan), report output order MUST strictly match work order: measure→identify bottleneck with Bullet or rack-mini-profiler→RED regression spec→fix→GREEN regression spec→EXPLAIN ANALYZE→quantified improvement (queries: N→M, p95: Xms→Yms).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
