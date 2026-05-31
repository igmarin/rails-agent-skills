# Complete Example: Refactor Code Task (answer.md)

Use this complete, production-ready example to format your output when asked to perform a safe refactoring of Rails code.

***

# Plan

1. **Define Stable Behavior**: Identify the exact inputs and outputs of the block under refactoring and write the stable behavior statement.
2. **Adapter/Facade/Wrapper Decision**: Explicitly state why no transitional shim is needed (or define one if changing public API).
3. **Write Characterization Spec**: Write a request or model spec covering the current logic and confirm it passes.
4. **Execute Refactoring Step-by-Step**:
   - **Step A**: Extract the domain logic to a new Service Object PORO.
   - **Step B**: Replace the logic inside the controller with a call to the new Service Object.
5. **Verify After Every Step**: Run the focused spec and record the output.
6. **Final Suite Verification**: Run the entire test suite to ensure zero regressions.

***

# Stable Behavior & Interface

* **Inputs**: POST requests to `/orders` with parameter structure: `{ order: { product_id: Integer, quantity: Integer } }`.
* **Outputs**: Order record persisted, database count changed by +1, warehouse email job enqueued, and user redirected to the order page.
* **Transitional Interface (Shim Decision)**: Since the public HTTP endpoint signature and parameters remain unchanged, **no transitional facade or adapter shim is required**. The controller's public action interface is kept stable throughout.

***

# Step 1: Characterization Spec (Before Refactor)

`# spec/requests/orders_spec.rb`
```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Orders creation current behavior", type: :request do
  describe "POST /orders" do
    let(:valid_params) { { order: { product_id: 1, quantity: 2 } } }

    it "creates order and enqueues warehouse notification" do
      expect { post orders_path, params: valid_params }
        .to change(Order, :count).by(1)
      expect(NotifyWarehouseJob).to have_been_enqueued
    end
  end
end
```

**Verification Run Command:**
```bash
bundle exec rspec spec/requests/orders_spec.rb
```

**Observed output**
```text
.

Finished in 0.01524 seconds (files took 1.12 seconds to load)
1 example, 0 failures
```

***

# Step 2: Implement Extracted Service Object

`# app/services/orders/create_order.rb`
```ruby
# frozen_string_literal: true

module Orders
  class CreateOrder
    def self.call(params:)
      order = Order.new(params)
      if order.save
        NotifyWarehouseJob.perform_later(order.id)
        { success: true, order: order }
      else
        { success: false, order: order }
      end
    end
  end
end
```

`# spec/services/orders/create_order_spec.rb`
```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::CreateOrder do
  describe '.call' do
    let(:params) { { product_id: 1, quantity: 2 } }
    subject(:result) { described_class.call(params: params) }

    it "creates the order record" do
      expect { result }.to change(Order, :count).by(1)
    end
  end
end
```

**Verification Run Command:**
```bash
bundle exec rspec spec/services/orders/create_order_spec.rb
```

**Observed output**
```text
.

Finished in 0.01021 seconds (files took 1.10 seconds to load)
1 example, 0 failures
```

***

# Step 3: Update Controller to Call Service

`# app/controllers/orders_controller.rb`
```ruby
# frozen_string_literal: true

class OrdersController < ApplicationController
  def create
    result = Orders::CreateOrder.call(params: order_params)
    if result[:success]
      redirect_to order_path(result[:order]), notice: 'Order created.'
    else
      @order = result[:order]
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:product_id, :quantity)
  end
end
```

**Verification Run Command:**
```bash
bundle exec rspec spec/requests/orders_spec.rb
```

**Observed output**
```text
.

Finished in 0.01633 seconds (files took 1.14 seconds to load)
1 example, 0 failures
```

***

# Step 4: Final Suite Run Verification

**Verification Run Command:**
```bash
bundle exec rspec
```

**Observed output**
```text
....................................

Finished in 0.45120 seconds (files took 1.50 seconds to load)
36 examples, 0 failures
```

***

# Verification & Quality Gates

| Check Level | Command | Status |
| :--- | :--- | :--- |
| **Characterization Spec** | `bundle exec rspec spec/requests/orders_spec.rb` | `1 example, 0 failures` |
| **Extracted Service Spec** | `bundle exec rspec spec/services/orders/create_order_spec.rb` | `1 example, 0 failures` |
| **Broader Suite** | `bundle exec rspec` | `36 examples, 0 failures` |
| **Code Linter** | `bundle exec rubocop app/controllers/orders_controller.rb app/services/orders/create_order.rb` | `no offenses detected` |

***

# Assumptions

1. **Test Environment**: Assumes the local database is migrated and factory records exist for standard runs.
2. **Behavior Match**: Assumes the extracted service behaves identically to the original inline controller logic.
3. **Execution**: The verification runs are executed against a standard Rails 7.x/8.x setup with zero pending migrations.

***

# Quality Gate Checklist

- [x] Characterization tests pass on current code
- [x] Behavior-preserving refactoring executed step-by-step
- [x] Verification run after every step
- [x] Full test suite green after final step
