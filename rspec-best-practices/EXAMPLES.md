# RSpec Examples

Executable spec patterns for common Rails scenarios.

## Request Spec (endpoint behavior)

```ruby
# spec/requests/orders/create_spec.rb
RSpec.describe 'POST /orders', type: :request do
  let(:product) { create(:product, stock: 5) }

  context 'when product is in stock' do
    it 'creates the order and returns 201' do
      post orders_path, params: { order: { product_id: product.id, quantity: 1 } }, as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body['id']).to be_present
    end
  end

  context 'when product is out of stock' do
    before { product.update!(stock: 0) }

    it 'returns 422 with an error message' do
      post orders_path, params: { order: { product_id: product.id, quantity: 1 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['error']).to eq('Out of stock')
    end
  end
end
```

## Model Spec (domain rule)

```ruby
# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  describe '#total_price' do
    it 'sums line item prices' do
      order = build(:order, line_items: [
        build(:line_item, price: 10, quantity: 2),
        build(:line_item, price: 5,  quantity: 3)
      ])
      expect(order.total_price).to eq(35)
    end
  end

  describe 'validations' do
    it 'is invalid without a product' do
      order = build(:order, product: nil)
      expect(order).not_to be_valid
      expect(order.errors[:product]).to include("can't be blank")
    end
  end
end
```

## Service Spec (orchestration flow)

```ruby
# spec/services/orders/create_order_spec.rb
RSpec.describe Orders::CreateOrder do
  describe '.call' do
    let(:user)    { create(:user) }
    let(:product) { create(:product, stock: 5) }

    it 'returns success with the new order' do
      result = described_class.call(user: user, product_id: product.id, quantity: 1)
      expect(result[:success]).to be true
      expect(result[:order]).to be_persisted
    end

    context 'when out of stock' do
      before { product.update!(stock: 0) }

      it 'returns failure with an error message' do
        result = described_class.call(user: user, product_id: product.id, quantity: 1)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Out of stock')
      end
    end
  end
end
```

## Time-Dependent Spec (travel_to)

```ruby
# spec/models/subscription_spec.rb
RSpec.describe Subscription, type: :model do
  describe '#expired?' do
    let(:subscription) { create(:subscription, expires_at: 30.days.from_now) }

    context 'before expiration' do
      it 'is not expired' do
        travel_to 29.days.from_now do
          expect(subscription).not_to be_expired
        end
      end
    end

    context 'after expiration' do
      it 'is expired' do
        travel_to 31.days.from_now do
          expect(subscription).to be_expired
        end
      end
    end
  end
end
```

## Shared Examples

```ruby
# spec/support/shared_examples/successful_response.rb
RSpec.shared_examples 'a successful response' do |status: :ok|
  it "returns #{status}" do
    expect(response).to have_http_status(status)
  end

  it 'returns JSON' do
    expect(response.content_type).to match(%r{application/json})
  end
end

# Usage
RSpec.describe 'GET /products', type: :request do
  before { get products_path, as: :json }

  include_examples 'a successful response', status: :ok
end
```
