---
name: rspec-best-practices
description: >
  Use when writing, reviewing, or cleaning up RSpec tests for Ruby and Rails codebases.
  Covers spec type selection, factory design, flaky test fixes, shared examples, deterministic
  assertions, and test-driven development discipline. Also applies when choosing between
  model, request, system, and job specs.
---

# RSpec Best Practices

Use this skill when the task is to write, review, or clean up RSpec tests.

**Core principle:** Prefer behavioral confidence over implementation coupling. Good specs are readable, deterministic, and cheap to maintain.

## Quick Reference

| Aspect | Rule |
|--------|------|
| Spec type | Request > controller; model for domain; system only for critical E2E |
| Assertions | Test behavior, not implementation |
| Factories | Minimal — only attributes needed for the test |
| Mocking | Stub external boundaries, not internal code |
| Isolation | Each example independent; no shared mutable state |
| Naming | `describe` for class/method, `context` for scenario |
| TDD | Write test first, watch it fail, then implement |

## HARD-GATE: Tests Gate Implementation

```
THE WORKFLOW IS: PRD → TASKS → TESTS → IMPLEMENTATION

Tests are a GATE between planning and code.
NO implementation code may be written until:
  1. The test EXISTS
  2. The test has been RUN
  3. The test FAILS for the correct reason (feature missing, not typo)

ONLY AFTER the test is validated can implementation begin.
```

Write code before the test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't write "just a little" implementation first
- Delete means delete

**The gate cycle for each behavior:**
1. **Write test:** One minimal test showing what the behavior should do
2. **Run test:** Execute it — this is mandatory, not optional
3. **Validate failure:** Confirm it fails because the feature is missing (not a typo or import error)
4. **GATE PASSED** — you may now write implementation code
5. **Write minimal code:** Simplest implementation to make the test pass
6. **Run test again:** Confirm it passes and no other tests break
7. **Refactor:** Clean up (remove duplication, improve names, extract helpers) — tests must stay green
8. **Next behavior:** Return to step 1

## Core Rules

- Test observable behavior, not private method structure.
- Use the highest-value spec type for the behavior under test.
- Prefer request specs over controller specs for Rails endpoints.
- Keep factories minimal and explicit.
- Stub external boundaries, not internal code paths, unless isolation is the goal.
- Avoid time, randomness, and global state leaks between examples.

## Spec Selection

- **model or unit specs** for cohesive domain objects
- **request specs** for controller and API behavior
- **system specs** only for critical end-to-end UI flows
- **job specs** for enqueue and execution behavior
- **feature-specific integration specs** when wiring matters more than isolation

**Monolith vs engine:** For a normal Rails app, this skill applies as-is. When the project is a **Rails engine**, use **rails-engine-testing** for dummy-app setup, engine request/routing/generator specs, and host integration; keep using this skill for general RSpec style and structure.

## Coverage

- Cover typical cases and edge cases: invalid inputs, errors, boundary conditions.
- Consider all relevant scenarios for each method or behavior.

## Readability and Clarity

- Use clear, descriptive names for `describe`, `context`, and `it` blocks.
- Prefer **expect** syntax for assertions.
- Keep test code concise; avoid unnecessary complexity or duplication.

## Structure

- **describe** for the class, module, or behavior; **context** for scenarios (e.g. "when valid", "when user is missing").
- Use **subject** for the object under test when it reduces repetition.
- Mirror source paths under `spec/` (e.g. `app/models/user.rb` -> `spec/models/user_spec.rb`).

## Test Data

- Use **let** and **let!** for test data; keep setup minimal and necessary.
- Prefer **factories** (e.g. FactoryBot) over fixtures.
- Prefer `let` over `let!` when the value isn't needed for setup (aligns with RuboCop-RSpec style).

## Independence and Isolation

- Each example should be independent; avoid shared mutable state between tests.
- Use **mocks** for external services (APIs, etc.) and **stubs** for predefined return values.
- Isolate the unit under test, but avoid over-mocking; prefer testing real behavior when practical.

## Avoid Repetition

- Use **shared_examples** / **shared_context** for behavior repeated across contexts.
- Extract repeated setup or expectations into helpers or custom matchers when it improves clarity.

## Verification Checklist

Before marking test work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? You skipped TDD. Start over.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Already manually tested" | Ad-hoc is not systematic. No record, can't re-run. |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| Testing mock behavior instead of real behavior | Mock returns what you told it to. Test the real thing. |
| Brittle assertions on internal calls | Assert outcomes, not implementation details. |
| Excessive `let!` and nested contexts | Prefer `let` when value isn't needed for setup. Keep nesting shallow. |
| Factories creating large graphs by default | Minimal factories — only what the test needs. |
| Time-sensitive tests without clock control | Use `travel_to` for time-dependent behavior. |
| "TDD is dogmatic, being pragmatic means adapting" | TDD IS pragmatic. Finds bugs before commit, enables refactoring. |

## Red Flags

- Code written before the test
- Test passes immediately (you're testing existing behavior, not new behavior)
- Can't explain why the test failed
- `let!` used everywhere instead of `let`
- Factories creating 10+ associated records
- Tests that break when implementation changes but behavior stays correct
- "I'll add tests later" (later never comes)
- Test name contains "and" (testing two behaviors in one example)
- Rationalizing "just this once" for skipping TDD

## Review Checklist

- Is the spec type appropriate for the risk?
- Would the test still pass if the implementation changed but behavior stayed correct?
- Are setup and assertions easy to read?
- Is the factory data minimal?
- Is flakiness risk controlled?

## Output Style

When asked to improve tests:

1. Identify the most important missing behavioral coverage.
2. Reduce brittleness before adding more assertions.
3. Prefer simpler setup over clever RSpec abstractions.

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-service-testing** | For service object specs (`spec/services/`) — instance_double, hash factories, shared_examples |
| **rails-engine-testing** | For engine specs — dummy app, routing specs, generator specs |
| **rails-code-review** | When reviewing test quality as part of code review |
| **refactor-safely** | When adding characterization tests before refactoring |
