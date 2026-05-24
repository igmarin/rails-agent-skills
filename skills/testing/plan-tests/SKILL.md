---
name: plan-tests
license: MIT
description: >
  Use when choosing the best first failing RSpec spec or vertical slice for a
  Ruby on Rails change. Covers request vs model vs service vs job vs engine spec
  selection, system spec escalation, smallest safe slice planning, and
  Rails-first TDD sequencing. Trigger words: where to start testing, what test
  to write first, RSpec, test-driven development, TDD, first failing test.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Plan Tests

## Quick Reference

| Change type | First spec | Path | Why |
|-------------|-----------|------|-----|
| API contract, params, status code, JSON shape | Request spec | `spec/requests/` | Proves the real HTTP contract |
| Domain rule on a cohesive record or value object | Model spec | `spec/models/` | Fast feedback on domain behavior |
| Multi-step orchestration across collaborators | Service spec | `spec/services/` | Focuses on the workflow boundary |
| Enqueue/run/retry/discard behavior | Job spec | `spec/jobs/` | Captures async semantics directly |
| Critical Turbo/Stimulus or browser-visible flow | System spec | `spec/system/` | Use only when browser interaction is the real risk |
| Engine routing, generators, host integration | Engine spec | `spec/requests/` or engine path | Normal app specs miss engine wiring — see `test-engine` |
| Bug fix | Reproduction spec | Where the bug is observed | Proves the fix and prevents regression |
| Unsure between layers | Higher boundary first | — | Easier to prove real behavior before drilling down |

## HARD-GATE

```text
CHECKPOINT: Test Design Review

1. Present: Show the failing spec(s) written
2. Ask:
   - Does this test cover the right behavior?
   - Is the boundary correct (request vs service vs model)?
   - Are the most important edge cases represented?
   - Is the failure reason correct (feature missing, not setup error)?
3. Confirm: Only proceed to implementation once test design is approved.
```

## Core Process

Use this skill when the hardest part of the task is deciding where TDD should start.

**Core principle:** Start at the highest-value boundary that proves the behavior with the least unnecessary setup.

### Process

1. **Name the behavior:** State the user-visible outcome or invariant to prove.
2. **Locate the boundary:** Decide where the behavior is observed first: HTTP request, service entry point, model rule, job execution, engine integration, or external adapter.
3. **Pick the smallest strong slice:** Choose the spec type that proves the behavior without dragging in unrelated layers. Do not choose the first spec based on convenience alone — do not start with a lower-level unit if the real risk is request, job, engine, or persistence wiring.
4. **Suggest the path:** Name the likely spec path using normal Rails conventions (for example `spec/requests/...`, `spec/services/...`, `spec/jobs/...`, `spec/models/...`).
5. **Write one failing example:** Keep it minimal; one example is enough to open the gate. Do not include multiple opening examples unless the user explicitly asks for expanded coverage; list additional cases as follow-up coverage instead.
6. **Run and validate:** Confirm the failure is because the behavior is missing, not because the setup is broken.
7. **Hand off:** Continue with `write-tests`, `test-service`, `test-engine`, or the implementation skill that fits the slice.

### Examples

#### Good: New JSON Endpoint

```ruby
# Behavior: POST /orders validates params and returns 201 with JSON payload
# First slice: request spec
# Suggested path: spec/requests/orders/create_spec.rb

RSpec.describe "POST /orders", type: :request do
  let(:user) { create(:user) }
  let(:valid_params) { { order: { product_id: create(:product).id, quantity: 1 } } }

  before { sign_in user }

  it "creates an order and returns 201" do
    post orders_path, params: valid_params, as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body["id"]).to be_present
  end
end
```

#### Good: New Orchestration Service

```ruby
# Behavior: Orders::CreateOrder validates inventory, persists, and enqueues follow-up work
# First slice: service spec
# Suggested path: spec/services/orders/create_order_spec.rb

RSpec.describe Orders::CreateOrder do
  subject(:result) { described_class.call(user: user, product: product, quantity: 1) }

  let(:user)    { create(:user) }
  let(:product) { create(:product, stock: 5) }

  it "returns a successful result with the new order" do
    expect(result).to be_success
    expect(result.order).to be_persisted
  end
end
```

### Pitfalls

| Pitfall | What to do |
|---------|------------|
| Starting with a PORO spec because it is easy | Easy ≠ high-signal — choose the boundary that proves the real behavior |
| Writing three spec types before running any | Pick one slice, run it, prove the failure, then proceed |
| Defaulting to request specs for everything | Some domain rules are better proven at the model or service layer |
| Defaulting to model specs for controller behavior | Controllers and APIs need request-level proof |
| Using controller specs as the default HTTP entry point | Prefer request specs unless the repo has an existing reason |
| Jumping to system specs too early | Reserve for critical browser flows that lower layers cannot prove |
| "We'll add the request spec later" | The spec is the gate — implement only after the first slice is failing for the right reason |
| First spec requires excessive factory setup | Excessive setup = wrong boundary. Simplify or move the slice. |

## Extended Resources

Load only when needed:

- [assets/first_slice_template.md](assets/first_slice_template.md) — Use when producing a complete first-slice decision artifact with boundary table, one opening example, RED proof, follow-up coverage, and HARD-GATE answers.

## Output Style

1. **Test Proposal**: Clearly present the proposed failing spec with the correct boundary context.
2. **Opening gate**: Include exactly one first failing `it` example for the initial TDD gate. Put happy path, edge cases, enqueue checks, and validation errors under "Follow-up coverage" unless one of them is the chosen first slice.
3. **Failure proof**: Show the focused command and the expected RED reason before implementation.
4. **Design checkpoint**: Answer the four HARD-GATE review questions before handing off.
5. **Template use**: If the answer needs a full planning artifact, load `assets/first_slice_template.md` and follow its structure.
6. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | After choosing the first slice, to enforce the TDD loop correctly |
| **test-service** | When the first slice is a service object spec |
| **test-engine** | When the first slice belongs to an engine |
| **triage-bug** | When the starting point is an existing bug report |
| **refactor-code** | When the task is mostly structural and needs characterization tests first |

| **test-planning-process** *(from ruby-core-skills)* | Process discipline: test type decision framework, coverage strategy |
