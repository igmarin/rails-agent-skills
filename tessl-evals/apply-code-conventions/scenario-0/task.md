# Apply Code Conventions Task

## Problem

A Rails team needs help with a task in this area:

Use when applying code conventions to Rails files — must run linter (detect .rubocop.yml/.standard.yml, note absence, and state which linter was detected and that style defers to it), apply area-specific rules per path with concrete per-path recommendations, verify tests gate (state the failing spec, run command, expected failure, minimal implementation step, and passing rerun) BEFORE new behavior, chain to specialised skills, only recommend let_it_be if test-prof already in Gemfile.lock (otherwise default to let, reach for "let!" only if lazy evaluation breaks example, do not introduce test-prof), and load extended files (assets/checklist.md, assets/snippets.md) only when needed.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
