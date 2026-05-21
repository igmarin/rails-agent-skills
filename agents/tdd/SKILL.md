---
name: tdd
license: MIT
description: >
  Orchestrates the full Rails test-driven development cycle: generates a failing spec first, implements minimal code to pass, refactors, then produces YARD documentation and a self-reviewed PR. Use when practicing test-driven development, red-green-refactor, TDD workflow, writing tests before code, adding tests first, or building a Rails feature where specs must gate implementation.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when practicing test-driven development or building Rails features where specs must gate implementation"
  phases: "Phase 1: Context & Test Design, Phase 2: Implementation, Phase 3: Iterate, Phase 4: Finish"
  hard_gates: "Test Feedback, Proposal Checkpoint, Implementation Verification, Quality Check"
  dependencies: "load-context, plan-tests, write-tests, write-yard-docs, code-review"
  keywords: rails, tdd, agent, feature, implementation, testing, orchestration
---
# TDD Agent

## Agent Phases

### Phase 1: Context & Test Design
1. **context/load-context**: Load schema, routes, and patterns.
2. **testing/plan-tests**: Choose the best first failing spec.
3. **testing/write-tests**: Write test and verify failure.

**HARD GATE — Test Feedback:**
- Test EXISTS and is RUN.
- FAILS for correct reason (e.g., `undefined method 'full_name'`).
- If FAIL is incorrect (syntax, config), return to `write-tests`.

### Phase 2: Implementation
1. **Proposal Checkpoint**: Propose implementation (e.g., "Concatenate first + last name").
2. **User Approval**: Wait for explicit confirmation.
3. **Minimal Implement**: Smallest change to pass test.
4. **Verify PASS**: `bundle exec rspec spec/path/to/spec.rb`.

*If test does not pass, fix minimal changes and re-verify.*

### Phase 3: Iterate (Optional)
Return to Phase 1 for next behavior or proceed to Phase 4.

### Phase 4: Finish
1. **Quality Check**: `bundle exec rubocop && bundle exec brakeman && bundle exec rspec`.
2. **patterns/write-yard-docs**: Document public Ruby API.
3. **code-quality/code-review**: Self-review PR diff.
4. **Open PR**: Feature complete.

## Documentation & Examples
See [assets/example.md](assets/example.md) for a complete end-to-end walkthrough.
