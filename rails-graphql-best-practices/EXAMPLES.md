# GraphQL Best Practices — Complete Example

A complete, copy-ready reference covering every required pattern. All examples use an `Orders` domain.

---

## 1. Type with Descriptions and Connection Type

Every class, field, and argument must have a `description`. Paginated lists use `.connection_type` — never a plain array.

```ruby
# app/graphql/types/order_type.rb
# frozen_string_literal: true

module Types
  class OrderType < Types::BaseObject
    description "A customer order containing one or more line items."

    field :id,          ID,      null: false, description: "Unique identifier."
    field :status,      String,  null: false, description: "Current status: pending, confirmed, shipped, delivered."
    field :total_cents, Integer, null: false, description: "Order total in cents."
    field :buyer,       Types::UserType, null: true, description: "The user who placed the order."
  end
end
```

```ruby
# app/graphql/types/query_type.rb
# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description "Root query type."

    # connection_type — REQUIRED for paginated lists. Never use [Types::OrderType].
    field :orders, Types::OrderType.connection_type, null: false,
          description: "Paginated list of orders for the current user.",
          resolver: Resolvers::Orders::ListResolver
  end
end
```

---

## 2. Resolver with Dataloader (N+1 Prevention)

Never load an association directly on `object`. Use `dataloader.with(Sources::RecordById, Model).load(foreign_key)`.

```ruby
# app/graphql/resolvers/orders/list_resolver.rb
# frozen_string_literal: true

module Resolvers
  module Orders
    class ListResolver < Resolvers::BaseResolver
      description "Returns paginated orders for the authenticated user."

      type Types::OrderType.connection_type, null: false

      def resolve
        context[:current_user].orders.order(created_at: :desc)
      end
    end
  end
end
```

```ruby
# app/graphql/types/order_type.rb — buyer field uses dataloader
field :buyer, Types::UserType, null: true, description: "The user who placed the order."

def buyer
  # CORRECT: batch-loads users — no N+1
  dataloader.with(Sources::RecordById, User).load(object.user_id)
end
```

```ruby
# app/graphql/sources/record_by_id.rb
# frozen_string_literal: true

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

---

## 3. Field-Level Authorization (Not Type-Level Alone)

Type-level authorization is insufficient — sensitive fields need their own guard:

```ruby
# app/graphql/types/order_type.rb
field :internal_notes, String, null: true,
      description: "Internal fulfillment notes — visible to admins only." do
  # field-level guard — runs even if type-level auth passes
  guard -> (_obj, _args, ctx) { ctx[:current_user]&.admin? }
end

field :payment_reference, String, null: true,
      description: "Payment provider reference ID — restricted to finance team." do
  guard -> (_obj, _args, ctx) { ctx[:current_user]&.finance? }
end
```

---

## 4. Mutation with Errors Array and Rescue

Mutations always return `{ result_field, errors: [String] }`. Never let an exception propagate unhandled to the client.

```ruby
# app/graphql/mutations/create_order.rb
# frozen_string_literal: true

module Mutations
  class CreateOrder < Mutations::BaseMutation
    description "Creates a new order for the authenticated user."

    argument :product_id, ID,      required: true, description: "ID of the product to order."
    argument :quantity,   Integer, required: true, description: "Number of units."

    field :order,  Types::OrderType, null: true,  description: "The created order, or nil on failure."
    field :errors, [String],         null: false,  description: "Validation or processing errors."

    def resolve(product_id:, quantity:)
      result = Orders::CreateOrder.call(
        user:       context[:current_user],
        product_id: product_id,
        quantity:   quantity
      )

      if result[:success]
        { order: result[:response][:order], errors: [] }
      else
        { order: nil, errors: Array(result[:response][:errors]) }
      end
    rescue ActiveRecord::RecordInvalid => e
      { order: nil, errors: e.record.errors.full_messages }
    rescue StandardError => e
      Rails.logger.error("Mutations::CreateOrder failed: #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      { order: nil, errors: ["An unexpected error occurred"] }
    end
  end
end
```

---

## 5. Schema Safeguards

```ruby
# app/graphql/app_schema.rb
# frozen_string_literal: true

class AppSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Dataloader

  # Disable introspection in production — prevents schema enumeration
  disable_introspection_entry_points if Rails.env.production?

  # Protect against deeply nested / expensive queries
  max_depth 10
  max_complexity 300
end
```

---

## 6. Spec Using AppSchema.execute

```ruby
# spec/graphql/mutations/create_order_spec.rb
# frozen_string_literal: true

RSpec.describe "Mutations::CreateOrder" do
  let(:user)    { create(:user) }
  let(:product) { create(:product, stock: 5) }

  let(:query) do
    <<~GQL
      mutation CreateOrder($productId: ID!, $quantity: Int!) {
        createOrder(input: { productId: $productId, quantity: $quantity }) {
          order { id status }
          errors
        }
      }
    GQL
  end

  subject(:result) do
    AppSchema.execute(query,
                      variables: { productId: product.id, quantity: 1 },
                      context:   { current_user: user })
  end

  it "creates the order" do
    expect(result.dig("data", "createOrder", "errors")).to be_empty
    expect(result.dig("data", "createOrder", "order", "id")).to be_present
  end

  context "when unauthenticated" do
    subject(:result) do
      AppSchema.execute(query, variables: { productId: product.id, quantity: 1 })
    end

    it "returns an authorization error" do
      expect(result["errors"]).not_to be_empty
    end
  end

  context "when product is out of stock" do
    before { product.update!(stock: 0) }

    it "returns errors and no order" do
      expect(result.dig("data", "createOrder", "order")).to be_nil
      expect(result.dig("data", "createOrder", "errors")).not_to be_empty
    end
  end
end
```

---

## Pattern Checklist (use before shipping)

| Check | Pattern | Where above |
|-------|---------|-------------|
| `description` on every type and field | `description "..."` on class + each `field` | Sections 1, 3, 4 |
| Paginated list uses `connection_type` | `Types::OrderType.connection_type` | Section 1 |
| Association loads use dataloader | `dataloader.with(Sources::RecordById, Model).load(fk)` | Section 2 |
| `Sources::RecordById` defined | `class Sources::RecordById < GraphQL::Dataloader::Source` | Section 2 |
| Sensitive fields have field-level guard | `guard -> (_obj, _args, ctx) { ctx[:current_user]&.role? }` | Section 3 |
| Mutation returns `errors` array | `field :errors, [String], null: false` | Section 4 |
| Mutation rescues StandardError | `rescue StandardError => e` with logger | Section 4 |
| Introspection disabled in production | `disable_introspection_entry_points if Rails.env.production?` | Section 5 |
| `max_depth` and `max_complexity` set | `max_depth 10` / `max_complexity 300` | Section 5 |
| Specs use `AppSchema.execute` | Not controller/request dispatch | Section 6 |
