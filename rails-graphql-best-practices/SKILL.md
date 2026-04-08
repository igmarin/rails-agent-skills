---
name: rails-graphql-best-practices
description: >
  Use when building or reviewing GraphQL APIs in Rails with the graphql-ruby gem.
  Covers schema design, N+1 prevention with dataloaders, field-level auth, query
  limits, error handling, and testing resolvers/mutations with RSpec.
---

# Rails GraphQL Best Practices

Use this skill when **designing, implementing, or reviewing GraphQL APIs** in a Rails application with the `graphql-ruby` gem.

## Quick Reference

| Topic | Rule |
|-------|------|
| Type naming | PascalCase, match domain language from `ddd-ubiquitous-language` |
| Mutations | Return `{ result, errors }` — never raise from a mutation |
| N+1 | Every association load in a resolver must use a dataloader or batch loader |
| Authorization | Field-level auth required — type-level auth is not sufficient |
| Production | Disable introspection; set `max_depth` and `max_complexity` |
| Testing | Use `schema.execute` in request or integration specs |
| Docs | Write `description` on every type, field, argument, and mutation |

## HARD-GATE

```text
Tests gate implementation — write specs before resolver code (see rspec-best-practices).
DO NOT add a new resolver or mutation without completing the N+1 analysis step below.
DO NOT rely solely on type-level authorization — see Authorization section.
```

## Workflow: Adding a New Resolver or Mutation

```text
1. SPEC:      Write failing spec (happy path + auth cases + validation error case)
2. TYPE:      Define argument and return types
3. IMPLEMENT: Write resolver or mutation class — delegate logic to a service object
4. N+1 CHECK: Verify every association load goes through a dataloader source
5. AUTH CHECK: Confirm field-level guards on all sensitive fields
6. RUN:       All new specs pass; run full suite before opening PR
```

**DO NOT proceed to step 3 before step 1 is written and failing.**

## Schema Design

### Type Conventions

- Match type names and field names to domain language — do not leak internal model names
- Use connection types for all paginated collections: `field :orders, Types::OrderType.connection_type, null: false`

### Resolver Structure

- Prefer **dedicated resolver classes** over inline field blocks for non-trivial logic
- Keep `QueryType` and `MutationType` as entry points only — delegate to resolver objects: `field :summary, resolver: Resolvers::Orders::SummaryResolver`

## N+1 Prevention

### Detection

- Enable `bullet` gem in development — treat GraphQL N+1s as **Critical** severity
- Assert query counts with `expect { }.to make_database_queries(count: N)` using `db-query-matchers`

### Resolution

Use `dataloader` (built into graphql-ruby 1.12+) or `graphql-batch`:

```ruby
# BAD — one query per record
def resolve = object.user

# GOOD — single batched query
def resolve
  dataloader.with(Sources::RecordById, User).load(object.user_id)
end
```

**Rule:** If a resolver calls an ActiveRecord association on `object`, it must go through a dataloader source.

## Authorization

### Field-Level Authorization

Type-level authorization is **not sufficient**. Add field-level checks for sensitive fields:

```ruby
# Type-level only — insufficient when the type is reused elsewhere
class Types::UserType < Types::BaseObject
  guard -> (obj, args, ctx) { ctx[:current_user].admin? }
  field :email, String, null: false
  field :internal_notes, String, null: true  # sensitive — needs its own guard
end

# GOOD — field-level guard on sensitive fields
field :internal_notes, String, null: true do
  guard -> (obj, args, ctx) { ctx[:current_user].admin? }
end
```

### Pundit Integration

```ruby
def resolve
  authorize! object, to: :read?, with: OrderPolicy
  # ... resolver logic
end
```

### Production Introspection

```ruby
class AppSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?
end
```

## Query Limits

```ruby
class AppSchema < GraphQL::Schema
  max_depth 10
  max_complexity 300
end
```

## Error Handling

Mutations must return a structured response — never raise unhandled exceptions:

```ruby
class Mutations::CreateOrder < Mutations::BaseMutation
  argument :product_id, ID, required: true

  field :order, Types::OrderType, null: true
  field :errors, [String], null: false

  def resolve(product_id:)
    result = Orders::CreateOrder.call(user: context[:current_user], product_id: product_id)
    result.success? ? { order: result.order, errors: [] } : { order: nil, errors: result.errors }
  rescue ActiveRecord::RecordInvalid => e
    { order: nil, errors: e.record.errors.full_messages }
  end
end
```

**Shape contract:** `errors` is always present and always an array. System errors are rescued at the schema level, not per-mutation.

## Performance

- Use **persisted queries** in production to prevent arbitrary query execution
- Add APM tracing on resolver execution (Datadog: `GraphQL::Tracing::DataDogTracing`; OpenTelemetry: `GraphQL::Tracing::OpenTelemetryTracing`)

## Testing

Always test: happy path, unauthenticated, unauthorized, validation errors returning the errors array (not exceptions), N+1 via query count matchers, and depth/complexity limits.

See [TESTING.md](./TESTING.md) for a complete spec template, spec paths, and the full test checklist.

## Documentation

Write `description` on every type, field, argument, and mutation — GraphQL schemas are self-documenting:

```ruby
class Types::OrderType < Types::BaseObject
  description "A customer order containing one or more line items."

  field :id, ID, null: false, description: "Unique identifier."
  field :status, String, null: false, description: "Current order status: pending, confirmed, shipped, delivered."
  field :total_cents, Integer, null: false, description: "Total order amount in cents."
end
```

Prefer **Insomnia** or **GraphQL Playground** over Postman for GraphQL endpoints — see `api-rest-collection`.

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | Type and field naming must match business language |
| **rails-tdd-slices** | Choose first failing spec (mutation vs query vs resolver unit) |
| **rspec-best-practices** | Full TDD cycle for resolvers and mutations |
| **rails-security-review** | Auth, introspection disable, query depth/complexity limits |
