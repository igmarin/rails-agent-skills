---
name: apply-stack-conventions
type: atomic
license: MIT
description: >
  Use when writing new Rails code (Ruby on Rails) for the PostgreSQL + Hotwire + Tailwind stack, including TDD (test-driven development), write-tests-first, or red-green-refactor workflows — must write specs and validate them RED BEFORE implementation, verify they pass GREEN after, show spec file content (not just spec path), include a Tests-first proof before implementation section showing actual spec code, the run command (bundle exec rspec spec/[path]_spec.rb), and the Observed RED output and Observed GREEN output labels, keeping steps testable in isolation. MVC structure, ActiveRecord queries, Turbo Frames/Streams, Stimulus controllers, and Tailwind patterns. Not for general Rails design principles — scoped to this specific stack.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Apply Stack Conventions

## Quick Reference

| Stack area | Default convention |
|------------|------------------|
| Rails MVC | Thin controllers; move non-trivial business logic into service objects |
| PostgreSQL | Avoid N+1s with `includes`; use database constraints for integrity |
| Hotwire | Prefer Turbo Frames/Streams before Stimulus; only reach for Stimulus when Turbo cannot handle the interactivity |
| Tailwind | Use utilities in views; extract repeated UI into partials/components |
| Auth | Apply Devise authentication and Pundit authorization to every action that touches access-controlled resources |

## HARD-GATE: TDD Cycle

All new code **must** have its test written and validated **before** implementation. Follow this exact cycle for every layer:

1. Write the spec file — show the full file content, not only the path
2. Run: `bundle exec rspec spec/[path]_spec.rb` — verify it **FAILS** (**Observed RED output**)
3. Write the implementation code
4. Re-run the same command — verify it **PASSES** (**Observed GREEN output**)
5. Refactor if needed, keeping tests green

**CRITICAL:** Execute all test commands using your shell/terminal tools. Do **not** fabricate, mock, or simulate terminal output. Copy-paste the actual observed output. If the environment does not support running tests, stop and tell the user — do not proceed to implementation without verified RED output.

### Red-Green Cycle Example

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

**Observed RED output** — paste actual terminal output here (expect failure)

**Model implementation — `app/models/order.rb`**

```ruby
class Order < ApplicationRecord
  validates :total, presence: true
end
```

**Observed GREEN output** — paste actual terminal output here (expect pass)

## Core Process

Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

**Style:** If the project uses a linter, treat it as the source of truth for formatting. For cross-cutting design principles (DRY, YAGNI, structured logging, rules by directory), use **apply-code-conventions**.

### Feature Development Workflow

For a typical feature, compose stack patterns in this order:

1. **Model** — add validations, associations, scopes; eager-load with `includes` for any association used in loops
2. **Service object** — extract non-trivial business logic from the controller (see **create-service-object**)
3. **Controller** — keep actions thin; delegate to services; respond with `turbo_stream` and `html` formats
4. **View / Turbo wiring** — wrap dynamic sections in `<turbo-frame>` tags; broadcast `turbo_stream` responses from the controller
5. **Stimulus** — add a controller only when client-side interactivity cannot be handled by Turbo alone
6. **Tailwind** — apply utility classes to the view; extract repeated patterns into partials or Stimulus targets

Each step should remain testable in isolation before wiring to the next layer. In the final artifact, include a **Layer isolation** section naming the focused spec or check for model/query, service, controller/request, view/Turbo, Stimulus, and Tailwind. If a layer is not changed, mark it "not applicable"; do not silently omit any layer.

### Service Object Pattern

Controllers delegate to a service via `.call`; the service returns a result hash. See **create-service-object** and `assets/snippets/service_object.rb` for the full pattern and implementation details.

```ruby
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

For eager loading patterns and N+1 fixes, see the Extended Resources section below.

### Pitfalls to Avoid

| Issue | Correct approach |
|-------|------------------|
| Controller action with 15+ lines of business logic | Extract to a service object using the `.call` pattern |
| Accessing a protected resource without an authorisation check | Apply a Pundit policy on every action that touches access-controlled data |

## Output Style

Every response **must** include these sections in order:

1. **Stack decisions** — which Rails, PostgreSQL, Hotwire, Stimulus, Tailwind, auth, and service-object conventions apply.
2. **Tests-first proof before implementation** — follow the HARD-GATE cycle per layer (spec file content → RED output → implementation → GREEN output).
3. **Layer isolation** — focused spec/check for each changed layer; mark unchanged layers "not applicable".
4. **Layered implementation** — separate model/query, service, controller, view, Stimulus, and Tailwind changes.
5. **Performance and security checks** — N+1 prevention, authorization policy use, unsafe params/content handling.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/snippets/eager_loading.rb](assets/snippets/eager_loading.rb)** — Use when applying eager loading patterns to fix N+1 queries
- **[assets/snippets/n_plus_one_fix_example.rb](assets/snippets/n_plus_one_fix_example.rb)** — Use when you need a complete N+1 fix example with before/after
- **[assets/snippets/service_object.rb](assets/snippets/service_object.rb)** — Use when extracting controller logic into a service object
- **[assets/snippets/turbo_frame.html.erb](assets/snippets/turbo_frame.html.erb)** — Use when implementing Turbo Frame patterns
- **[assets/snippets/stimulus_controller.js](assets/snippets/stimulus_controller.js)** — Use when adding Stimulus controllers
- **[assets/snippets/tailwind_component.html.erb](assets/snippets/tailwind_component.html.erb)** — Use when building Tailwind-styled view components

## Integration

| Skill | When to chain |
|-------|---------------|
| **apply-code-conventions** | For design principles, structured logging, and path-specific rules |
| **code-review** | When reviewing existing code against these conventions |
| **create-service-object** | When extracting business logic into service objects |
| **write-tests** | For testing conventions and full red/green/refactor TDD cycle |
| **review-architecture** | For structural review beyond conventions |
