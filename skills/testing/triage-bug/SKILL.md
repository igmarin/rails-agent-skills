---
name: triage-bug
license: MIT
description: >
  Use when investigating a bug, error, or regression in a Ruby on Rails codebase.
  Creates a failing RSpec reproduction test, isolates the broken code path, and
  produces a minimal fix plan. Trigger words: debug, broken, error, regression,
  stack trace, failing test, RSpec, bug report, Rails app.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Triage Bug

## Quick Reference

| Bug shape | Likely first spec |
|-----------|-------------------|
| HTTP symptoms (status, JSON, redirect) | Request spec |
| Data symptoms (wrong value, validation) | Model or service spec |
| Timing symptoms (missing job, email) | Job spec |
| Engine routing/generator regression | Engine spec in dummy app |

## HARD-GATE

```text
DO NOT guess at fixes without a reproduction path.
1. Reproduce the bug.
2. Choose the right failing spec boundary.
3. Plan the smallest safe repair.
```

## Core Process

1. **Capture the report:** Restate the expected behavior, actual behavior, and reproduction steps.
2. **Bound the scope:** Identify whether the issue appears in request handling, domain logic, jobs, engine integration, or an external dependency.
3. **Gather current evidence:** Logs, error messages, edge-case inputs, recent changes, or missing guards.
4. **Choose the first failing spec:** Pick the boundary where the bug is visible to users or operators.
5. **Define the smallest fix path:** Name the likely files and the narrowest behavior change that should make the spec pass.
6. **Hand off:** Continue through `plan-tests` -> `write-tests` -> implementation skill.

### Canonical Request-Boundary Example

When the report is an order creation failure visible through `POST /orders`, default to the request boundary first:

- **First failing spec:** `spec/requests/orders/create_spec.rb`
- **Command:** `bundle exec rspec spec/requests/orders/create_spec.rb`
- **Expected RED:** response is not `422` with `"Out of stock"` yet, or the service raises instead of returning a handled error.
- **Smallest fix path:** `Orders::CreateOrder` handles the stock guard and returns `{ success: false, error: "Out of stock" }` without creating the order.

Do not replace this with a pricing, model-only, or controller-only example unless the bug report points there.

### Boundary Guide

See [BOUNDARY_GUIDE.md](./BOUNDARY_GUIDE.md) for the full bug-shape → spec-type mapping and layer diagnosis tips.

### Pitfalls

| Pitfall | What to do |
|---------|------------|
| Unit spec when the bug is visible at request level | Start where the failure is actually observed |
| Bundling reproduction, refactor, and new features | Fix the bug in the smallest safe slice only |
| Flaky evidence treated as green light to patch | Stabilize reproduction before touching code |
| The explanation relies on "probably" or "maybe" | Ambiguity means the reproduction step isn't done yet |

## Extended Resources

- [BOUNDARY_GUIDE.md](./BOUNDARY_GUIDE.md)
- [assets/examples.md](assets/examples.md)

## Output Style

1. **Triage shape**:
   - **Observed behavior**
   - **Expected behavior**
   - **Likely boundary**
   - **First failing spec to add**
   - **Smallest safe fix path**
   - **Follow-up skills**
   - **Exact command to run before the fix**
2. **Skeleton spec**: Provide a skeleton failing spec to run before implementing the fix.
   ```ruby
   # spec/requests/orders/create_spec.rb
   RSpec.describe "POST /orders", type: :request do
     context "when product is out of stock" do
       let(:product) { create(:product, stock: 0) }

       it "returns 422 with an error message" do
         post orders_path, params: { order: { product_id: product.id, quantity: 1 } }, as: :json
         expect(response).to have_http_status(:unprocessable_entity)
         expect(response.parsed_body["error"]).to eq("Out of stock")
       end
     end
   end
   ```
3. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | To choose the strongest first failing spec for the bug |
| **write-tests** | To run the TDD loop correctly after the spec is chosen |
| **refactor-code** | When the bug sits inside a risky refactor area and behavior must be preserved first |
| **code-review** | To review the final bug fix for regressions and missing coverage |
| **review-architecture** | When the bug points to a deeper boundary or orchestration problem |
