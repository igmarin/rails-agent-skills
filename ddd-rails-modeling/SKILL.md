---
name: ddd-rails-modeling
description: >
  Use when modeling Domain-Driven Design concepts in a Ruby on Rails codebase.
  Covers Rails-first mapping of entities, aggregates, value objects, domain
  services, application services, repositories, and domain events without
  over-engineering or fighting Rails conventions.
---

# DDD Rails Modeling

Use this skill when the domain concepts are clear enough that the next question is how to model them in Rails.

**Core principle:** Model real domain pressure, not textbook DDD vocabulary.

## Quick Reference

| Concept | Rails-first default |
|---------|---------------------|
| Entity | ActiveRecord model when persisted identity matters |
| Value object | Plain Ruby object near the domain it supports |
| Aggregate root | The main entry point that guards invariants |
| Domain service | PORO for business behavior that does not belong to one entity |
| Application service | Orchestrator in `app/services` coordinating a use case |
| Repository | Use only for a real boundary beyond normal ActiveRecord usage |
| Domain event | Explicit object only when multiple downstream consumers justify it |

## HARD-GATE

```text
DO NOT introduce repositories, aggregates, or domain events just to sound "DDD".
DO NOT fight Rails defaults when a normal model or service expresses the domain clearly.
ALWAYS start from domain invariants, ownership, and lifecycle before choosing a pattern.
```

## When to Use

- A Rails feature has clear domain language but unclear modeling choices.
- The user asks whether something should be a model, value object, service, repository, or event.
- A bounded context is clear and needs tactical design in Rails.
- **Next step:** Chain to `generate-tasks` for implementation planning, or to `rails-tdd-slices` once the first behavior to test is clear.

## Modeling Order

1. **List domain concepts:** Entities, values, policies, workflows, and events from the ubiquitous language.
2. **Identify invariants:** Decide which object or boundary must keep each rule true.
3. **Choose the aggregate entry point:** Name the object that should guard state transitions and consistency.
4. **Place behavior:** Keep behavior on the entity/aggregate when cohesive; extract a domain service only when behavior spans multiple concepts cleanly.
5. **Pick Rails homes:** Choose the simplest location that matches the boundary and repo conventions.
6. **Verify with tests:** Hand off to `rails-tdd-slices` and `rspec-best-practices` before implementation.

## Rails-First Mapping

| Need | Prefer | Avoid by default |
|------|--------|------------------|
| Persisted concept with identity | ActiveRecord model | Extra wrapper object with no added meaning |
| Small immutable calculation or policy value | PORO value object | Shoving all logic into helpers or primitives |
| Use-case orchestration | Application service in `app/services` | Fat controller or callback chains |
| Cross-entity business rule | Domain service | Picking an arbitrary model just to hold the code |
| Complex query / persistence abstraction | Repository only if boundary is real | Creating repositories for every query |
| Multi-consumer business signal | Explicit domain event | Callback-driven hidden side effects |

## Suggested Rails Homes

| Modeling choice | Typical home |
|-----------------|--------------|
| Aggregate / entity | `app/models/...` |
| Application or domain service | `app/services/...` |
| Value object | `app/models/...` or nearby PORO location used by the repo |
| Policy / rule object | `app/services/...`, `app/policies/...`, or project convention |
| Domain event object | `app/events/...` or project-specific namespace if the repo already uses events |

## Output Style

When using this skill, return:

1. **Domain concept**
2. **Recommended modeling choice**
3. **Suggested Rails home**
4. **Invariant or ownership reason**
5. **Patterns to avoid**
6. **Next skill to chain**

## Examples

### Good: Value Object

```ruby
# Money or ReservationWindow carries behavior and invariants
# but does not need its own database identity.
```

- **Modeling choice:** Value object
- **Suggested home:** PORO near the domain it supports

### Good: Application Service

```ruby
# Orders::CreateOrder coordinates inventory, pricing, persistence,
# and follow-up side effects for one use case.
```

- **Modeling choice:** Application service
- **Suggested home:** `app/services/orders/create_order.rb`

### Bad: Cargo-Cult DDD

```ruby
# Bad move:
# Add repositories, command handlers, and domain events
# when a normal model + service already expresses the use case cleanly.
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Turning every concept into a service | Many behaviors belong naturally on entities or value objects |
| Creating repositories for all reads and writes | ActiveRecord already gives a strong default persistence boundary |
| Treating aggregates as folder names only | Aggregates exist to protect invariants, not to look architectural |
| Adding domain events for one local callback | Events should justify their coordination cost |
| Forgetting Rails conventions entirely | DDD should sharpen Rails design, not replace it wholesale |

## Red Flags

- Pattern choice is justified only with "DDD says so"
- The same invariant is enforced from several unrelated entry points
- New abstractions increase indirection without clarifying ownership
- Primitive obsession still exists, but modeling is focused on folders instead of concepts

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | When the terms are not clear enough to model yet |
| **ddd-boundaries-review** | When the modeling problem is really a context boundary problem |
| **generate-tasks** | After the tactical design is clear and ready for implementation planning |
| **rails-tdd-slices** | When the next step is choosing the best first failing spec |
| **rails-principles-and-boundaries** | When validating the modeling choice against Rails simplicity and repo conventions |
