---
name: refactor-code
license: MIT
description: >
  Use when refactoring Rails code to change structure without changing behavior — must write characterization tests and verify they pass on the current code BEFORE touching any production files, identify inputs/outputs keeping public interfaces stable, run verification after every step and the full suite at the end, and include a Stable behavior statement and Verification evidence showing actual command output under the Observed output label. Trigger words: refactor, restructure, extract service, split class, reduce duplication.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Refactor Code

Use this skill when the task is to change structure without changing intended behavior.

**Core principle:** Small, reversible steps over large rewrites. Separate design improvement from behavior change.

## Quick Reference

| Step | Action | Verification |
|------|--------|------|
| 1 | Define stable behavior | Written statement of what must not change |
| 2 | Add characterization tests | Tests pass on current code |
| 3 | Choose smallest safe slice | One boundary at a time |
| 4 | Rename, move, or extract | Tests still pass |
| 5 | Remove compatibility shims | Tests still pass, new path proven |

## HARD-GATE

```text
NO REFACTORING WITHOUT CHARACTERIZATION TESTS FIRST.
NEVER mix behavior changes with structural refactors in the same step —
  if behavior changes are also needed, complete the structural refactor first,
  then apply behavior changes in a separate step with its own test.
ONE boundary per refactoring step — never extract two abstractions in the same step.
If a public interface changes, document the compatibility shim and its removal condition.
```

## Core Process

### 1. Define stable behavior
Identify the exact inputs and outputs of the logic being refactored. Keep public interfaces stable until callers are migrated. Prefer adapters, facades, or wrappers for transitional states.

Include an **Adapter/facade/wrapper decision** subsection before listing refactoring steps: either name the transitional shim and its removal condition, or state why no shim is needed because the public interface remains unchanged.

### 2. Add characterization tests
**Write this before touching any production file.** No refactoring step begins until this test exists and passes on the current (un-refactored) code. If the characterization spec fails, do not continue — stop and fix the test or the behavior mismatch.

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
Run it: `bundle exec rspec spec/requests/orders_spec.rb` — it must pass on the **current** code.

### 3. Choose the smallest safe slice
Good first moves include: renaming unclear methods, isolating duplicated logic behind a shared object, or wrapping external integrations before moving call sites. Add narrow seams before deleting old code paths.

All refactoring patterns (extracting services, splitting classes, reducing duplication) follow this same process — one boundary at a time, characterization tests first, verification after each step.

### 4. Execute extraction/refactor (One step at a time)
Extract, move, or rename logic. Stop and simplify if the refactor introduces more indirection than clarity.

#### Minimal Inline Example (Controller orchestration extraction)
**Before:**
```ruby
def create
  order = OrderCreator.new(params).call
  NotifyWarehouseJob.perform_later(order.id)
  redirect_to order_path(order)
end
```
**After:**
```ruby
def create
  order = Orders::CreateOrder.call(params: params)
  redirect_to order_path(order)
end
```

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/complete_example.md](assets/complete_example.md)** — A complete, step-by-step example of a high-scoring `answer.md` showing plan, stable behavior, characterization tests, step-by-step verification runs, and final suite verification command outputs.
- **[EXAMPLES.md](EXAMPLES.md)** — For more examples of extracting services and renaming in small batches.

### 5. Verification Protocol

Run verification after every refactoring step:
1. Run the full test suite.
2. Read the output — check exit code, count failures.
3. If tests fail: STOP, undo the step, investigate.
4. If tests pass: proceed to next step.
5. Only claim completion with evidence from the last test run — report the last line of output (e.g. "5 examples, 0 failures").

Report test run output at EACH step — not only at the end. At least two separate **Observed output** entries at different sequence points are required.

**Evidence labelling rules:** Label actual run output as **Observed output** only. Never use labels such as "Expected output", "Required output", "Planned output", or "Must produce 0 failures" as substitutes for actual observed run output.

## Output Style

When asked to refactor code, your output `answer.md` MUST include:

1. **Short Plan**: A step-by-step plan for the refactoring. The plan MUST explicitly include this statement: "If the characterization spec fails, do not continue — stop and fix the behavior mismatch before refactoring."
2. **Stable Behavior & Interface**: Identify the exact inputs and outputs of the logic being refactored. State the **Adapter/facade/wrapper decision**: either name the transitional shim and its removal condition, or state why no shim is needed because the public interface remains unchanged.
3. **Step-by-Step Execution**: Show the refactoring process divided into clear, sequential steps.
4. **Verification Evidence**: Report actual run output at EACH step under the literal label **Observed output** only (with at least two separate **Observed output** entries at different sequence points).
   - **CRITICAL**: You MUST run the tests using your shell/terminal execution tools. Do NOT fabricate, mock, or simulate terminal output. You MUST execute the test commands (e.g. `bundle exec rspec`) and copy-paste the actual observed terminal output into the **Observed output** block. Do NOT state that tests were not run or that the environment is static/mock; you must always execute the tests and report the actual run output.
5. **Resource Loading & Reference**: Include a short section in `answer.md` documenting which specific assets (e.g. `assets/complete_example.md`) were loaded conditionally and why. This makes the process instruction verifiable.
6. **Language**: Must be in English unless explicitly requested otherwise.

