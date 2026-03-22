---
name: rails-bug-triage
description: >
  Use when investigating a bug in a Ruby on Rails codebase and you need to turn
  the report into a reproducible failing spec and fix plan. Covers reproduction,
  scope narrowing, boundary selection, and TDD-first handoff.
---

# Rails Bug Triage

Use this skill when a bug report exists but the right reproduction path and fix sequence are not yet clear.

**Core principle:** Do not guess at fixes. Reproduce the bug, choose the right failing spec, then plan the smallest safe repair.

## Quick Reference

| Step | Goal |
|------|------|
| Reproduce | Confirm the bug is real and current |
| Localize | Find the layer where the failure is observed |
| Choose spec | Pick the highest-value failing spec |
| Plan fix | Define the smallest repair path |

## HARD-GATE

```text
DO NOT propose a fix before the bug is reproduced or a failing spec is identified.
DO NOT accept "it probably lives in X" as evidence.
ALWAYS hand off to a failing spec before implementation begins.
```

## When to Use

- The user reports a bug and wants help investigating it.
- A failing behavior is described, but the responsible Rails layer is unknown.
- You need to convert a bug report into a TDD-ready fix plan.
- **Next step:** Chain to `rails-tdd-slices` to choose the first spec, then `rspec-best-practices` and the implementation skill for the affected area.

## Process

1. **Capture the report:** Restate the expected behavior, actual behavior, and reproduction steps.
2. **Bound the scope:** Identify whether the issue appears in request handling, domain logic, jobs, engine integration, or an external dependency.
3. **Gather current evidence:** Logs, error messages, edge-case inputs, recent changes, or missing guards.
4. **Choose the first failing spec:** Pick the boundary where the bug is visible to users or operators.
5. **Define the smallest fix path:** Name the likely files and the narrowest behavior change that should make the spec pass.
6. **Hand off:** Continue through `rails-tdd-slices` -> `rspec-best-practices` -> implementation skill.

## Triage Output

Return findings in this shape:

1. **Observed behavior**
2. **Expected behavior**
3. **Likely boundary**
4. **First failing spec to add**
5. **Smallest safe fix path**
6. **Follow-up skills**

## Boundary Guide

| Bug shape | Likely first spec |
|-----------|-------------------|
| Wrong status code, params handling, JSON payload | Request spec |
| Invalid state transition, validation, calculation | Model or service spec |
| Async side effect missing or duplicated | Job spec |
| Engine routing/install/generator regression | Engine spec |
| Third-party mapping/parsing issue | Integration or client-layer spec |

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Jumping straight to the suspected fix | Suspicion is not proof; reproduce first |
| Using a unit spec when the bug is visible at request level | Start where the failure is actually observed |
| Bundling reproduction, refactor, and new features together | Fix the bug in the smallest safe slice |
| Treating flaky evidence as a green light to patch blindly | Stabilize reproduction before changing code |

## Red Flags

- No one can state exact expected vs actual behavior
- The first spec does not reproduce the reported issue
- The proposed fix touches unrelated layers immediately
- The explanation relies on "probably", "maybe", or "should"

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-tdd-slices** | To choose the strongest first failing spec for the bug |
| **rspec-best-practices** | To run the TDD loop correctly after the spec is chosen |
| **refactor-safely** | When the bug sits inside a risky refactor area and behavior must be preserved first |
| **rails-code-review** | To review the final bug fix for regressions and missing coverage |
| **rails-architecture-review** | When the bug points to a deeper boundary or orchestration problem |
