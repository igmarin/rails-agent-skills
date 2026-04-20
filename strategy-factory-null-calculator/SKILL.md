---
name: strategy-factory-null-calculator
description: >
  Use when building variant-based calculators with a single entry point that
  picks the right implementation (Strategy + Factory), or when adding a no-op
  fallback (Null Object). Generates variant-based calculator classes, implements
  SERVICE_MAP routing, and scaffolds RSpec tests per variant. Trigger words:
  design pattern, Ruby, dispatch table, polymorphism, no-op default, variant
  calculator, strategy pattern, factory pattern, null object pattern.
---

# Strategy + Factory + Null Object Calculator Pattern

One API for the client: `Calculator::Factory.for(entity).calculate`. The factory picks the strategy; NullService handles unknown variants safely.

## HARD-GATE: Tests Gate Implementation

For each component (Factory → BaseService → NullService → Concrete):
1. Write the spec — contexts per variant, plus the NullService path
2. Run it — verify it fails because the component does not exist yet
3. Implement the component — minimum code to make the spec pass
4. Run again — confirm green, then proceed to the next component

## Quick Reference

| Component | Responsibility |
|-----------|---------------|
| **Factory** | Dispatch to correct service class via SERVICE_MAP; fall back to NullService |
| **BaseService** | Guard with `should_calculate?`; delegate to `compute_result` |
| **NullService** | Always returns nil safely — never raises |
| **Concrete** | Override `should_calculate?` (add variant check on top of `super`) and `compute_result` |

## File Structure

```
app/services/<calculator_name>/
├── factory.rb
├── base_service.rb
├── null_service.rb
├── standard_service.rb
├── premium_service.rb
```

## 1. Factory

```ruby
# frozen_string_literal: true

module PricingCalculator
  class Factory
    SERVICE_MAP = {
      'standard' => StandardPricingService,
      'premium'  => PremiumPricingService
    }.freeze

    def self.for(order)
      plan = order.plan
      return NullService.new(order) unless plan&.active?

      service_class = SERVICE_MAP[plan.name] || NullService
      service_class.new(order)
    end
  end
end
```

No qualifying context or unknown variant → `NullService`. For full BaseService and NullService implementations, see [IMPLEMENTATION.md](./IMPLEMENTATION.md).

## 2. Usage

```ruby
price = PricingCalculator::Factory.for(order).calculate
```

**Single entry point rule:** `Factory.for(entity)` is the **only** permitted access path. Clients never instantiate service classes directly. If you see `StandardPricingService.new(order)` outside of `Factory`, that is a bug — route through the factory.

## 3. Tests (RSpec)

**Factory dispatch (all branches):**

```ruby
RSpec.describe PricingCalculator::Factory do
  describe '.for' do
    it 'returns NullService when plan is nil' do
      order = create(:order, plan: nil)
      expect(described_class.for(order)).to be_a(PricingCalculator::NullService)
    end

    it 'returns StandardPricingService for standard plan' do
      order = create(:order, plan: create(:plan, name: 'standard', active: true))
      expect(described_class.for(order)).to be_a(PricingCalculator::StandardPricingService)
    end
  end
end
```

Cover inactive plan, each variant, and unknown variant. See [TESTING.md](./TESTING.md) for NullService and concrete service specs.

## Pitfalls

| Pitfall | Fix |
|---------|-----|
| SERVICE_MAP key mismatch | Verify keys match exactly what is stored in the database — typos cause silent NullService fallbacks |
| Missing NullService spec | Always add a spec context for unknown/nil variants or tests will never catch the fallback regression |
| Direct service instantiation (`ServiceClass.new(entity)`) | Route through `Factory.for(entity)` — it is the sole public entry point; direct instantiation bypasses the NullService safety net |

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-service-testing** | For complete Factory, BaseService, NullService, and concrete strategy specs |
| **ruby-service-objects** | For naming conventions, YARD docs, and `frozen_string_literal` baseline |

## Assets

- [assets/examples.md](assets/examples.md)
