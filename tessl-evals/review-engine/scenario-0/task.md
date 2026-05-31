# Review Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when reviewing a Rails engine — must inspect namespace isolation (isolate_namespace), verify configuration seams and check host-app integration (flagging host constant references), verify initialization reload safety (use config.to_prepare, flag load-time global mutations), check that migrations are copied via generator without destructive/irreversible changes, confirm spec/dummy exists and is used for integration specs, and summarize findings by severity flagging High findings first.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
