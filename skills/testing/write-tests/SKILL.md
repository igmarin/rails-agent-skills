---
name: write-tests
type: atomic
license: MIT
description: >
  Use when writing, reviewing, or configuring RSpec tests in Ruby on Rails — must execute the spec via `bundle exec rspec` and capture the actual test output (failure message or stack trace) rather than describing expected behavior, prefer behavioral confidence over implementation coupling, pick the smallest spec type exercising the behavior (model > service > request > system), mirror the file paths of the source, use # frozen_string_literal: true, define subject(:result) for service specs, and consult `assets/tdd_proof_checklist.md` when the task involves new behavior. Use when adding test coverage, refactoring specs, or practicing TDD. Trigger words: write spec, rspec, test-driven development, testing, write tests.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Write Tests

Use this skill when the task is to write, review, or clean up RSpec tests.

## Quick Reference

| Aspect | Rule |
|--------|------|
| Spec types | Model: domain logic / pure domain → start here; Request: HTTP endpoints; Job: background processing; Service/PORO: clean Ruby; System: E2E cross-layer journey (sparingly) |
| Assertions | Test behavior, not implementation |
| Factories | Minimal attributes; traits for options; prefer `build`/`build_stubbed` over `create` |
| Mocking | Stub external boundaries at class level (e.g. `allow(Client).to receive`); no Active Record mocking |
| Service specs | **Required:** `describe '.call'` and `subject(:result)` (see assets/output_checklist.md) |
| `let` vs `let!` | Default to `let`; use `let!` only when object must exist before action |
| Example names | Present tense; no `should`; **no `and`** (see assets/output_checklist.md) |

## TDD Workflow (RED → GREEN → REFACTOR)

> **HARD GATE: DO NOT write implementation code before a failing test exists.**

When driving new behaviour with RSpec, follow this sequence:

1. **Write the failing spec** — pick the smallest spec type that exercises the intended behaviour (model > service > request > system), as shown in the Spec types row above.
2. **Run it and confirm the failure message** — show the concrete RED failure class/message. Do not leave this as a placeholder template; do not use illustrative `e.g.` failure examples in the final artifact.
3. **Implement the minimum code** to make the spec pass.
4. **Refactor** — clean up duplication and naming while keeping the suite green.
5. **Verify** — run the full relevant spec file, then the suite, before committing.

For output format and RED/GREEN proof requirements, see **[assets/tdd_proof_checklist.md](assets/tdd_proof_checklist.md)**.

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

Split `and` in `it`/`specify` descriptions every time — no exceptions.

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
- **[assets/tdd_proof_checklist.md](assets/tdd_proof_checklist.md)** — Use when the task involves new behavior; defines RED/GREEN proof format, output formatting rules, and GREEN progress bar requirements.
- **[assets/output_checklist.md](assets/output_checklist.md)** — Complete 18-point checklist for RSpec output structure, conventions, and self-auditing; also defines all output style rules (spec structure, file path mirroring, `frozen_string_literal`, `subject(:result)`, and TDD proof format).
