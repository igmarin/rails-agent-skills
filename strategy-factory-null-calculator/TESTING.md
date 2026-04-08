# Strategy + Factory + Null Object — RSpec Examples

## Factory Spec (all dispatch branches)

```ruby
RSpec.describe PricingCalculator::Factory do
  describe '.for' do
    let(:order) { create(:order) }

    context 'when plan is nil' do
      before { order.update!(plan: nil) }
      it { expect(described_class.for(order)).to be_a(PricingCalculator::NullService) }
    end

    context 'when plan is inactive' do
      before { order.plan.update!(active: false) }
      it { expect(described_class.for(order)).to be_a(PricingCalculator::NullService) }
    end

    context 'when plan is standard' do
      before { order.plan.update!(name: 'standard', active: true) }
      it { expect(described_class.for(order)).to be_a(PricingCalculator::StandardPricingService) }
    end

    context 'when plan name is unknown' do
      before { order.plan.update!(name: 'enterprise', active: true) }
      it { expect(described_class.for(order)).to be_a(PricingCalculator::NullService) }
    end
  end
end
```

## NullService Spec

```ruby
RSpec.describe PricingCalculator::NullService do
  let(:order) { create(:order) }

  it 'always returns nil' do
    expect(described_class.new(order).calculate).to be_nil
  end
end
```

## Concrete Service Spec

```ruby
RSpec.describe PricingCalculator::StandardPricingService do
  let(:order) { create(:order, :with_standard_plan, base_price: 100) }

  describe '#calculate' do
    it 'returns the discounted price for standard plans' do
      expect(described_class.new(order).calculate).to eq(90)
    end

    context 'when plan is inactive' do
      before { order.plan.update!(active: false) }
      it { expect(described_class.new(order).calculate).to be_nil }
    end
  end
end
```
