---
name: rails-engine-extraction
description: Use when extracting existing Rails app code into a reusable engine. Trigger words: extract to engine, move feature to engine, host coupling, adapters, extraction slices, preserve behavior, incremental extraction, bounded feature.
---
# Rails Engine Extraction

Use this skill when the task is to move existing code out of a Rails app and into an engine.

Prefer incremental extraction over big-bang rewrites. Preserve behavior first, then improve design.

## HARD-GATE

**DO NOT extract and change behavior in the same step.** Extraction must preserve existing behavior; refactoring and improvements belong in a separate step after the move is complete and verified.

## Quick Reference

| Extraction Step | Action |
|-----------------|--------|
| Identify bounded feature | Choose one coherent responsibility to extract |
| List host dependencies | Document models, services, config the feature needs |
| Define engine boundary | Decide what lives in engine vs host |
| Move stable logic first | POROs, services, value objects before controllers |
| Add adapters | Replace direct host references with config or adapter interfaces |
| Move UI/routes last | Controllers, views, routes only after seams are clear |
| Keep tests green | Regression coverage throughout each slice |

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Extracting too much at once | One bounded slice per step; large extractions hide bugs and are hard to revert |
| Direct host references in engine | Engine must use adapters or config; direct constants couple engine to host internals |
| No adapter layer | Without adapters, host model changes break the engine; introduce seams before moving |

## Red Flags

- Engine requires host models directly (no config or adapter)
- No incremental migration plan (big-bang extraction)
- Behavior changes mixed with extraction (refactor in same commit as move)
- Engine references many top-level host constants
- Extraction introduces circular dependencies
- Initialization order becomes fragile
- The dummy app passes but the real host app contract is still implicit

## Extraction Order

1. Identify the bounded feature to extract.
2. List hard dependencies on the host app.
3. Define the future engine boundary and host contract.
4. Move stable domain logic first.
5. Add adapters or configuration seams for host-owned dependencies.
6. Move controllers, routes, views, or jobs only after the seams are clear.
7. Keep regression coverage green throughout.

## What To Extract First

Start with:

- POROs and services
- value objects
- policies or query objects
- engine-local models with limited host coupling

Delay these until later:

- direct references to host app models
- authentication integration
- route ownership changes
- asset and UI integration

## Coupling Strategy

Replace hardcoded host dependencies with:

- configuration values
- adapter objects
- service interfaces
- notifications or callbacks

Do not move code into an engine if it still depends on many private host internals.

## Safe Slice Checklist

- one coherent responsibility
- minimal new public API
- tests proving no regression in host behavior
- clear follow-up slice after the first move

## Examples

**First slice (move PORO, no host model yet):**

Extract `Pricing::Calculator` from `app/services/pricing/calculator.rb` into the engine. It only depends on `LineItem` and `Discount` — move those to the engine as engine models in the same slice, or keep them in the host and inject via an adapter in a later slice.

**Adapter for host dependency:**

```ruby
# In engine: use config instead of hardcoded User
# Before (in app): OrderCreator.new(current_user).call
# After (in engine): OrderCreator.new(MyEngine.config.current_user_provider.call(request)).call
# Host sets in initializer: MyEngine.config.current_user_provider = ->(req) { req.env["current_user"] }
```

**Red flag:** Extracting `OrdersController` in the first slice while it still calls `User`, `Tenant`, and `AuditLog` — too many host ties. Extract the service/PORO first and introduce adapters, then move the controller.

## Output Style

When asked to extract code:

1. Describe the boundary you are extracting.
2. List host dependencies that must be abstracted.
3. Propose the smallest safe first slice.
4. Add regression tests before and after the move.

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-author | Engine structure, host contract, namespace design after extraction |
| rails-engine-testing | Dummy app, regression tests, integration verification |
| refactor-safely | Behavior-preserving refactors before or after extraction slices |
