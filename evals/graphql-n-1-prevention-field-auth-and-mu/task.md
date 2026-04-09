# Add GraphQL Order Management API

## Problem/Feature Description

MarketFlow, a B2B marketplace, is building a GraphQL API to allow partner apps to query orders and place new ones on behalf of buyers. The existing REST API is being progressively replaced, and the GraphQL layer needs to expose two capabilities: fetching a list of orders for the current buyer (with pagination support), and placing a new order via a mutation.

The engineering team has run into production issues before with unintended data exposure on shared types — a support agent accidentally saw internal pricing notes through the buyer-facing API because authorization was only applied at the type level, not the field level. There are also performance concerns because initial prototypes loaded associated records one-by-one in resolvers, causing slowdowns with large buyer accounts.

Your task is to implement the following GraphQL components using the `graphql-ruby` gem (assume it is installed):

1. `Types::OrderType` — exposes: `id`, `status`, `total_cents`, `buyer_id`, and `internal_notes` (a sensitive field only visible to admins)
2. `Resolvers::Orders::ListResolver` — returns paginated orders for the current buyer, loading the `buyer` association efficiently
3. `Mutations::PlaceOrder` — accepts `product_id` and `quantity`, delegates to an `Orders::PlaceOrderService`, and returns a structured response
4. Schema-level production hardening (introspection and query limits)

Assume `AppSchema`, `Types::BaseObject`, `Mutations::BaseMutation`, and `context[:current_user]` are already set up. The `Orders::PlaceOrderService` exists and responds to `.call(user:, product_id:, quantity:)` returning an object with `.success?`, `.order`, and `.errors`.

## Output Specification

Produce the following files:

- `app/graphql/types/order_type.rb`
- `app/graphql/resolvers/orders/list_resolver.rb`
- `app/graphql/mutations/place_order.rb`
- `app/graphql/app_schema.rb` — schema class with production hardening applied
- `spec/graphql/mutations/place_order_spec.rb` — RSpec spec using `AppSchema.execute`
- `spec/graphql/resolvers/orders/list_resolver_spec.rb` — RSpec spec
