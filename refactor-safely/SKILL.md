---
name: refactor-safely
license: MIT
description: >
  Use when the goal is to change code structure without changing behavior — this
  includes extracting a service object from a fat controller or model, splitting
  a large class, renaming abstractions, reducing duplication, or reorganizing
  modules. Covers characterization tests (write tests that document current behavior
  before touching the code), safe extraction in small steps, and verification after
  every step. Do NOT use for bug fixes or new features — those follow the TDD gate
  in rspec-best-practices. Do NOT mix structural changes with behavior changes in
  the same step.
license: MIT
---

# Refactor Safely

Use this skill when the task is to change structure without changing intended behavior.

**Core principle:** Small, reversible steps over large rewrites. Separate design improvement from behavior change.

## Quick Reference

| Step | Action | Verification |
|------|--------|-------------|
| 1 | Define stable behavior | Written statement of what must not change |
| 2 | Add characterization tests | Tests pass on current code |
| 3 | Choose smallest safe slice | One boundary at a time |
| 4 | Rename, move, or extract | Tests still pass |
| 5 | Remove compatibility shims | Tests still pass, new path proven |

## HARD-GATE

```
NO REFACTORING WITHOUT CHARACTERIZATION TESTS FIRST.
NEVER mix behavior changes with structural refactors in the same step.
ONE boundary per refactoring step — never extract two abstractions in the same step.
VERIFY tests pass after EVERY step — not just at the end.
If a public interface changes, document the compatibility shim and its removal condition.
```

## Core Rules

- When behavior changes are also needed, complete the structural refactor first, then apply behavior changes in a separate step with its own test.
- Keep public interfaces stable until callers are migrated.
- Extract boundaries one at a time; split any step that would touch two abstractions.
- Prefer adapters, facades, or wrappers for transitional states.
- Stop and simplify if the refactor introduces more indirection than clarity.

## Good First Moves

- Rename unclear methods or objects
- Isolate duplicated logic behind a shared object
- Extract query or service objects from repeated workflows
- Wrap external integrations before moving call sites
- Add narrow seams before deleting old code paths

## Verification Protocol

**EXTREMELY-IMPORTANT:** Run verification after every refactoring step.

```
AFTER each step:
1. Run the full test suite
2. Read the output — check exit code, count failures
3. If tests fail: STOP, undo the step, investigate
4. If tests pass: proceed to next step
5. ONLY claim completion with evidence from the last test run —
   report the last line of output (e.g. "5 examples, 0 failures")

Report test run output at EACH step — not only at the end. At least two separate evidence entries at different sequence points are required.
```

**Forbidden claims:**
- "Should work now" (run the tests)
- "Looks correct" (run the tests)
- "I'm confident" (confidence is not evidence)

## Characterization Test Template

**Write this before touching any production file.** This is not optional — no refactoring step begins until this test exists and passes on the current (un-refactored) code.

```ruby
# spec/requests/orders_spec.rb  (or service/model spec — mirror the file being refactored)
# frozen_string_literal: true

RSpec.describe "Orders#create current behavior", type: :request do
  describe "POST /orders" do
    let(:valid_params) { { order: { product_id: 1, quantity: 2 } } }

    it "creates order and enqueues warehouse notification" do
      expect { post orders_path, params: valid_params }
        .to change(Order, :count).by(1)
      expect(NotifyWarehouseJob).to have_been_enqueued
    end
  end
end
```

Run it: `bundle exec rspec spec/requests/orders_spec.rb` — it must pass on the **current** code before any refactoring begins. If it fails, stop and fix the test or the existing code first.

## Minimal Inline Example

The default tiny slice when extracting controller orchestration:

**Before (controller does orchestration):**

```ruby
def create
  order = OrderCreator.new(params).call
  NotifyWarehouseJob.perform_later(order.id)
  redirect_to order_path(order)
end
```

**After (same behavior, extraction only):**

```ruby
def create
  order = Orders::CreateOrder.call(params: params)
  redirect_to order_path(order)
end
```

## Deeper Guidance

Use support files for detailed guidance and examples:

- [EXAMPLES.md](./EXAMPLES.md): End-to-end refactor sequences and anti-pattern examples
- [HEURISTICS.md](./HEURISTICS.md): Common mistakes, red flags, and review heuristics
- [INTEGRATION.md](./INTEGRATION.md): How to chain this skill with related skills

## Output Style

When asked to refactor:

1. State the stable behavior that must not change.
2. Propose the smallest safe sequence — each step extracts exactly ONE boundary (one class, one module, or one extracted delegation). A step that moves two abstractions is too large; split it.
3. Show the characterization test code in your output — do not touch any production file until the test exists and passes.
4. **Compatibility shims (required when public interface changes):** For each shim, state: (a) what the shim is, (b) why it exists, (c) the specific condition under which it will be removed (e.g., "remove after all callers migrate to Orders::CreateOrder.call"). If no public interface changes, state "No compatibility shims needed — public interface unchanged."
5. Follow Verification Protocol after each step — report evidence mid-sequence AND at the end.

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-best-practices** | For additional spec structure and shared examples after characterization tests are written |
| **rails-architecture-review** | When refactor reveals structural problems ([details](./INTEGRATION.md#rails-architecture-review)) |
| **rails-code-review** | For reviewing the refactored code ([details](./INTEGRATION.md#rails-code-review)) |
| **ruby-service-objects** | When extracting logic into service objects ([details](./INTEGRATION.md#ruby-service-objects)) |

## Assets

- [assets/characterization_tests.md](assets/characterization_tests.md)
- [assets/examples.md](assets/examples.md)
