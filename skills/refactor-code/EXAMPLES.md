# Refactor Safely Examples

Use these examples when the main `SKILL.md` flow is clear and you need concrete execution patterns.

## Example 1: Extract Service from Controller

**Stable behavior to preserve:**  
"Creating an order validates line items, applies pricing, persists the order, and enqueues `NotifyWarehouseJob`."

**Smallest safe sequence:**

1. Add a characterization test (request or service spec) that covers current `OrdersController#create`.
2. Extract `Orders::CreateOrder` with identical behavior and call it from the controller.
3. Keep response/redirect logic unchanged while migrating internals.
4. Remove duplication from controller once the new path is proven.
5. Run full tests after each step.

## Example 2: Rename in Small Batches

**Goal:** Rename `Order` to `Purchase` safely.

**Safe sequence:**

1. Introduce compatibility alias/wrapper (temporary).
2. Rename a small set of call sites (one boundary at a time).
3. Run full suite after each batch.
4. Remove alias only when all call sites are migrated and tests are green.

## Anti-Pattern Example

**Avoid:** "Rename `Order` to `Purchase` and update all 50 call sites in one PR."

**Why unsafe:** Too many touchpoints in one step, high rollback cost, poor reviewability, and no isolation when tests fail.
