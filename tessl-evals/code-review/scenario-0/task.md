# Code Review Task

## Problem

A Rails team needs help with a task in this area:

Use when reviewing Rails pull requests and diffs — must state "Review early, review often.Self-review before PR.Re-review after significant changes." as the review principle, ground every finding from the actual diff in a real file:line, use ONLY three severity labels (Critical, Suggestion, Nice to have) where Critical includes security/data loss/crash and Always Critical flags (permit!, html_safe on user content, business logic in controllers, unparameterized SQL, destructive migrations), and always include a "Code review before merge" task or task-list line.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
