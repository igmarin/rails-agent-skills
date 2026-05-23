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
  dependencies: "define-domain-language, implement-graphql, security-check, write-tests"
  keywords: rails, graphql, api, ddd, domain, security, tdd, schema
---
# GraphQL Agent

Orchestrates systematic GraphQL API development with Domain-Driven Design principles, ensuring proper domain boundaries, type-safe schemas, TDD implementation, and security best practices.

## When to Use

- Building new GraphQL APIs from scratch
- Adding GraphQL endpoints to existing Rails application
- Implementing GraphQL mutations or queries
- Designing GraphQL schemas with domain modeling
- Adding GraphQL features to Rails projects
- Migrating REST APIs to GraphQL

## Agent Phases

### Phase 1: Domain Modeling

**Objective:** Establish clear domain language and boundaries before designing GraphQL schema.

**Steps:**
1. **skills/ddd/define-domain-language** — Define ubiquitous language for the GraphQL domain
2. **Domain Boundaries** — Identify bounded contexts and aggregate boundaries
3. **Entity Mapping** — Map domain entities to GraphQL types and relationships

**HARD GATE — Domain Language:**
- Core domain terms defined and documented
- Bounded contexts identified
- Entity relationships mapped
- Language consistent across team

**If gate fails:** Return to domain discovery. GraphQL schema without clear domain model will be inconsistent.

**Example Domain Language:**
```markdown
# GraphQL API Domain Language

## Core Terms
- **Order:** Represents a customer's purchase request
- **LineItem:** Individual product within an order
- **Customer:** User who places orders
- **Product:** Catalog item available for purchase

## Relationships
- Order has_many LineItems
- Order belongs_to Customer
- LineItem belongs_to Product
- Customer has_many Orders

## Bounded Contexts
- Order Context (orders, line items)
- Catalog Context (products)
- Customer Context (customers, authentication)
```

---

### Phase 2: Schema Design

**Objective:** Design GraphQL schema that reflects domain model and follows best practices.

**Steps:**
1. **Schema Planning** — Design types, queries, mutations based on domain model
2. **skills/api/implement-graphql** — Implement GraphQL schema with graphql-ruby
3. **Schema Validation** — Ensure schema is valid, non-circular, and follows conventions

**Schema Design Guidelines:**
- Use GraphQL type system to enforce domain boundaries
- Design queries for read operations, mutations for write operations
- Implement proper authorization at field level
- Use pagination for list fields (cursor-based or offset-based)
- Include error handling in mutation responses

**HARD GATE — Schema Validation:**
```bash
bundle exec rails graphql:validate
```

- Schema is valid GraphQL
- No circular type references
- All types have proper fields and arguments
- Authorization rules defined for sensitive fields

**If gate fails:** Fix schema validation errors before proceeding to implementation.

**Example Schema Structure:**
```ruby
# app/graphql/types/order_type.rb
module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :customer, Types::CustomerType, null: false
    field :line_items, [Types::LineItemType], null: false
    field :total, Float, null: false
    field :status, String, null: false

    # Authorization
    def self.authorized?(object, context)
      context[:current_user].can_read?(object)
    end
  end
end
```

---

### Phase 3: TDD Implementation

**Objective:** Implement resolvers and mutations using TDD discipline.

### TDD Enforcement for GraphQL

**Before implementing any resolver/mutation:**
1. **testing/plan-tests** — Choose test type:
   - Resolver specs for individual field resolution
   - Mutation specs for write operations
   - Integration specs for end-to-end queries
2. **testing/write-tests** — Write failing test for resolver/mutation
3. **Test Verification** — Confirm test FAILS for right reason (functionality missing, not syntax error)
4. **Implementation Proposal** — Propose resolver/mutation implementation
5. **User Approval** — Wait for explicit confirmation
6. **Implement** — Write resolver/mutation code
7. **Verify PASS** — Run test to confirm it passes
8. **Regression Check** — Run full test suite

**HARD GATE — Test Verification:**
- Test EXISTS and RUNS
- Test FAILS for correct reason before implementation
- Test PASSES after implementation
- Full test suite PASSES (no regressions)

**If test fails for wrong reason:** Fix test (not implementation) to accurately test intended behavior.

**Example Resolver Test:**
```ruby
# spec/graphql/resolvers/order_resolver_spec.rb
RSpec.describe Resolvers::OrderResolver do
  let(:current_user) { create(:user) }
  let(:order) { create(:order, customer: current_user) }

  it 'returns order for authorized user' do
    result = described_class.new(object: nil, context: { current_user: }).resolve(id: order.id)
    expect(result).to eq(order)
  end

  it 'returns nil for unauthorized user' do
    unauthorized_user = create(:user)
    result = described_class.new(object: nil, context: { current_user: unauthorized_user }).resolve(id: order.id)
    expect(result).to be_nil
  end
end
```

**Example Resolver Implementation:**
```ruby
# app/graphql/resolvers/order_resolver.rb
module Resolvers
  class OrderResolver < GraphQL::Schema::Resolver
    type Types::OrderType, null: true
    argument :id, ID, required: true

    def resolve(id:)
      Order.find_by(id: id).tap do |order|
        raise GraphQL::ExecutionError, "Not authorized" unless order&.customer == context[:current_user]
      end
    end
  end
end
```

---

### Phase 4: Security Review

**Objective:** Ensure GraphQL API follows security best practices.

**Steps:**
1. **skills/code-quality/security-check** — Security audit focused on GraphQL concerns:
   - Authorization at field level
   - Query depth limiting
   - Query complexity analysis
   - Rate limiting
   - Input validation and sanitization
2. **N+1 Query Prevention** — Use dataloaders or batch loading
3. **Error Handling** — Ensure proper error messages without information leakage

**HARD GATE — Security Check:**
- Authorization implemented on all sensitive fields
- Query depth limits configured (recommended: < 10 levels)
- Query complexity limits configured
- Rate limiting implemented
- No N+1 queries in resolvers
- Error messages don't leak sensitive information

**If gate fails:** Address security vulnerabilities before deploying GraphQL API.

**Example Security Configuration:**
```ruby
# app/graphql/schema.rb
class MySchema < GraphQL::Schema
  use GraphQL::Batch
  use GraphQL::Guard

  query Types::QueryType
  mutation Types::MutationType

  # Query depth limiting
  max_depth 10

  # Query complexity
  max_complexity 100

  # Error handling
  rescue_from(StandardError) do |err|
    raise GraphQL::ExecutionError, "An error occurred"
  end
end
```

---

## Integration

| Predecessor | This Agent | Successor |
|-------------|---------------|-----------|
| create-prd | graphql | tdd |
| define-domain-language | graphql | security-check |
| None (standalone) | graphql | quality |

## When to Use This vs. Individual Skills

- **Full GraphQL API development (all phases):** Use this agent
- **Only design schema:** Use `implement-graphql`
- **Only define domain language:** Use `define-domain-language`
- **Only security review:** Use `security-check`
- **Not sure if GraphQL is right choice:** Use `skill-router`

## HARD-GATE: Security Before Deployment

**NEVER deploy GraphQL API before:**
- Domain language clearly defined
- Schema validated and documented
- All resolvers/mutations have passing tests
- Authorization implemented on sensitive fields
- Query depth and complexity limits configured
- N+1 queries eliminated
- Error handling properly configured

**If gate fails:** GraphQL API is not production-ready. Address security issues.

## Output Style

```markdown
# GraphQL API Report — [Date]

## Domain Model
- **Core Terms:** Order, LineItem, Customer, Product
- **Bounded Contexts:** Order, Catalog, Customer
- **Relationships:** Mapped and documented

## Schema
- **Types:** 12 types defined
- **Queries:** 8 queries implemented
- **Mutations:** 5 mutations implemented
- **Validation:** ✓ PASS

## Implementation
- **Resolver Tests:** 8/8 passing
- **Mutation Tests:** 5/5 passing
- **Integration Tests:** 3/3 passing
- **Total Coverage:** 94%

## Security Review
- **Authorization:** ✓ Implemented on all sensitive fields
- **Query Depth Limit:** ✓ Configured (max 10)
- **Query Complexity:** ✓ Configured (max 100)
- **Rate Limiting:** ✓ Implemented
- **N+1 Queries:** ✓ None detected
- **Error Handling:** ✓ Properly configured

## Status
**PRODUCTION READY** — All security checks passed
```

## Anti-Patterns to Avoid

- **Schema without domain:** Never design GraphQL schema without clear domain model
- **Authorization bypass:** Never implement GraphQL without field-level authorization
- **Unlimited queries:** Always configure query depth and complexity limits
- **N+1 queries:** Use dataloaders or batch loading to avoid N+1 in resolvers
- **Information leakage:** Ensure error messages don't expose sensitive information
- **Skipping security:** Never deploy GraphQL API without security review