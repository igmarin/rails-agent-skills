# Code Review Task

## Problem

A Rails team needs help with a task in this area:

Reviews Rails pull requests — core principle: review early and often, self-review before PR, re-review after significant changes; use ONLY three severity labels: Critical (security/data loss/crash/Always Critical — blocks merge), Suggestion, Nice to have; Always Critical flags: `permit!`, `html_safe` on user content, business logic in controller actions, unparameterized SQL, destructive migrations; ground every finding in a real file:line from the diff — do not present a simulated PR review; follow Review Order: Configuration→Routing→Controllers→Views→Models→Associations→Queries→Migrations→Validations→I18n→Sessions→Security→Caching→Jobs→Tests; always include `Code review before merge` task.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
