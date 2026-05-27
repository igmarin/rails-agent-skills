# Plan Tests Task

## Problem

A Rails team needs help with a task in this area:

Choose the best first failing RSpec spec for a Rails change — start at the highest-value boundary that proves behavior with least setup, pick one smallest strong slice: choose spec type that proves the behavior without dragging in unrelated layers (don't start at a lower-level unit if the real risk is request/job/engine/persistence), write exactly ONE failing example for the initial TDD gate (list additional cases as follow-up coverage), confirm failure is for missing behavior not broken setup, present the test design checkpoint: answer right behavior/correct boundary/edge cases represented/failure reason before handing off to write-tests.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
