---
name: rails-architecture-review
description: >
  Use when reviewing Rails application structure, identifying fat models or controllers,
  auditing callbacks, concerns, service extraction, domain boundaries, or general Rails
  architecture decisions. Recommends service object extractions, simplifies callback
  chains, identifies abstraction quality issues, and produces severity-classified
  findings with the smallest credible improvement for each.
---

# Rails Architecture Review

Use this skill when the task is to review or improve the structure of a Rails application or library.

**Core principle:** Prioritize boundary problems over style. Prefer simple objects and explicit flow over hidden behavior.

## Quick Reference

| Area | What to check |
|------|--------------|
| Controllers | Coordinate only — no domain logic |
| Models | Own persistence + cohesive domain rules, not orchestration |
| Services | Create real boundaries, not just moved code |
| Callbacks | Small and unsurprising — no hidden business logic |
| Concerns | One coherent capability per concern |
| External integrations | Behind dedicated collaborators |

## Review Order

1. Identify the main entry points: controllers, jobs, models, services.
2. Check where domain logic lives.
3. Inspect model responsibilities, callbacks, and associations.
4. Inspect controller size and orchestration.
5. Check concerns, helpers, and presenters for mixed responsibilities.
6. Check whether abstractions clarify the design or only move code around.
7. **Verify each High-severity finding** by reading the actual code — confirm it is a real structural problem, not just a pattern match on file size or line count.

## Severity Levels

### High-Severity Findings

- Business logic hidden in callbacks or broad concerns
- Controllers orchestrating multi-step domain workflows inline
- Models coupled directly to HTTP, jobs, mailers, or external APIs
- Abstractions that add indirection without a clear responsibility
- Cross-layer constant reach that makes code hard to change

### Medium-Severity Findings

- Duplicated workflow logic across controllers or jobs
- Scopes or class methods carrying too much query or policy logic
- Helpers or presenters leaking domain behavior
- Service objects wrapping trivial one-liners
- Concerns combining unrelated responsibilities

## Examples

**High-severity finding (controller doing too much):**

```ruby
# Bad: domain workflow in controller
class OrdersController < ApplicationController
  def create
    order = Order.new(order_params)
    Inventory.check!(order.line_items)
    Pricing.apply_promotions!(order)
    order.save!
    NotifyWarehouseJob.perform_later(order.id)
    redirect_to order
  end
end
```

- **Severity:** High. **Area:** `OrdersController#create`. **Risk:** Controllers should coordinate, not run multi-step domain workflows. **Improvement:** Extract to `Orders::CreateOrder.call(params)` and have the controller call it and handle response/redirect.

**Good (single responsibility):**

```ruby
class OrdersController < ApplicationController
  def create
    result = Orders::CreateOrder.call(order_params)
    result[:success] ? redirect_to(result[:order]) : render(:new, status: :unprocessable_entity)
  end
end
```

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| "Fat model is fine, controllers should be skinny" | Both should be focused — extract to services, not models |
| "One concern per model keeps it clean" | Concerns combining unrelated behavior are worse than inline code |
| "Service objects for everything" | Trivial one-liner wrappers add indirection without value |
| Callbacks for business workflows | Callbacks are persistence-level — use explicit service calls |
| Model with 500+ lines and multiple concerns | Extract domain logic to services or query objects |
| Controller action > 15 lines | Extract to service — controller coordinates, not implements |
| Callback chain triggering jobs, mailers, or external APIs | Move side effects into explicit service calls |
| Concern used by only one class | Just inline it — a single-use concern adds no value |

## Output Style

Write findings first.

For each finding include:

- Severity
- Affected files or area
- Why the structure is risky
- The smallest credible improvement

Then list open assumptions and recommended next refactor steps.

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-boundaries-review** | When the architecture issue is really about bounded contexts, ownership, or language leakage |
| **ddd-rails-modeling** | When the review identifies unclear domain modeling choices inside a context |
| **rails-code-review** | For detailed code-level review after architecture review |
| **refactor-safely** | When architecture review identifies extraction candidates |
| **ruby-service-objects** | When recommending service extraction |
| **rails-security-review** | When architecture review reveals security boundary concerns |
