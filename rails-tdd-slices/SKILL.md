---
name: rails-tdd-slices
description: >
  Use when choosing the best first failing spec or vertical slice for a Ruby on
  Rails change. Covers request vs model vs service vs job vs engine spec
  selection, system spec escalation, smallest safe slice planning, and
  Rails-first TDD sequencing.
---

# Rails TDD Slices

Use this skill when the hardest part of the task is deciding where TDD should start.

**Core principle:** Start at the highest-value boundary that proves the behavior with the least unnecessary setup.

## Quick Reference

| Change type | Best first slice |
|-------------|------------------|
| Endpoint / controller flow | Request spec |
| Domain rule on an existing object | Model spec |
| Service orchestration | Service spec |
| Background work | Job spec |
| Critical end-to-end UI flow | System spec |
| Engine routing / install / generator | Engine spec via `rails-engine-testing` |
| Bug fix | Reproduction spec where the bug is observed |

## HARD-GATE

```text
DO NOT choose the first spec based on convenience alone.
DO NOT start with a lower-level unit if the real risk is request, job, engine, or persistence wiring.
ALWAYS run the chosen spec and verify it fails for the right reason before implementation.
```

## When to Use

- The user asks where to start TDD for a Rails change.
- A feature spans multiple layers and the first spec is not obvious.
- A bug is reproducible but it is unclear whether to begin with request, service, model, or job coverage.
- **Next step:** Chain to `rspec-best-practices` after choosing the slice, then to the implementation skill for the affected area.

## Process

1. **Name the behavior:** State the user-visible outcome or invariant to prove.
2. **Locate the boundary:** Decide where the behavior is observed first: HTTP request, service entry point, model rule, job execution, engine integration, or external adapter.
3. **Pick the smallest strong slice:** Choose the spec type that proves the behavior without dragging in unrelated layers.
4. **Suggest the path:** Name the likely spec path using normal Rails conventions (for example `spec/requests/...`, `spec/services/...`, `spec/jobs/...`, `spec/models/...`).
5. **Write one failing example:** Keep it minimal; one example is enough to open the gate.
6. **Run and validate:** Confirm the failure is because the behavior is missing, not because the setup is broken.
7. **Hand off:** Continue with `rspec-best-practices`, `rspec-service-testing`, `rails-engine-testing`, or the implementation skill that fits the slice.

## Decision Heuristics

| Situation | Prefer | Why |
|-----------|--------|-----|
| New API contract, params, status code, JSON shape | Request spec | Proves the real contract |
| Pure rule on a cohesive record or value object | Model spec | Fast feedback on domain behavior |
| Multi-step orchestration across collaborators | Service spec | Focuses on the workflow boundary |
| Enqueue/run/retry/discard behavior | Job spec | Captures async semantics directly |
| Critical Turbo/Stimulus or browser-visible flow | System spec | Use only when browser interaction is the real risk |
| Engine routing, generators, host integration | Engine spec | Normal app specs miss engine wiring |
| Unsure between two layers | Higher boundary first | Easier to prove real behavior before drilling down |

## Rails Paths

Use conventional spec paths when recommending the first slice:

| First slice | Suggested path pattern |
|-------------|------------------------|
| Request spec | `spec/requests/..._spec.rb` |
| Model spec | `spec/models/..._spec.rb` |
| Service spec | `spec/services/..._spec.rb` |
| Job spec | `spec/jobs/..._spec.rb` |
| System spec | `spec/system/..._spec.rb` |
| Engine spec | Engine request/routing/generator path used by `rails-engine-testing` |

## Examples

### Good: New JSON Endpoint

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

### Good: New Orchestration Service

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

### Bad: Starting Too Low

```ruby
# Bad first move:
# Start with a PORO helper spec because it is easier to write,
# even though the real risk is the request contract or workflow wiring.
```

## Test Feedback Checkpoint

After writing and running the first failing spec, **pause before implementation** and present the test for review:

```
CHECKPOINT: Test Design Review

1. Present: Show the failing spec(s) written
2. Ask:
   - Does this test cover the right behavior?
   - Is the boundary correct (request vs service vs model)?
   - Are the most important edge cases represented?
   - Is the failure reason correct (feature missing, not setup error)?
3. Confirm: Only proceed to implementation once test design is approved.
```

**Why this matters:** Implementing against a poorly designed test wastes the TDD cycle. A 2-minute review of the test now prevents a full rewrite later.

**Hand off:** After test design is confirmed → `rspec-best-practices` for the full TDD gate cycle.

## Output Style

When using this skill, return:

1. **Behavior to prove**
2. **Chosen boundary**
3. **First spec type**
4. **Suggested spec path**
5. **Why this is the highest-value starting slice**
6. **Next skill to chain**

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Starting with a PORO spec because it is easy | Easy is not the same as high-signal |
| Writing three spec types before running any | Pick one slice, run it, prove the failure |
| Defaulting to request specs for every change | Some domain rules are better proven lower in the stack |
| Defaulting to model specs for controller behavior | Controllers and APIs need request-level proof |
| Using controller specs as the default HTTP entry point | Prefer request specs unless the repo has a strong existing reason otherwise |
| Jumping to system specs too early | Reserve system specs for critical browser flows where lower layers cannot prove the risk well |

## Red Flags

- "We'll add the request spec later"
- The chosen spec cannot prove the user-visible behavior
- The first spec requires excessive factories just to boot
- The failure is caused by broken setup rather than missing behavior
- The first recommendation is a controller spec without a repo-specific reason
- A system spec is chosen even though a request or service spec would prove the behavior faster

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-best-practices** | After choosing the first slice, to enforce the TDD loop correctly |
| **rspec-service-testing** | When the first slice is a service object spec |
| **rails-engine-testing** | When the first slice belongs to an engine |
| **rails-bug-triage** | When the starting point is an existing bug report |
| **refactor-safely** | When the task is mostly structural and needs characterization tests first |
