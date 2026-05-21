---
name: bug-fix
license: MIT
description: >
  Orchestrates systematic bug fixing loop: triage bug report → create failing reproduction test → implement minimal fix → verify resolution and no regressions. Use when fixing reported bugs, addressing production issues, resolving test failures, or implementing fixes for code review findings. Trigger: bug report, production issue, failing test, fix bug, resolve issue, address critical finding.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when fixing reported bugs, addressing production issues, or implementing fixes for code review findings"
  phases: "Phase 1: Bug Triage, Phase 2: Reproduction, Phase 3: Fix Implementation, Phase 4: Verification"
  hard_gates: "Reproduction Test Fails, Fix Implementation, Test Passes, No Regressions"
  dependencies: "triage-bug, plan-tests, write-tests"
  keywords: rails, bug-fix, debugging, testing, tdd, production, regression
---
# Bug Fix Agent

Orchestrates systematic bug resolution from initial report through verified fix, ensuring bugs are properly understood, reproduced with tests, fixed with TDD discipline, and verified without regressions.

## When to Use

- Fixing reported bugs from users or stakeholders
- Addressing production issues or incidents
- Resolving failing test suites
- Implementing fixes for code review Critical findings
- Debugging unexpected application behavior
- Fixing security vulnerabilities

## Agent Phases

### Phase 1: Bug Triage

**Objective:** Understand the bug and determine root cause before attempting fixes.

**Steps:**
1. **skills/testing/triage-bug** — Analyze bug report, identify symptoms, and determine reproduction steps
2. **Context Gathering** — Load relevant code context:
   - Identify affected files and components
   - Review recent changes that may have introduced the bug
   - Check error logs, stack traces, and system state

**HARD GATE — Bug Understanding:**
- Bug symptoms clearly identified
- Root cause hypothesis formed
- Affected code paths mapped
- Reproduction steps documented

**If gate fails:** Return to information gathering. Cannot proceed without understanding the bug.

**Example Bug Report Format:**
```markdown
# Bug Report: Order calculation incorrect

## Symptoms
Order totals are calculated incorrectly when discount is applied.

## Reproduction Steps
1. Create order with 3 items
2. Apply 10% discount
3. Total is $90 instead of $81

## Root Cause Hypothesis
Discount calculation in OrderService#calculate_total is multiplying instead of dividing.

## Affected Files
- app/services/order_service.rb
- spec/services/order_service_spec.rb
```

---

### Phase 2: Reproduction

**Objective:** Create a failing test that reproduces the bug before fixing it.

### TDD Enforcement for Bug Fixes

**Before writing any fix code:**
1. **testing/plan-tests** — Choose the best test type to reproduce the bug:
   - Unit test for logic bugs
   - Integration test for interaction bugs
   - System test for end-to-end bugs
2. **testing/write-tests** — Write failing test that reproduces the exact bug symptoms
3. **Test Verification** — Confirm test FAILS for the right reason (reproduces the bug, not syntax error)
4. **Minimal Reproduction** — Ensure test isolates the bug without unnecessary complexity

**HARD GATE — Reproduction Test:**
- Test EXISTS and RUNS
- Test FAILS with error matching bug symptoms
- Failure message clearly indicates the bug
- Test is isolated and deterministic

**If test fails for wrong reason:** Fix test (not code) to accurately reproduce the bug.

**Example Reproduction Test:**
```ruby
# spec/services/order_service_spec.rb
RSpec.describe OrderService do
  describe '#calculate_total' do
    it 'correctly applies discount to order total' do
      order = create(:order, :with_items, item_count: 3, item_price: 30.00)
      result = OrderService.calculate_total(order, discount_percent: 10)

      expect(result).to eq(81.00) # Currently fails: returns 90.00
    end
  end
end
```

---

### Phase 3: Fix Implementation

**Objective:** Implement minimal fix to make reproduction test pass.

**Steps:**
1. **Fix Proposal** — Propose minimal code change to address root cause
2. **User Approval** — Wait for explicit confirmation of approach
3. **Implement Fix** — Apply smallest possible code change
4. **Verify PASS** — Run reproduction test to confirm it now passes

### TDD Implementation Discipline

**Fix Implementation Guidelines:**
- Make the smallest change that makes the test pass
- Do not refactor or add "nice-to-have" improvements
- Focus on the root cause, not symptoms
- Preserve existing behavior except for the bug fix

**HARD GATE — Fix Verification:**
- Reproduction test PASSES (bug is resolved)
- Code change is minimal and focused
- No unrelated changes introduced
- Fix addresses root cause, not just symptoms

**If test still fails:** Fix is incorrect. Revise approach and re-implement.

**Example Fix:**
```ruby
# app/services/order_service.rb
def self.calculate_total(order, discount_percent: 0)
  subtotal = order.items.sum(&:price)
  discount_amount = subtotal * (discount_percent / 100.0) # Fixed: was multiplication
  subtotal - discount_amount
end
```

---

### Phase 4: Verification

**Objective:** Ensure fix resolves bug without introducing regressions.

**Steps:**
1. **Regression Test Suite** — Run full test suite to ensure no existing functionality broken
2. **Edge Case Testing** — Test boundary conditions and related scenarios
3. **Manual Verification** — If applicable, manually verify fix in development environment
4. **Documentation Update** — Update relevant docs if bug revealed documentation gap

**HARD GATE — Regression Check:**
```bash
bundle exec rspec  # Full test suite must pass
```

**Edge Cases to Consider:**
- Zero values (discount_percent: 0)
- Negative values (if applicable)
- Boundary conditions (discount_percent: 100)
- Related functionality (other calculation methods)

**HARD GATE — Verification Complete:**
- Full test suite PASSES (no regressions)
- Edge cases tested and passing
- Manual verification completed (if applicable)
- Documentation updated (if needed)

**If regressions found:** Fix introduced new issues. Revise fix and re-verify.

---

## Integration

| Predecessor | This Agent | Successor |
|-------------|------------|-----------|
| triage-bug | bug-fix | quality |
| code-review (Critical findings) | bug-fix | respond-to-review |
| production incident | bug-fix | deployment |
| None (standalone) | bug-fix | PR submission |

## When to Use This vs. Individual Skills

- **Full bug fix cycle (all phases):** Use this agent
- **Only triage bug report:** Use `triage-bug`
- **Only write reproduction test:** Use `write-tests`
- **Not sure if it's a bug:** Use `skill-router`

## HARD-GATE: Fix Quality Before Merge

**NEVER mark bug as resolved before:**
- Reproduction test EXISTS and FAILS before fix
- Reproduction test PASSES after fix
- Full regression test suite PASSES
- Edge cases tested and passing
- Root cause addressed (not just symptoms)

**If gate fails:** Bug is not properly fixed. Return to appropriate phase.

## Output Style

```markdown
# Bug Fix Report — [Date]

## Bug Summary
- **Issue:** Order calculation incorrect with discount
- **Root Cause:** Multiplication instead of division in discount calculation
- **Affected Files:** app/services/order_service.rb

## Reproduction
- Test created: spec/services/order_service_spec.rb:42
- Test failure before fix: Expected 81.00, got 90.00
- Test passes after fix: ✓

## Fix Applied
- File: app/services/order_service.rb:17
- Change: Fixed discount calculation formula
- Lines changed: 1

## Verification
- Reproduction test: ✓ PASS
- Regression suite: ✓ PASS (485/485 tests)
- Edge cases tested: ✓ PASS (zero, boundary, negative)
- Manual verification: ✓ PASS

## Status
**RESOLVED** — No regressions detected
```

## Anti-Patterns to Avoid

- **Fixing without reproduction:** Never fix a bug without a failing test that reproduces it
- **Symptom fixing:** Always address root cause, not just visible symptoms
- **Scope creep:** Don't add improvements or refactoring along with bug fix
- **Skipping regression:** Always run full test suite after fix
- **Documentation drift:** Update docs if bug revealed documentation gaps