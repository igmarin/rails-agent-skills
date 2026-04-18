---
name: rails-engine-extraction
description: >
  Use when extracting existing Rails app code into a reusable engine. Scaffolds the
  engine structure, moves POROs/services/controllers incrementally, creates adapter
  interfaces to decouple host dependencies, and verifies regression coverage throughout
  each extraction slice. Trigger words: extract to engine, move feature to engine,
  host coupling, adapters, extraction slices, preserve behavior, incremental extraction,
  bounded feature.
---
# Rails Engine Extraction

Use this skill when the task is to move existing code out of a Rails app and into an engine.

Prefer incremental extraction over big-bang rewrites. Preserve behavior first, then improve design.

## HARD-GATE

**DO NOT extract and change behavior in the same step.** Extraction must preserve existing behavior; refactoring and improvements belong in a separate step after the move is complete and verified.

## Extraction Order

1. Identify the bounded feature to extract — one coherent responsibility.
2. List hard dependencies on the host app (models, services, config).
3. Define the future engine boundary and host contract.
4. Move stable domain logic first: POROs, services, value objects, policies, query objects. Delay direct host model references, authentication, route ownership, and asset integration.
5. Add adapters or configuration seams for host-owned dependencies. Replace hardcoded host references with config values, adapter objects, or service interfaces.
6. Move controllers, routes, views, or jobs only after seams are clear.
7. Keep regression coverage green throughout each slice.

Each slice must have: one coherent responsibility, minimal new public API, passing regression tests, and a clear next step.

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Extracting too much at once | One bounded slice per step; large extractions hide bugs and are hard to revert |
| Direct host references in engine | Use adapters or config; direct constants couple engine to host internals |
| Behavior changes mixed with extraction | Preserve behavior first; refactor only after the move is verified |
| Circular dependencies introduced | Verify import graph before moving each slice |
| Dummy app passes but host contract is implicit | Explicitly document and test the host app contract |

## Examples

**First slice (move PORO, no host model yet):**

```bash
# Move the file into the engine and adjust the namespace
mkdir -p my_engine/app/services/my_engine
mv app/services/pricing/calculator.rb my_engine/app/services/my_engine/pricing_calculator.rb
```

```ruby
# Before (in host app): module Pricing; class Calculator
# After (in engine):
module MyEngine
  class PricingCalculator
    def initialize(line_items)
      @line_items = line_items
    end

    def total
      @line_items.sum { |item| item.price * item.quantity }
    end
  end
end
```

Verify regression coverage still passes before proceeding to the next slice:

```bash
bundle exec rspec spec/services/pricing/ spec/requests/orders/
```

Move engine-local models in the same slice, or keep host models and inject via an adapter in a later slice.

**Adapter for host dependency (compact):**

```ruby
# config seam (compact)
module MyEngine
  def self.current_user_for(request)
    config.current_user_provider.call(request)
  end
end

# usage
OrderCreator.for_request(request) # resolves via MyEngine.current_user_for(request)
```

See references/adapter_examples.md for the full adapter example. Compact examples and the per-slice checklist are available at rails-engine-extraction/assets/examples.md and rails-engine-extraction/assets/checklist.json.

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-author | Engine structure, host contract, namespace design after extraction |
| rails-engine-testing | Dummy app, regression tests, integration verification |
| refactor-safely | Behavior-preserving refactors before or after extraction slices |
