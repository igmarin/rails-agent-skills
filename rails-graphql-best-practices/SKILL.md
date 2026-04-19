---
name: rails-graphql-best-practices
description: >
  Use when building or reviewing GraphQL APIs in Rails with the graphql-ruby gem.
  Covers schema design, N+1 prevention with dataloaders, field-level auth, query
  limits, error handling, and testing resolvers/mutations with RSpec.
---

# Rails GraphQL Best Practices

Use this skill when **designing, implementing, or reviewing GraphQL APIs** in a Rails application with the `graphql-ruby` gem.

## HARD-GATE

```text
Tests gate implementation — write specs before resolver code (see rspec-best-practices).
Before shipping a resolver/mutation slice, ALL of the following must be true (details in linked sections; do not duplicate checks in prose here):
- N+1 Prevention: use `dataloader.with(Source, Model).load(id)` — NEVER `object.association`
- Authorization: sensitive fields have field-level guards (not type-level alone).
- Type Conventions: paginated collections use Types::*Type.connection_type, not plain arrays.
- Schema safeguards: AppSchema disables introspection in production and sets max_depth / max_complexity.
- TESTING.md: specs in `spec/graphql/` use `AppSchema.execute` — **ALL spec files** (resolver specs AND mutation specs). Never use HTTP controller dispatch for GraphQL specs.
- Error Handling: mutations return `{ result, errors }` with rescue blocks — no unhandled exceptions.
- Documentation: `description:` on every field in every type.
- Resolver Structure: dedicated resolver classes, not inline field blocks.
```

## Workflow: Adding a New Resolver or Mutation

```text
1. SPEC:       Write failing spec (happy path + auth + validation error case) — see TESTING.md
2. TYPE:       Arguments and return types — Type Conventions for pagination shape
3. IMPLEMENT:  Resolver/mutation class delegating to a service object
4. N+1 CHECK:  N+1 Prevention (dataloader on every association load from GraphQL)
5. AUTH CHECK: Authorization (field-level guards where data is sensitive)
6. FINAL CHECK: Verify every HARD-GATE item above against the code you wrote — all 8 must be true
7. RUN:        Full suite green before PR
```

**DO NOT proceed to step 3 before step 1 is written and failing.**

## Schema Design

### Type Conventions

- Match type and field names to domain language — do not leak internal model names.
- **Paginated collections:** use `connection_type`, never a plain array of nodes.

```ruby
field :orders, Types::OrderType.connection_type, null: false, resolver: Resolvers::Orders::ListResolver
```

### Resolver Structure

- Prefer **dedicated resolver classes** over inline field blocks for non-trivial logic.
- Keep `QueryType` and `MutationType` as entry points only — delegate: `field :summary, resolver: Resolvers::Orders::SummaryResolver`.

## N+1 Prevention

### Detection

- Enable `bullet` gem in development — treat GraphQL N+1s as **Critical** severity.
- Assert query counts with `expect { }.to make_database_queries(count: N)` using `db-query-matchers`.

### Resolution

**FORBIDDEN:** Never call `object.buyer`, `object.user`, or any association directly — every association load MUST use the dataloader (graphql-ruby 1.12+):

```ruby
# ❌ causes N+1 for every record in the list
def buyer; object.buyer; end

# ✅ batches loads across all records
def buyer
  dataloader.with(Sources::RecordById, Buyer).load(object.buyer_id)
end
```

**List resolvers MUST ALSO use the dataloader** — even when the resolver returns a list of root records, any association each list item will expose must be preloaded through the dataloader, not via `.includes` on the scope or `object.association` in the type. If the list shape is `List<Order>` and `Order` exposes `buyer`, the ListResolver loads `buyer` via `dataloader.with(...).load(...)` on each record (or through a batch source):

```ruby
# app/graphql/resolvers/orders/list_resolver.rb
class Resolvers::Orders::ListResolver < Resolvers::BaseResolver
  type Types::OrderType.connection_type, null: false

  def resolve
    orders = Order.for_user(context[:current_user])
    orders.each { |order| dataloader.with(Sources::RecordById, Buyer).load(order.buyer_id) }
    orders
  end
end
```

Rule: in a ListResolver, **never** call `.includes(:buyer)` or `object.buyer` — the dataloader is the ONLY sanctioned association load path from GraphQL, regardless of whether the field lives on the type or in the resolver.

**Source class definition:**

```ruby
# app/graphql/sources/record_by_id.rb
class Sources::RecordById < GraphQL::Dataloader::Source
  def initialize(model_class)
    @model_class = model_class
  end

  def fetch(ids)
    records = @model_class.where(id: ids).index_by(&:id)
    ids.map { |id| records[id] }
  end
end
```

## Authorization

### Field-Level Authorization

Type-level auth alone is insufficient — add field-level guards for sensitive fields:

```ruby
field :internal_notes, String, null: true do
  guard -> (_obj, _args, ctx) { ctx[:current_user]&.admin? }
end
```

For Pundit: `authorize! object, to: :read?, with: OrderPolicy` in the resolver's `resolve` method.

## Schema safeguards

Configure **production introspection** and **query limits** on `AppSchema` in one place:

```ruby
class AppSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?

  max_depth 10
  max_complexity 300
end
```

Adjust depth/complexity to your API; document the chosen limits in the PR or schema comments if non-default.

## Error Handling

Mutations must return a structured response — never raise unhandled exceptions to the client:

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
  rescue StandardError => e
    Rails.logger.error("Mutation failed: #{e.class}: #{e.message}")
    { order: nil, errors: ['An unexpected error occurred'] }
  end
end
```

## Testing

See [TESTING.md](./TESTING.md) for the spec template, paths, and checklist (happy path, unauthenticated, unauthorized, validation `errors`, N+1 counts, limits).

## Documentation

Write `description:` inline on **every** field in every type — no field left undescribed:

```ruby
class Types::OrderType < Types::BaseObject
  description "A customer order containing one or more line items."

  field :id, ID, null: false, description: "Unique identifier."
  field :status, String, null: false, description: "Current order status: pending, confirmed, shipped, delivered."
  field :total_cents, Integer, null: false, description: "Total order amount in cents."
end
```

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | Type and field naming must match business language |
| **rails-tdd-slices** | Choose first failing spec (mutation vs query vs resolver unit) |
| **rspec-best-practices** | Full TDD cycle for resolvers and mutations |
| **rails-security-review** | Auth, introspection disable, query depth/complexity limits |
