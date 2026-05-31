---
name: graphql
license: MIT
description: >
  Orchestrates end-to-end GraphQL API development with DDD principles: domain modeling → schema design → TDD implementation → security review. Use when building GraphQL APIs, adding GraphQL endpoints, or implementing GraphQL features with proper domain boundaries and security. Trigger: GraphQL API, GraphQL schema, GraphQL mutation, GraphQL query, add GraphQL endpoint, implement GraphQL.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when building GraphQL APIs or implementing GraphQL features with proper domain boundaries and security"
  phases: "Phase 1: Domain Modeling, Phase 2: Schema Design, Phase 3: TDD Implementation, Phase 4: Security Review"
  hard_gates: "Domain Language Defined, Schema Validated, Tests Pass, Security Check"
  dependencies:
    - source: self
      skills: [implement-graphql, security-check, load-context]
    - source: ruby-core-skills
      skills: [define-domain-language, tdd-process, write-yard-docs]
  keywords: rails, graphql, api, ddd, domain, security, tdd, schema
---
# GraphQL Agent

## Agent Phases

### Phase 1: Domain Modeling

**Steps:**
1. Map entities → Types, actions → Mutations, read paths → Queries (e.g. `Order` entity → `OrderType`, `placeOrder` action → `PlaceOrderMutation`, order lookup → `orderQuery`)
2. Assign each type to a bounded context and define which context owns and exposes it

**HARD GATE — Domain Language:**
- Core GraphQL types and their owning bounded contexts identified
- Entity relationships mapped to GraphQL connections or nested types

**If gate fails:** Return to domain discovery.

---

### Phase 2: Schema Design

**Steps:**
1. Design types, queries, and mutations based on the domain model
2. Implement schema with graphql-ruby
3. Validate schema correctness

**Schema Design Guidelines:**
- Implement authorization at field level
- Use cursor-based or offset pagination for list fields
- Include structured error handling in mutation responses

**HARD GATE — Schema Validation:**

Verify schema validity using graphql-ruby's built-in tools:
```ruby
# lib/tasks/graphql.rake
namespace :graphql do
  task validate: :environment do
    puts MySchema.to_definition
    puts "Schema valid."
  end
end
```
```bash
bundle exec rake graphql:validate
```

- No circular type references
- All types have proper fields and arguments
- Authorization rules defined for sensitive fields

**Example Type:**
```ruby
# app/graphql/types/order_type.rb
module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :customer, Types::CustomerType, null: false
    field :line_items, [Types::LineItemType], null: false
    field :total, Float, null: false
    field :status, String, null: false

    def self.authorized?(object, context)
      context[:current_user].can_read?(object)
    end
  end
end
```

---

### Phase 3: TDD Implementation

**For every resolver or mutation:**
1. Write a failing test (resolver spec, mutation spec, or integration spec)
2. Confirm the test FAILS for the right reason (missing functionality, not syntax error)
3. Propose implementation and wait for explicit user approval
4. Implement resolver/mutation code
5. Confirm test PASSES, then run full suite to check for regressions

**HARD GATE — Test Verification:**
- Test EXISTS and RUNS
- Test FAILS before implementation (correct reason)
- Test PASSES after implementation
- Full test suite PASSES (no regressions)

> If a test fails for the wrong reason, fix the test (not the implementation) to accurately reflect intended behavior.

**Example Resolver Test + Implementation:**
```ruby
# spec/graphql/resolvers/order_resolver_spec.rb
RSpec.describe Resolvers::OrderResolver do
  let(:user) { create(:user) }
  let(:order) { create(:order, customer: user) }

  it 'returns order for authorized user' do
    result = described_class.new(object: nil, context: { current_user: user }).resolve(id: order.id)
    expect(result).to eq(order)
  end

  it 'returns nil for unauthorized user' do
    result = described_class.new(object: nil, context: { current_user: create(:user) }).resolve(id: order.id)
    expect(result).to be_nil
  end
end

# app/graphql/resolvers/order_resolver.rb
module Resolvers
  class OrderResolver < GraphQL::Schema::Resolver
    type Types::OrderType, null: true
    argument :id, ID, required: true

    def resolve(id:)
      order = Order.find_by(id: id)
      raise GraphQL::ExecutionError, "Not authorized" unless order&.customer == context[:current_user]
      order
    end
  end
end
```

---

### Phase 4: Security Review

**Steps:**
1. Audit authorization at field level — every sensitive field must have an `authorized?` guard
2. Configure query depth and complexity limits on the schema class
3. Implement rate limiting at the application layer
4. Eliminate N+1 queries using `GraphQL::Batch` or `dataloader` — use `graphql-ruby`'s built-in dataloader or `batch-loader` gem for associations
5. Ensure `rescue_from` on the schema class catches `StandardError` and returns a generic message, preventing stack traces or model details from leaking

**HARD GATE — Security Check:**
- Authorization on all sensitive fields
- Query depth limit configured (recommended: ≤ 10)
- Query complexity limit configured
- Rate limiting implemented
- No N+1 queries in resolvers
- Error messages sanitized

**Example Security Configuration:**
```ruby
# app/graphql/schema.rb
class MySchema < GraphQL::Schema
  use GraphQL::Batch

  query Types::QueryType
  mutation Types::MutationType

  max_depth 10
  max_complexity 100

  rescue_from(StandardError) do |err|
    raise GraphQL::ExecutionError, "An error occurred"
  end
end
```
