# Optimize Performance Task

## Problem

A Rails team needs help with a task in this area:

Use when optimizing Rails performance — must follow a strict workflow where the report order matches the work order (measure baseline, identify bottleneck, write and run failing RED regression spec asserting query count using db-query-matchers, apply fix, verify spec is GREEN, check with EXPLAIN ANALYZE in rails dbconsole, and report quantified improvements), and write the regression spec before applying any optimization.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
