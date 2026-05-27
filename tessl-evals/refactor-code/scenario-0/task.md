# Refactor Code Task

## Problem

A Rails team needs help with a task in this area:

Use when changing structure without changing behavior — write characterization tests BEFORE touching any production file (must pass on current un-refactored code, if it fails stop and fix the test or behavior mismatch), NEVER mix behavior changes with structural refactors, identify exact inputs/outputs, keep public interfaces stable until callers migrate, ONE boundary per step, run verification after EVERY step plus full test suite at end, use ONLY Observed output for actual run output (NEVER substitute expected/required/planned output or "must produce 0 failures" as evidence), include stable behavior statement.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
