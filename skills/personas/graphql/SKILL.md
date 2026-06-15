---
name: graphql
type: persona
tags: [personas]
license: MIT
description: >
  Orchestrates end-to-end GraphQL API development across four hard-gated phases: (1) domain modeling — mapping entities→Types, actions→Mutations, with bounded context ownership; (2) schema design — field-level authorization, cursor pagination, and structured error handling; (3) TDD — tests must fail before implementation and full suite must pass after; (4) security review — query depth/complexity limits, rate limiting, N+1 elimination, and error sanitization. Use when building GraphQL APIs, adding GraphQL endpoints, or implementing GraphQL features with proper domain boundaries and security. Trigger: GraphQL API, GraphQL schema, GraphQL mutation, GraphQL query, add GraphQL endpoint, implement GraphQL.
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
# GraphQL Persona

## Agent Phases

### Phase 1: Domain Modeling

**Steps:**
1. Map each domain entity and action to a GraphQL type or mutation, assigning it to a single owning bounded context
2. Document entity relationships as GraphQL connections or nested types with explicit ownership

**Example Domain → Schema Mapping:**

| Domain Concept | GraphQL Construct | Owning Context |
|---|---|---|
| Order (entity) | `Types::OrderType` | Orders |
| Customer (entity) | `Types::CustomerType` | Accounts |
| PlaceOrder (command) | `Mutations::PlaceOrder` | Orders |
| Order.lineItems | `Types::LineItemType` (connection) | Orders |

**HARD GATE — Domain Language:**
- Core GraphQL types and their owning bounded contexts identified
- Entity relationships mapped to GraphQL connections or nested types

**If gate fails:** Return to domain discovery.

---

### Phase 2: Schema Design

**Steps:**
1. Use cursor-based or offset pagination for all list fields — never return unbounded arrays
2. Enforce field-level authorization via `authorized?` on sensitive types and fields (see Phase 4 for the full security checklist)
3. Wrap mutation responses in a result object with a structured `errors` field
4. Validate schema correctness before proceeding

**HARD GATE — Schema Validation:**

Verify schema validity using graphql-ruby's built-in tools:
```ruby
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
module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :customer, Types::CustomerType, null: false
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
1. Write a failing resolver spec, mutation spec, or integration spec targeting the specific graphql-ruby class under test
2. Propose implementation, wait for explicit user approval, then implement the resolver/mutation code
3. Run the full suite to confirm no regressions

**HARD GATE — Test Verification:**
- Test EXISTS and RUNS
- Test FAILS before implementation (correct reason)
- Test PASSES after implementation
- Full test suite PASSES (no regressions)

**Example Resolver Test:**
```ruby
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
```

---

### Phase 4: Security Review

This is the authoritative phase for all authorization and security requirements.

**Steps:**
1. Audit authorization at field level — every sensitive field must have an `authorized?` guard
2. Configure query depth and complexity limits on the schema class
3. Implement rate limiting at the application layer
4. Eliminate N+1 queries using `GraphQL::Batch` or `dataloader`
5. Ensure `rescue_from` on the schema class catches `StandardError` and returns a generic message

**HARD GATE — Security Check:**
- Authorization on all sensitive fields
- Query depth limit configured (recommended: ≤ 10)
- Query complexity limit configured
- Rate limiting implemented
- No N+1 queries in resolvers
- Error messages sanitized

**Example Security Configuration:**
```ruby
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

---

## Error Recovery

| Problem | Remediation |
|---|---|
| Schema validation fails | Check circular references with `MySchema.to_definition`; verify all referenced types are defined |
| Authorization bypass detected | Add `authorized?` to the affected type, write a failing spec, re-run Phase 4 |
| N+1 queries | Identify with `bullet` gem; add `GraphQL::Batch` loader or `dataloader` for the association |

---

## Anti-Patterns

- **God schema:** Use `app/graphql/types/`, `app/graphql/mutations/`, `app/graphql/resolvers/` — not one file
- **Leaking internals:** Never expose ActiveRecord column names directly — map to domain-appropriate field names
- **Fat resolvers:** Extract business logic to service objects; resolvers should only coordinate
