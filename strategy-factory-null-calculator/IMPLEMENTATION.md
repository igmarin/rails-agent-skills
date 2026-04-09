# Implementation Reference

## BaseService

```ruby
# frozen_string_literal: true

module PricingCalculator
  class BaseService
    def initialize(order)
      @order = order
    end

    def calculate
      return nil unless should_calculate?
      compute_result(@order.base_price)
    end

    private

    def should_calculate? = @order.plan&.active?
    def compute_result(_price) = nil
  end
end
```

## NullService

```ruby
# frozen_string_literal: true

module PricingCalculator
  class NullService < BaseService
    private

    def should_calculate? = false
  end
end
```

## Concrete Service Example

```ruby
# frozen_string_literal: true

module PricingCalculator
  class StandardPricingService < BaseService
    DISCOUNT = 0.10

    private

    def should_calculate?
      super && @order.plan.name == 'standard'
    end

    def compute_result(base_price)
      base_price * (1 - DISCOUNT)
    end
  end
end
```
