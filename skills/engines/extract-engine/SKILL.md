---
name: extract-engine
license: MIT
description: >
  Use when extracting existing Rails app code into a reusable engine — DO NOT extract and change behavior in the same step, preserve existing behavior first then refactor separately, move stable domain logic first (POROs/services/value objects), add adapters or configuration seams for host dependencies before moving controllers/routes/views, keep regression coverage green throughout each slice, one bounded slice per step with one coherent responsibility and minimal new public API. Scaffolds engine structure, increments through extraction slices, creates adapter interfaces to decouple host dependencies. Trigger words: extract to engine, move feature to engine, host coupling, adapters, extraction slices, preserve behavior, incremental extraction.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Extract Engine

Use this skill when the task is to move existing code out of a Rails app and into an engine.
Prefer incremental extraction over big-bang rewrites. Preserve behavior first, then improve design.

## Quick Reference

| Phase | Focus |
|-------|-------|
| Prep | Identify bounded feature and host dependencies |
| Logic | Move stable domain logic (POROs, services) first |
| Seams | Add adapters/config for host dependencies |
| Web | Move controllers, routes, views last |

## HARD-GATE

```text
DO NOT extract and change behavior in the same step.
Extraction must preserve existing behavior; refactoring and improvements belong in a separate step after the move is complete and verified.
```

## Core Process

1. Identify the bounded feature to extract — one coherent responsibility.
2. List hard dependencies on the host app (models, services, config).
3. Define the future engine boundary and host contract.
4. Move stable domain logic first: POROs, services, value objects, policies, query objects. Delay direct host model references, authentication, route ownership, and asset integration.
5. Add adapters or configuration seams for host-owned dependencies. Replace hardcoded host references with config values, adapter objects, or service interfaces.
6. Move controllers, routes, views, or jobs only after seams are clear.
7. Keep regression coverage green throughout each slice.

Each slice must have: one coherent responsibility, minimal new public API, passing regression tests, and a clear next step.

## Extended Resources

**Pitfalls**
| Pitfall | What to do |
|---------|------------|
| Extracting too much at once | One bounded slice per step; large extractions hide bugs and are hard to revert |
| Direct host references in engine | Use adapters or config; direct constants couple engine to host internals |
| Behavior changes mixed with extraction | Preserve behavior first; refactor only after the move is verified |
| Circular dependencies introduced | Verify import graph before moving each slice |
| Dummy app passes but host contract is implicit | Explicitly document and test the host app contract |

**Examples**
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

- [assets/examples.md](assets/examples.md)
- [references/adapter_examples.md](references/adapter_examples.md)

## Output Style

1. Propose one small, bounded extraction slice at a time.
2. Outline the files moving, the new boundaries, and the regression tests to run.
3. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| create-engine | Engine structure, host contract, namespace design after extraction |
| test-engine | Dummy app, regression tests, integration verification |
| refactor-code | Behavior-preserving refactors before or after extraction slices |
