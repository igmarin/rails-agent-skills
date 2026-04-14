# strategy-factory-null-calculator examples

1) Factory usage example (Ruby)

```ruby
calculator = StrategyFactory.for(account: account)
result = calculator.calculate(amount: 1000)
```

2) Null calculator behavior

NullCalculator returns zeroed results and never raises, safe to use as fallback:

```
{ value: 0, breakdown: {}, warnings: [] }
```

3) Lookup order
- The factory tries strategies in `lookup_order` and falls back to `null_calculator` if none match.
