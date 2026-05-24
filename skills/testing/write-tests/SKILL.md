---
name: write-tests
license: MIT
description: >
  Use when writing, reviewing, or cleaning up RSpec tests for Ruby and Rails codebases.
  Covers spec type selection, factory design, flaky test fixes, shared examples, deterministic
  assertions, test-driven development discipline, and choosing the best first failing
  spec for Rails changes. Also applies when choosing between model, request, system,
  and job specs. Trigger words: write spec, rspec, test-driven development, testing.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Write Tests

Use this skill when the task is to write, review, or clean up RSpec tests.

**Core principle:** Prefer behavioral confidence over implementation coupling. Good specs are readable, deterministic, and cheap to maintain.

## Quick Reference

| Aspect | Rule |
|--------|------|
| Spec types | Model: domain logic; Request: HTTP endpoints (prefer over controller); Job: background processing; Service/PORO: no Rails helpers; System: critical E2E only (slow) |
| Assertions | Test behavior, not implementation |
| Factories | Minimal — only attributes needed; use traits for optional states; prefer `build`/`build_stubbed` over `create` |
| Mocking | Stub external boundaries, not internal code |
| Isolation | Each example independent; no shared mutable state |
| Naming | `describe` for class/method, `context` for scenario |
| Service specs | **Required:** `describe '.call'` and `subject(:result)` for the primary invocation |
| `let` vs `let!` | Default to `let`; `let!` ONLY when object must exist before example runs |
| External service mocking | `allow(ServiceClass).to receive(:method)` — **not** `instance_double`; `instance_double` only for injected collaborators |
| Example names | Present tense: `it 'returns the user'`; **NEVER** `it 'should ...'`; **NEVER** contains `and` — see [One Behavior Per Example](#one-behavior-per-example) |
| `aggregate_failures` | Use when asserting multiple related items in one example |

## HARD-GATE

```text
TESTS GATE IMPLEMENTATION:
DO NOT write implementation code before a failing test exists.
When writing tests for new behavior, follow the TDD workflow exactly:
1. Write spec
2. Run spec and verify it fails
3. Implement minimal code
4. Run spec and verify it passes

ONE BEHAVIOR PER EXAMPLE:
The word "and" in an `it` / `specify` description signals two behaviors in one example. Split it every time — no exceptions.
```

## Core Process

When driving new behaviour with RSpec, follow this sequence:

1. **Write the failing spec** — pick the smallest spec type that exercises the intended behaviour (model > service > request > system). See table below for guidance.
2. **Run it and confirm the failure message** — show the concrete RED failure class/message for the first spec. Do not leave this as a placeholder template and do not use illustrative `e.g.` failure examples in the final artifact.
3. **Implement the minimum code** to make the spec pass.
4. **Refactor** — clean up duplication and naming while keeping the suite green.
5. **Verify** — run the full relevant spec file, then the suite, before committing.

### Choosing the best first failing spec for a Rails change

| Change type | Start with |
|-------------|------------|
| Pure domain logic | Model or PORO service spec |
| HTTP endpoint behaviour | Request spec |
| Background processing | Job spec |
| Cross-layer user journey | System spec (sparingly) |

### Service Spec (anchor pattern)
```ruby
RSpec.describe Invoices::MarkOverdue do
  describe '.call' do
    subject(:result) { described_class.call(invoice: invoice) }

    context 'when the invoice is overdue and unpaid' do
      let(:invoice) { create(:invoice, due_date: 2.days.ago, paid_at: nil) }
      it 'marks the invoice overdue' do
        expect { result }.to change { invoice.reload.overdue? }.from(false).to(true)
      end
    end
  end
end
```

### One Behavior Per Example
```ruby
# BAD — two assertions; if the first fails, the second never runs
it 'returns 201 and creates the record' do; end

# GOOD — one observable outcome per example
it 'returns 201' do; end
it 'creates the record' do; end
```

## Flaky Tests & Deterministic Assertions

| Cause | Fix |
|-------|-----|
| Time-dependent logic | `freeze_time` / `travel_to`; never set past dates as shortcut |
| State leakage | Each example sets up own state; avoid `before(:all)` |
| Async jobs | `queue_adapter = :test` + `have_enqueued_job`; never assert side-effects imperatively |
| External HTTP | `WebMock` / `VCR`; never allow real network in CI |
| DB state bleed | Transactional fixtures or `DatabaseCleaner`; never share `let!` across contexts |
| Race conditions | Explicit Capybara waits; avoid `sleep` |
| Imprecise assertions | `change.from().to()` over final state; exact values over `be_truthy`/`be_falsey`; see rule 16 for `updated_at` |

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](EXAMPLES.md)** — For code examples of service specs, shared examples, and factory design.
- **[assets/spec_templates.md](assets/spec_templates.md)** — Standard templates for different types of specs.
- **[assets/tdd_proof_checklist.md](assets/tdd_proof_checklist.md)** — Use when the task involves new behavior and the final answer must show RED/GREEN proof.

## Output Style

When asked to write or review RSpec specs, your output MUST satisfy each rule below. Each is graded independently — one violation drops the whole check.

1. **Spec file path** mirrors the source: `app/foo/bar.rb` → `spec/foo/bar_spec.rb`.
2. **`# frozen_string_literal: true`** as the first line of every spec file.
3. **`RSpec.describe`** uses the full constant path (`RSpec.describe Module::Class do`), not a string.
4. **`describe '#method'` / `describe '.class_method'`** for each method under test.
5. **`context 'when ...'` / `context 'with ...'`** for scenario variations — never use `context` to group methods.
6. **`let` for test data**, `let!` ONLY when the object must exist before the action under test.
7. **No `let_it_be`** unless the project already depends on `test-prof` (check `Gemfile.lock` first).
8. **NO "and" in any example description** — Split them. Perform an explicit scan before returning the spec.
9. **`subject(:result) { ... }`** for service / PORO specs invoking `.call`.
10. **`travel_to` / `freeze_time`** for any time-dependent assertion — never set past `Time.now` or stub `Time.current` directly.
11. **External boundaries mocked** at the class-method level (`allow(SomeClient).to receive(:method)`); ActiveRecord finders are NEVER mocked.
12. **TDD failure proof** — State the smallest spec type chosen, the command run, and the concrete observed failing message proving missing behavior rather than broken setup. Do not return only a RED proof template with placeholders, and do not write `e.g.` before the failure message.
13. **Verification proof** — After implementation, state the passing focused rerun, the full relevant spec file, and the broader suite command when available.
14. **Minimal factories** — Use only explicit attributes needed for the behavior; prefer traits for optional states and `build` / `build_stubbed` unless persistence is required. Do not hide business-meaningful defaults in the factory.
15. **Multiple related assertions** — Use `aggregate_failures` when one behavior needs several related expectations, and show it in the produced spec when relevant.
16. **Timestamp assertions** — Never assert `updated_at` unless time is frozen and the timestamp change is the behavior under test.
17. **Self-audit** — Before returning, include a short checklist confirming:
   - No `it`/`specify` descriptions contain "and".
   - Every `let!` is justified by a must-exist-before-action constraint.
   - Referenced shared examples are actually included.
   - Shared examples are avoided when each context needs different setup.
   - Factories use the least-persistent setup that proves the behavior.
   - Time-dependent records are created before `travel_to` when the original timestamp matters.
18. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | Choosing the best first failing spec for a Rails change |
| **create-service-object** | Providing test structure for the `.call` pattern |
| **refactor-code** | Adding characterization tests before refactoring |
| **implement-graphql** | Writing specs for GraphQL resolvers and mutations |

|| **tdd-process** *(from ruby-core-skills)* | Process discipline: Red-Green-Refactor gates, checkpoint pattern |
