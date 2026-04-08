---
name: refactor-safely
description: >
  Use when the goal is to change code structure without changing behavior — this
  includes extracting a service object from a fat controller or model, splitting
  a large class, renaming abstractions, reducing duplication, or reorganizing
  modules. Covers characterization tests (write tests that document current behavior
  before touching the code), safe extraction in small steps, and verification after
  every step. Do NOT use for bug fixes or new features — those follow the TDD gate
  in rspec-best-practices. Do NOT mix structural changes with behavior changes in
  the same step.
---

# Refactor Safely

Use this skill when the task is to change structure without changing intended behavior.

**Core principle:** Small, reversible steps over large rewrites. Separate design improvement from behavior change.

## Quick Reference

| Step | Action | Verification |
|------|--------|-------------|
| 1 | Define stable behavior | Written statement of what must not change |
| 2 | Add characterization tests | Tests pass on current code |
| 3 | Choose smallest safe slice | One boundary at a time |
| 4 | Rename, move, or extract | Tests still pass |
| 5 | Remove compatibility shims | Tests still pass, new path proven |

## HARD-GATE

```
NO REFACTORING WITHOUT CHARACTERIZATION TESTS FIRST.
SEPARATE behavior changes from structural refactors.
VERIFY tests pass after EVERY step — not just at the end.
```

If you haven't run the test suite after a refactoring step, you cannot claim it works.

## Core Rules

- Split behavior changes from structural refactors when practical.
- Keep public interfaces stable until callers are migrated.
- Extract one boundary at a time.
- Prefer adapters, facades, or wrappers for transitional states.
- Stop and simplify if the refactor introduces more indirection than clarity.

## Good First Moves

- Rename unclear methods or objects
- Isolate duplicated logic behind a shared object
- Extract query or service objects from repeated workflows
- Wrap external integrations before moving call sites
- Add narrow seams before deleting old code paths

## Verification Protocol

**EXTREMELY-IMPORTANT:** Run verification after every refactoring step.

```
AFTER each step:
1. Run the full test suite
2. Read the output — check exit code, count failures
3. If tests fail: STOP, undo the step, investigate
4. If tests pass: proceed to next step
5. ONLY claim completion with evidence from the last test run
```

**Forbidden claims:**
- "Should work now" (run the tests)
- "Looks correct" (run the tests)
- "I'm confident" (confidence is not evidence)

## Examples

**Stable behavior to preserve:** "Creating an order validates line items, applies pricing, persists the order, and enqueues NotifyWarehouseJob."

**Smallest safe sequence (extract service):**

1. Add a characterization test (request or service spec) that covers the current `OrdersController#create` flow.
2. Extract `Orders::CreateOrder` with the same behavior; call it from the controller; keep controller response/redirect logic. Verify tests pass.
3. Remove duplicated logic from the controller. No behavior change. Verify tests pass.
4. (Later) Improve the service internals if needed; the refactor is done.

**Red-flag refactor (avoid):** "Rename `Order` to `Purchase` and update all 50 call sites in one PR" — too many touchpoints; do renames in small steps with find/replace and tests after each commit.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Quick refactor, no tests needed" | No characterization tests = no safety net. Bugs will slip through. |
| Mixing behavior change with structural change | Do one or the other. Mixed changes are impossible to review. |
| Renaming 50 call sites in one commit | Do it in small batches with tests between each. |
| Adding abstraction to satisfy a pattern | Abstractions must serve a real boundary, not a textbook. |
| Removing old code before new path is proven | Keep compatibility shims until callers are fully migrated. |

## Red Flags

- Refactor plan requires touching many unrelated call sites at once
- No tests prove current behavior before starting
- Structural cleanup is mixed with new feature work
- Old and new paths diverge without a migration plan
- New abstractions exist only to satisfy a pattern, not a real boundary
- More than 3 refactoring steps without running tests
- Using "should", "probably", "seems to" when claiming tests pass

## Output Style

When asked to refactor:

1. State the stable behavior that must not change.
2. Propose the smallest safe sequence.
3. Add or point to the tests that protect each step.
4. Call out any temporary compatibility code and when to remove it.
5. Run verification after each step and report results with evidence.

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-best-practices** | For writing characterization tests before refactoring |
| **rails-architecture-review** | When refactor reveals structural problems |
| **rails-code-review** | For reviewing the refactored code |
| **ruby-service-objects** | When extracting logic into service objects |
