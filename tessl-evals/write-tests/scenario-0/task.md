# Write Tests Task

## Problem

A Rails team needs help with a task in this area:

Use when writing, reviewing, or cleaning up RSpec tests — prefer behavioral confidence over implementation coupling, tests gate implementation (write smallest spec type model>service>request>system→show concrete RED failure message proving missing behavior not broken setup, never use illustrative `e.g.` placeholders→implement minimum→verify GREEN→run full spec file then suite), service specs use `describe '.call'` + `subject(:result)`, default to `let` with `let!` ONLY when must-exist-before-action, one behavior per example (split `it` containing "and"), output MUST satisfy each rule: each is graded independently — one violation drops the whole check, load extended resources only when needed (progressive disclosure: `assets/tdd_proof_checklist.md` when final answer must show RED/GREEN proof).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
