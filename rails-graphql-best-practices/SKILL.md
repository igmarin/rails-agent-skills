---
name: rails-graphql-best-practices
description: >
  Use when building or reviewing GraphQL APIs in Rails with the graphql-ruby gem.
  Covers schema design, N+1 prevention with dataloaders, field-level auth, query
  limits, error handling, and testing resolvers/mutations with RSpec.
---

# Rails GraphQL Best Practices

Use this skill when **designing, implementing, or reviewing GraphQL APIs** in a Rails application with the `graphql-ruby` gem.

**Core principle:** GraphQL shifts validation and security responsibility to the resolver layer. Every field, type, and mutation needs explicit attention to authorization, N+1 risk, and error shape.

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
DO NOT add a new resolver or mutation without N+1 analysis.
DO NOT rely solely on type-level authorization — add field-level auth for sensitive fields.
ALWAYS disable introspection in production.
ALWAYS set max_depth and max_complexity on the schema.
Tests gate implementation — write specs before resolver code (see rspec-best-practices).
```

## Schema Design

### Type Conventions

- Name types in **PascalCase** matching the domain language (e.g. `OrderType`, not `ApiOrderType`)
- Match type field names to domain terms from the ubiquitous language — no leaking of internal model names
- Use **connection types** (Relay-style) for all paginated collections — never return a raw array for lists that could grow

```ruby
# BAD — raw array, no cursor-based pagination
field :orders, [Types::OrderType], null: false

# GOOD — connection type enables cursor pagination
field :orders, Types::OrderType.connection_type, null: false
```

### Resolver Structure

- Prefer **dedicated resolver classes** over inline field blocks for non-trivial logic
- Keep `QueryType` and `MutationType` as entry points only — delegate to resolver objects

```ruby
# BAD — business logic inline in the type
field :summary, String, null: false do
  def resolve
    object.line_items.sum(&:total)  # N+1 risk, logic buried in type
  end
end

# GOOD — resolver object handles logic and receives preloaded data
field :summary, resolver: Resolvers::Orders::SummaryResolver
```

### Interface and Union Types

- Use **Interface** when multiple types share fields and behavior
- Use **Union** when a field can return one of several unrelated types (e.g. search results)
- Prefer neither over a simple type unless there is real polymorphism — do not over-engineer

## N+1 Prevention

N+1 in GraphQL is critical: a single query can trigger hundreds of DB calls invisibly.

### Detection

- Enable `bullet` gem in development — treat GraphQL N+1s as **Critical** severity
- Test with `expect { }.to make_database_queries(count: N)` using the `db-query-matchers` gem

### Resolution

Use `dataloader` (built into graphql-ruby 1.12+) or `graphql-batch`:

```ruby
# BAD — N+1: one query per order
def resolve
  object.user  # called for every order in the list
end

# GOOD — batch loads all users in one query
def resolve
  dataloader.with(Sources::RecordById, User).load(object.user_id)
end
```

**Rule:** If a resolver calls an ActiveRecord association on `object`, it must go through a dataloader source.

## Authorization

### Field-Level Authorization

Type-level authorization alone is **not sufficient**. Add field-level checks for sensitive data:

```ruby
# Type-level only — insufficient
class Types::UserType < Types::BaseObject
  guard -> (obj, args, ctx) { ctx[:current_user].admin? }  # blocks the whole type
  field :email, String, null: false  # still accessible if user type is reused elsewhere
  field :internal_notes, String, null: true  # sensitive — needs its own guard
end

# GOOD — field-level guard on sensitive fields
field :internal_notes, String, null: true do
  guard -> (obj, args, ctx) { ctx[:current_user].admin? }
end
```

### Pundit Integration

Use Pundit policies for consistent authorization:

```ruby
def resolve
  authorize! object, to: :read?, with: OrderPolicy
  # ... resolver logic
end
```

### Production Introspection

Always disable introspection in production — it exposes the full schema to attackers:

```ruby
# config/initializers/graphql.rb (or in schema definition)
class AppSchema < GraphQL::Schema
  if Rails.env.production?
    disable_introspection_entry_points
  end
end
```

## Query Limits

Always set explicit depth and complexity limits on the schema:

```ruby
class AppSchema < GraphQL::Schema
  max_depth 10
  max_complexity 300
end
```

Default to conservative limits and increase only when there is a documented reason.

## Error Handling

### Mutation Response Shape

Mutations must return a structured response — never raise unhandled exceptions:

```ruby
# Standard mutation return type
class Types::Mutations::CreateOrderPayload < Types::BaseObject
  field :order, Types::OrderType, null: true
  field :errors, [String], null: false
end

# Mutation implementation
class Mutations::CreateOrder < Mutations::BaseMutation
  argument :product_id, ID, required: true
  argument :quantity, Integer, required: true

  type Types::Mutations::CreateOrderPayload

  def resolve(product_id:, quantity:)
    result = Orders::CreateOrder.call(
      user: context[:current_user],
      product_id: product_id,
      quantity: quantity
    )

    if result.success?
      { order: result.order, errors: [] }
    else
      { order: nil, errors: result.errors }
    end
  rescue ActiveRecord::RecordInvalid => e
    { order: nil, errors: e.record.errors.full_messages }
  end
end
```

**Rules:**
- `errors` field is always present and always an array
- On success: `{ result: <object>, errors: [] }`
- On failure: `{ result: nil, errors: ["..."] }`
- System errors (unexpected exceptions) should be rescued at the schema level, not per-mutation

## Performance

- Set `max_depth` and `max_complexity` on every schema (see Query Limits above)
- In production, use **persisted queries** (query IDs sent from clients) to prevent arbitrary query execution
- Add APM tracing on resolver execution — for Datadog: use `GraphQL::Tracing::DataDogTracing`; for OpenTelemetry: use `GraphQL::Tracing::OpenTelemetryTracing`

## Testing

### Spec Structure

```ruby
# spec/graphql/mutations/create_order_spec.rb
RSpec.describe "Mutations::CreateOrder", type: :request do
  let(:user)    { create(:user) }
  let(:product) { create(:product, stock: 5) }
  let(:query) do
    <<~GQL
      mutation CreateOrder($productId: ID!, $quantity: Int!) {
        createOrder(input: { productId: $productId, quantity: $quantity }) {
          order { id }
          errors
        }
      }
    GQL
  end

  subject(:result) do
    AppSchema.execute(query, variables: { productId: product.id, quantity: 1 },
                              context: { current_user: user })
  end

  it "creates an order" do
    expect(result.dig("data", "createOrder", "errors")).to be_empty
    expect(result.dig("data", "createOrder", "order", "id")).to be_present
  end
end
```

### What to Always Test

- **Happy path** — successful query/mutation
- **Authorization** — unauthenticated (no context user), unauthorized (wrong role)
- **Validation errors** — mutation returns errors array, not exception
- **N+1** — use query count matchers for resolvers with associations
- **Depth/complexity limits** — a query exceeding limits returns an error, not data

### Spec Paths

| Test type | Suggested path |
|-----------|----------------|
| Query resolvers | `spec/graphql/queries/..._spec.rb` |
| Mutations | `spec/graphql/mutations/..._spec.rb` |
| Types | `spec/graphql/types/..._spec.rb` (only if type has custom logic) |
| Resolver objects | `spec/graphql/resolvers/..._spec.rb` |

## Documentation

GraphQL schemas are self-documenting — leverage it fully:

- Write `description` on **every** type, field, argument, and mutation
- Descriptions render in GraphQL Playground / Insomnia automatically
- YARD on resolver Ruby classes (public methods only)

```ruby
class Types::OrderType < Types::BaseObject
  description "A customer order containing one or more line items."

  field :id, ID, null: false, description: "Unique identifier."
  field :status, String, null: false, description: "Current order status: pending, confirmed, shipped, delivered."
  field :total_cents, Integer, null: false, description: "Total order amount in cents."
end
```

**API Documentation tooling for GraphQL:**
- Prefer **Insomnia** or **GraphQL Playground** over Postman for GraphQL endpoints
- Postman REST collections do not map cleanly to GraphQL queries/mutations
- See `api-rest-collection` for notes on this distinction

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Type-level auth is enough | Field-level auth is required for sensitive fields — types are reused |
| Raw arrays for list fields | Use connection types — raw arrays cannot be paginated |
| Resolvers call associations directly | Every association load needs a batch loader to prevent N+1 |
| Mutations raise on validation errors | Mutations must return `{ result, errors }` — never raise from user input |
| Introspection left on in production | Exposes full schema — always disable in production |
| Missing `max_depth` / `max_complexity` | Allows denial-of-service via deeply nested queries |
| Using Postman collections for GraphQL | Use Insomnia or GraphQL Playground — better native support |

## Red Flags

- A resolver calls `object.association` without a dataloader
- Mutation raises `ActiveRecord::RecordInvalid` instead of returning errors array
- No `description` on type fields (schema self-documentation incomplete)
- `disable_introspection_entry_points` not present in production schema
- `max_depth` or `max_complexity` not set
- Authorization check only at query root, not on individual sensitive fields
- No authorization tests (unauthenticated and unauthorized cases)

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | Type and field naming must match business language |
| **rails-tdd-slices** | Choose first failing spec (mutation spec vs query spec vs resolver unit) |
| **rspec-best-practices** | Full TDD cycle for resolvers and mutations |
| **rails-migration-safety** | When GraphQL schema changes require DB migrations |
| **rails-code-conventions** | Per-area rules for resolver classes, models, services |
| **rails-security-review** | Auth, introspection disable, query depth/complexity limits |
| **yard-documentation** | Document resolver Ruby classes |
| **api-rest-collection** | Note: prefer Insomnia or GraphQL Playground for GraphQL endpoints |
