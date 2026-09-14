# Refactor-safely examples

## 1) Characterization test for a presenter

```ruby
RSpec.describe OrderPresenter do
  it 'formats totals as currency' do
    order = build_stubbed(:order, total_cents: 12345)
    expect(OrderPresenter.new(order).formatted_total).to eq('$123.45')
  end
end
```

## 2) Safe extract example

Before:

```ruby
def index
  @rows = expensive_query.map { |r| transform(r) }
end
```

After (extract):

```ruby
def index
  @rows = Presentation::RowsBuilder.build(expensive_query)
end
```

## 3) Rollback plan

- If tests fail after refactor, revert commit, examine failing characterization tests, and extract smaller unit of work.
