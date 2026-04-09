# GraphQL Testing Reference

## Spec Template

```ruby
# spec/graphql/mutations/create_order_spec.rb
RSpec.describe "Mutations::CreateOrder" do
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

  context "when unauthenticated" do
    subject(:result) { AppSchema.execute(query, variables: { productId: product.id, quantity: 1 }) }

    it "returns an authorization error" do
      expect(result["errors"]).not_to be_empty
    end
  end
end
```

Call `AppSchema.execute` directly in GraphQL specs. Do not route these checks through controller/request dispatch when the behavior under test is schema, resolver, authorization, or mutation response shape.

## What to Always Test

- **Happy path** — successful query/mutation
- **Authorization** — unauthenticated (no context user), unauthorized (wrong role)
- **Validation errors** — mutation returns errors array, not exception
- **N+1** — query count matchers for resolvers with associations
- **Depth/complexity limits** — exceeding limits returns an error, not data

## Spec Paths

| Test type | Suggested path |
|-----------|----------------|
| Query resolvers | `spec/graphql/queries/..._spec.rb` |
| Mutations | `spec/graphql/mutations/..._spec.rb` |
| Types | `spec/graphql/types/..._spec.rb` (only if type has custom logic) |
| Resolver objects | `spec/graphql/resolvers/..._spec.rb` |
