---
name: write-tests
type: atomic
license: MIT
description: >
  Use when writing, reviewing, or configuring RSpec tests in Ruby on Rails — must run the spec and verify it fails (confirm the concrete RED failure class/message, no placeholders or illustrative examples) and run it and verify it passes, prefer behavioral confidence over implementation coupling, pick the smallest spec type exercising the behavior (model > service > request > system), mirror the file paths of the source, use # frozen_string_literal: true, define subject(:result) for service specs, and load `assets/tdd_proof_checklist.md` when the task involves new behavior. Use when adding test coverage, refactoring specs, or practicing TDD. Trigger words: write spec, rspec, test-driven development, testing, write tests.
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
| Spec types | Model: domain logic; Request: HTTP endpoints; Job: background processing; Service/PORO: clean Ruby; System: E2E |
| Assertions | Test behavior, not implementation |
| Factories | Minimal attributes; traits for options; prefer `build`/`build_stubbed` over `create` |
| Mocking | Stub external boundaries at class level (e.g. `allow(Client).to receive`); no Active Record mocking |
| Service specs | **Required:** `describe '.call'` and `subject(:result)` (see assets/output_checklist.md) |
| `let` vs `let!` | Default to `let`; use `let!` only when object must exist before action |
| Example names | Present tense; no `should`; **no `and`** (see assets/output_checklist.md) |

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
| Imprecise assertions | `change.from().to()` over final state; exact values over `be_truthy`/`be_falsey`; see rule 16 |

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/complete_example.md](assets/complete_example.md)** — A complete, step-by-step example of a high-scoring `answer.md` showing plan, spec, realistic Observed RED/GREEN outputs, and verification tables.
- **[assets/examples.md](assets/examples.md)** — For code examples of service specs, shared examples, and factory design.
- **[assets/spec_templates.md](assets/spec_templates.md)** — Standard templates for different types of specs.
- **[assets/tdd_proof_checklist.md](assets/tdd_proof_checklist.md)** — Use when the task involves new behavior and the final answer must show RED/GREEN proof.
- **[assets/output_checklist.md](assets/output_checklist.md)** — Complete 18-point checklist for RSpec output structure, conventions, and self-auditing.

## Output Style

When asked to write or review RSpec specs, the output `answer.md` must comply with all RSpec conventions, TDD proof steps, and self-audit checks.

- **TDD failure and verification proof**: Provide the exact command and failure/success output. **Even in static/mock environments where tests cannot be executed interactively, you MUST generate and present realistic, concrete terminal execution output under the literal labels `Observed RED output` and `Observed GREEN output`. Do NOT copy the exact timing values or example counts verbatim from the skill's reference templates; you MUST generate unique, scenario-specific numbers. The generated progress bar dots for the GREEN output MUST consist ONLY of periods (`.`) representing passing examples, and MUST NOT contain any `F` (failures) or `*`/`U` (pending) characters. The number of dots MUST exactly equal the number of examples in the summary. Count them carefully:
  - 1 example: `.`
  - 2 examples: `..`
  - 3 examples: `...`
  - 4 examples: `....`
  - 5 examples: `.....`
  - 6 examples: `......`
  - 7 examples: `.......`
  - 8 examples: `........`
  Do not add extra spaces, ellipsis, or mismatched dot counts. You MUST present a separate Observed GREEN output block (showing unique passing execution logs) for EACH verification level: (1) the focused spec, (2) the full relevant spec file or directory, and (3) the broader/full test suite. Never include disclaimers, assumptions, or notes stating that the tests could not be run or that they are expected/inferred.**
- **Spec structure**: File paths must mirror the source, use `# frozen_string_literal: true`, and define `subject(:result)` for service specs.
- **Conventions**: No `and` in example descriptions, use `let!` only when needed before action, and mock external boundaries cleanly.
- **Resource Loading & Reference**: Include a short section in `answer.md` documenting which specific assets (e.g., `assets/tdd_proof_checklist.md`, `assets/output_checklist.md`) were loaded on-demand and why. This makes the process instruction verifiable.
- **Language**: Must be in English unless explicitly requested otherwise.


## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | Choosing the best first failing spec for a Rails change |
| **create-service-object** | Providing test structure for the `.call` pattern |
| **refactor-code** | Adding characterization tests before refactoring |
| **implement-graphql** | Writing specs for GraphQL resolvers and mutations |

| **tdd-process** *(from ruby-core-skills)* | Process discipline: Red-Green-Refactor gates, checkpoint pattern |
