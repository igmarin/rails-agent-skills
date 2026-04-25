---
name: ddd-rails-modeling
license: MIT
description: >
  Use when modeling Domain-Driven Design concepts in a Ruby on Rails codebase.
  Covers Rails-first mapping of entities, aggregates, value objects, domain
  services, application services, repositories, and domain events without
  over-engineering or fighting Rails conventions.
license: MIT
---

# DDD Rails Modeling

**Core principle:** Model real domain pressure, not textbook DDD vocabulary.

## HARD-GATE

```text
DO NOT introduce repositories, aggregates, or domain events just to sound "DDD".
DO NOT fight Rails defaults when a normal model or service expresses the domain clearly.
ALWAYS start from domain invariants, ownership, and lifecycle before choosing a pattern.
```

## Modeling Order

1. **List domain concepts:** Entities, values, policies, workflows, and events from the ubiquitous language.
2. **Identify invariants:** Decide which object or boundary must keep each rule true.
3. **Choose the aggregate entry point:** Name the object that guards state transitions and consistency.
4. **Place behavior:** Keep behavior on the entity/aggregate when cohesive; extract a domain service only when behavior spans multiple concepts cleanly.
5. **Pick Rails homes:** Choose the simplest location that matches the boundary and repo conventions.
6. **Verify with tests:** Hand off to `rails-tdd-slices` and `rspec-best-practices` before implementation.

## Rails-First Mapping

| DDD concept | Rails-first default | Avoid by default | Typical home |
|-------------|---------------------|------------------|--------------|
| Entity | ActiveRecord model when persisted identity matters | Extra wrapper object with no added meaning | `app/models/` |
| Value object | PORO — immutable, equality by value | Shoving logic into helpers or primitives | `app/models/` or near the domain |
| Aggregate root | The model that guards invariants and is the single entry point | Splitting invariants across multiple models | `app/models/` |
| Domain service | PORO for behavior spanning multiple entities | Arbitrary model chosen just to hold code | `app/services/` |
| Application service | Orchestrator for one use case | Fat controller or callback chains | `app/services/` |
| Repository | Only when a real persistence boundary exists beyond ActiveRecord | Repositories for every query | `app/repositories/` (rare) |
| Domain event | Explicit object when multiple downstream consumers justify it | Callback-driven hidden side effects | `app/events/` or project namespace |

## Output Style

When using this skill, return for each domain concept:

1. **Domain concept** — name from the ubiquitous language
2. **Recommended modeling choice** — entity, value object, service, etc.
3. **Suggested Rails home** — file path
4. **Invariant or ownership reason** — why this boundary
5. **Patterns to avoid** — what not to reach for
6. **Next skill to chain** — `generate-tasks`, `rails-tdd-slices`, etc.

## Examples

### Value Object — Money

```ruby
# app/models/money.rb
class Money
  attr_reader :amount_cents, :currency

  def initialize(amount_cents, currency = "USD")
    @amount_cents = Integer(amount_cents)
    @currency = currency.upcase.freeze
    freeze
  end

  def ==(other)
    other.is_a?(Money) && amount_cents == other.amount_cents && currency == other.currency
  end

  alias eql? ==

  def hash
    [amount_cents, currency].hash
  end
end
```

- **Modeling choice:** Value object — equality by value, immutable, no database identity needed.
- **Suggested home:** `app/models/money.rb`
- **Avoid:** Adding `belongs_to` or a database table — this is a calculation value, not an entity.

### Application Service — CreateOrder

```ruby
# app/services/orders/create_order.rb
module Orders
  class CreateOrder
    Result = Struct.new(:success?, :order, :errors, keyword_init: true)

    def self.call(**args) = new(**args).call

    def initialize(user:, product_id:, quantity:)
      @user, @product_id, @quantity = user, product_id, quantity
    end

    def call
      order = @user.orders.build(product: Product.find(@product_id), quantity: @quantity)
      order.save ? Result.new(success?: true, order: order, errors: [])
                 : Result.new(success?: false, order: nil, errors: order.errors.full_messages)
    rescue ActiveRecord::RecordNotFound
      Result.new(success?: false, order: nil, errors: ["Product not found"])
    end
  end
end
```

- **Modeling choice:** Application service — coordinates persistence and follows up side effects for one use case.
- **Suggested home:** `app/services/orders/create_order.rb`
- **Avoid:** Fat controller method or a callback chain on `Order`.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Turning every concept into a service | Many behaviors belong naturally on entities or value objects |
| Creating repositories for all reads and writes | ActiveRecord already provides a strong default persistence boundary |
| Treating aggregates as folder names only | Aggregates exist to protect invariants, not to look architectural |
| Adding domain events for one local callback | Events justify their cost only when multiple downstream consumers exist |
| Pattern choice justified only with "DDD says so" | The reason must be an invariant, ownership boundary, or clear coordination need |
| Same invariant enforced from multiple unrelated entry points | Single aggregate root guards state transitions — one entry point per invariant |
| New abstractions that increase indirection without clarifying ownership | If the boundary is unclear after modeling, the abstraction is premature |

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | When the terms are not clear enough to model yet |
| **ddd-boundaries-review** | When the modeling problem is really a context boundary problem |
| **generate-tasks** | After the tactical design is clear and ready for implementation planning |
| **rails-tdd-slices** | When the next step is choosing the best first failing spec |
| **rails-code-conventions** | When validating the modeling choice against Rails simplicity and repo conventions |

## Assets

- [assets/examples.md](assets/examples.md)
- [assets/modeling_template.md](assets/modeling_template.md)
