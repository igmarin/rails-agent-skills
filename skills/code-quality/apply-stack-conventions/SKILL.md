---
name: apply-stack-conventions
license: MIT
description: >
<<<<<<< HEAD
   Use when writing new Rails code, building features with TDD (test-driven development, red-green-refactor, write tests first) for the Ruby on Rails + PostgreSQL + Hotwire + Tailwind stack — must write specs and run them in the terminal BEFORE implementation to verify they fail, then implement and re-run to verify they pass, show spec file content (not just spec path), include a Tests-first proof before implementation section showing actual spec code, the run command (bundle exec rspec spec/[path]_spec.rb), and actual observed terminal output, keeping steps testable in isolation. MVC structure, ActiveRecord queries, Turbo Frames/Streams, Stimulus controllers, and Tailwind patterns. Not for general Rails design principles — scoped to this specific stack.
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
  Use when writing new Rails code for a PostgreSQL + Hotwire + Tailwind CSS stack — ALL new code MUST have test written BEFORE implementation (write spec file content not just path: `bundle exec rspec spec/[path]_spec.rb`→verify RED failure with observed output→implement→verify GREEN with observed result, use Observed RED/GREEN labels as proof, never use illustrative `e.g.` comments as evidence), output MUST include tests-first proof before implementation with actual spec code + exact command + Observed RED/GREEN output per layer, layers testable in isolation (model/query→service→controller/request→view/Turbo→Stimulus→Tailwind, Layer isolation section with focused spec per layer, "not applicable" for unchanged), apply Devise+Pundit on access-controlled resources. Covers MVC structure, ActiveRecord queries, Turbo Frames/Streams, Stimulus controllers, Tailwind patterns. Not for general Rails design principles — scoped to this specific stack.
=======
  Use when writing new Rails code for the PostgreSQL + Hotwire + Tailwind stack — must write specs and validate them RED BEFORE implementation, verify they pass GREEN after, show spec file content (not just spec path), include a Tests-first proof before implementation section showing actual spec code, the run command (bundle exec rspec spec/[path]_spec.rb), and the Observed RED output and Observed GREEN output labels, keeping steps testable in isolation. MVC structure, ActiveRecord queries, Turbo Frames/Streams, Stimulus controllers, and Tailwind patterns. Not for general Rails design principles — scoped to this specific stack.
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Apply Stack Conventions

## Quick Reference

<<<<<<< HEAD
| Stack area | Default convention | Common pitfall |
|------------|------------------|----------------|
| Rails MVC | Thin controllers; move non-trivial business logic into service objects | Controller action with 15+ lines of business logic → extract to a service object using `.call` |
| PostgreSQL | Avoid N+1s with `includes`; use database constraints for integrity | N+1 queries in loops over associations → eager load with `includes` before the loop |
| Hotwire | Prefer `<turbo-frame>` wrapping for targeted section replacement; `turbo_stream` for multi-target updates; Stimulus only when Turbo cannot handle the interaction | Reaching for Stimulus before trying Turbo → use Turbo Frames/Streams first |
| Tailwind | Use utilities in views; extract repeated UI into partials/components | — |
| Auth | Apply Devise authentication and Pundit authorization to protected resources | Accessing a protected resource without an authorisation check → apply a Pundit policy on every action that touches access-controlled data |
| Service Objects | Controllers delegate via `.call`; service returns `{ success:, record: }` | Business logic living in controller actions → extract to a service object |
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
| Stack area | Default convention |
|------------|--------------------|
| Rails MVC | Thin controllers; move non-trivial business logic into service objects |
| PostgreSQL | Avoid N+1s with `includes`; use database constraints for integrity |
| Hotwire | Prefer Turbo Frames/Streams before Stimulus |
| Tailwind | Use utilities in views; extract repeated UI into partials/components |
| Auth | Apply Devise authentication and Pundit authorization to protected resources |
=======
| Stack area | Default convention |
|------------|------------------|
| Rails MVC | Thin controllers; move non-trivial business logic into service objects |
| PostgreSQL | Avoid N+1s with `includes`; use database constraints for integrity |
| Hotwire | Prefer Turbo Frames/Streams before Stimulus |
| Tailwind | Use utilities in views; extract repeated UI into partials/components |
| Auth | Apply Devise authentication and Pundit authorization to protected resources |
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

## HARD-GATE

```text
ALL new code MUST have its test written and validated BEFORE implementation.
  1. Write the spec file content, not only the spec path: bundle exec rspec spec/[path]_spec.rb
  2. Run the spec in the terminal — verify it FAILS (the output must show failure proving the feature does not exist yet)
  3. Write the implementation code
  4. Re-run the same spec in the terminal — verify it PASSES and include the observed green result line
  5. Refactor if needed, keeping tests green
The final artifact must show the test proof before implementation code.
For each layer, repeat the same spec command after implementation and show
the passing result line from the actual terminal run.
CRITICAL: You MUST execute test commands using your shell/terminal tools.
Do NOT fabricate, mock, or simulate terminal output. Copy-paste the actual
observed output into the proof section. Do NOT state that tests were not run
or that the environment lacks a runtime; you must always execute the tests.
See write-tests for the full gate cycle.
```

### Mini Red-Green Cycle Example

This illustrates the required format for the HARD-GATE proof section.
The output blocks below are **illustrative templates** — in your actual `answer.md`,
replace them with copy-pasted output from your terminal execution.

**Spec file — `spec/models/order_spec.rb`**

```ruby
require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it 'is invalid without a total' do
      order = build(:order, total: nil)
      expect(order).not_to be_valid
      expect(order.errors[:total]).to include("can't be blank")
    end
  end
end
```

**Run command**
```bash
bundle exec rspec spec/models/order_spec.rb
```

**Observed output (pre-implementation — expect failure)**
```
# paste actual terminal output here showing the failure
```

**Model implementation — `app/models/order.rb`**

```ruby
class Order < ApplicationRecord
  validates :total, presence: true
end
```

**Observed output (post-implementation — expect pass)**
```
# paste actual terminal output here showing 1 example, 0 failures
```

## Core Process

When **writing or generating** code for this project, follow these conventions. Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

**Style:** If the project uses a linter, treat it as the source of truth for formatting. For cross-cutting design principles (DRY, YAGNI, structured logging, rules by directory), use **apply-code-conventions**.

### Feature Development Workflow

For a typical feature, compose stack patterns in this order:

1. **Model** — add validations, associations, scopes; eager-load with `includes` for any association used in loops
2. **Service object** — extract non-trivial business logic from the controller (see **create-service-object**)
3. **Controller** — keep actions thin; delegate to services; respond with `turbo_stream` and `html` formats
4. **View / Turbo wiring** — wrap dynamic sections in `<turbo-frame>` tags; broadcast `turbo_stream` responses from the controller
5. **Stimulus** — add a controller only when client-side interactivity cannot be handled by Turbo alone
6. **Tailwind** — apply utility classes to the view; extract repeated patterns into partials or Stimulus targets

Each step should remain testable in isolation before wiring to the next layer.
In the final artifact, make this explicit in a **Layer isolation** section:
name the focused spec or check for model/query, service, controller/request,
view/Turbo, Stimulus, and Tailwind. If a layer is not changed, mark it "not
applicable"; do not silently omit view, Stimulus, or Tailwind isolation.

### Service Object Pattern

Controllers delegate to a service via `.call`; the service returns a result hash.

```ruby
# app/services/create_order_service.rb
class CreateOrderService
  def self.call(params)
    order = Order.new(params)
    if order.save
      { success: true, record: order }
    else
      { success: false, record: order }
    end
  end
end

# app/controllers/orders_controller.rb
def create
  result = CreateOrderService.call(order_params)
  if result[:success]
    redirect_to result[:record], notice: 'Order created.'
  else
    render :new, status: :unprocessable_entity
  end
end
```

<<<<<<< HEAD
See **create-service-object** for the full pattern and spec conventions.

### ActiveRecord: Preventing N+1 Queries
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
#### Avoiding N+1 — Eager Loading
=======
#### Eager Loading
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

```ruby
<<<<<<< HEAD
# Bad — triggers N+1
@orders = Order.all
@orders.each { |o| puts o.customer.name }

# Good — eager load before the loop
@orders = Order.includes(:customer).all
@orders.each { |o| puts o.customer.name }
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
# BAD — triggers one query per order
@orders = Order.where(user: current_user)
@orders.each { |o| o.line_items.count }

# GOOD — single JOIN via includes
@orders = Order.includes(:line_items).where(user: current_user)
=======
# Single JOIN via includes — avoids one query per record in the loop
@orders = Order.includes(:line_items).where(user: current_user)
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)
```

<<<<<<< HEAD
Enforce integrity via database constraints in addition to model validations.
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
#### Service Object (complex business logic out of the controller)

```ruby
# Controller stays thin — delegate to service
result = Orders::CreateOrder.call(user: current_user, params: order_params)
if result[:success]
  redirect_to result[:order], notice: "Order created"
else
  @order = Order.new(order_params)
  render :new, status: :unprocessable_entity
end
```

See **create-service-object** for the full `.call` pattern and response format.

### Security

This project uses **Devise** for authentication and **Pundit** for authorization. Apply these on every feature that introduces access-controlled resources.

### Pitfalls to Avoid

| Issue | Correct approach |
|-------|------------------|
| Client-side interactivity reached for before Turbo | Use Turbo Frames/Streams first; add a Stimulus controller only when Turbo cannot handle it |
| N+1 queries in loops over associations | Eager load with `includes` before the loop |
| Controller action with 15+ lines of business logic | Extract to a service object using the `.call` pattern |
| Accessing a protected resource without an authorisation check | Apply a Pundit policy on every action that touches access-controlled data |
=======
#### Service Object

```ruby
# Controller stays thin — delegate to service
result = Orders::CreateOrder.call(user: current_user, params: order_params)
if result[:success]
  redirect_to result[:order], notice: "Order created"
else
  @order = Order.new(order_params)
  render :new, status: :unprocessable_entity
end
```

See **create-service-object** for the full `.call` pattern and response format.

### Security

This project uses **Devise** for authentication and **Pundit** for authorization. Apply these on every feature that introduces access-controlled resources.

### Pitfalls to Avoid

| Issue | Correct approach |
|-------|------------------|
| Reaching for Stimulus before trying Turbo | Use Turbo Frames/Streams first |
| N+1 queries in loops over associations | Eager load with `includes` before the loop |
| Controller action with 15+ lines of business logic | Extract to a service object using the `.call` pattern |
| Accessing a protected resource without an authorisation check | Apply a Pundit policy on every action that touches access-controlled data |
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

## Output Style

When applying stack conventions, your output MUST include:

1. **Stack decisions** — State which Rails, PostgreSQL, Hotwire, Stimulus, Tailwind, auth, and service-object conventions apply.
<<<<<<< HEAD
2. **Tests-first proof before implementation** — Follow the HARD-GATE cycle: write spec code, execute it in the terminal, observe failure, write implementation, re-execute, observe pass. Place this section before any implementation code. Every spec file presented (including model, service, controller, and authorization/policy specs) MUST include its corresponding **Observed output** showing pre-implementation failure and post-implementation success.
   - **CRITICAL**: You MUST run the tests using your shell/terminal execution tools. Do NOT fabricate, mock, or simulate terminal output. Execute the test commands (e.g. `bundle exec rspec`) and copy-paste the actual observed terminal output into the proof blocks.
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
2. **Tests-first proof before implementation** — Put this section before any implementation code. For each layer, include the actual spec code written or updated, the exact command (`bundle exec rspec spec/[path]_spec.rb`), and the **Observed RED output** proving the feature is absent rather than misconfigured. Do not use placeholder or illustrative `e.g.` failure lines.
3. **Layer isolation** — Include a dedicated section stating how model/query, service, controller/request, view/Turbo, Stimulus, and Tailwind changes remain independently testable before wiring them together. Name the focused spec/check for each changed layer; mark unchanged layers "not applicable" instead of omitting them.
=======
2. **Tests-first proof before implementation** — Follow the HARD-GATE cycle above. Put this section before any implementation code, with actual spec code, exact command, and Observed RED/GREEN output per layer.
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)
3. **Layer isolation** — Dedicated section naming the focused spec/check for each changed layer (model/query, service, controller/request, view/Turbo, Stimulus, Tailwind); mark unchanged layers "not applicable".
4. **Layered implementation** — Separate model/query, service, controller, view, Stimulus, and Tailwind changes when applicable.
5. **Performance and security checks** — Call out N+1 prevention, authorization policy use, and unsafe params/content handling.
<<<<<<< HEAD
6. **Language** — Must be in English unless explicitly requested otherwise.
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
6. **Verification** — For every layer, repeat the focused spec command after implementation and show the **Observed GREEN output** result line from that run. Then list Rails specs, system tests, linting, and any browser/manual checks run.
7. **Language** — Must be in English unless explicitly requested otherwise.
=======
6. **Verification** — For every layer, show the Observed GREEN output after implementation per the HARD-GATE. Then list Rails specs, system tests, linting, and any browser/manual checks run.
7. **Language** — Must be in English unless explicitly requested otherwise.
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

## Integration

| Skill | When to chain |
|-------|---------------|
| **apply-code-conventions** | For design principles, structured logging, and path-specific rules |
| **code-review** | When reviewing existing code against these conventions |
| **create-service-object** | When extracting business logic into service objects |
| **write-tests** | For testing conventions and full red/green/refactor TDD cycle |
| **review-architecture** | For structural review beyond conventions |
