---
name: quality
license: MIT
description: >
  Complete code quality loop for Rails projects. Enforces naming conventions, reduces duplication,
  extracts methods and service objects, reduces complexity, and generates YARD docstrings and inline
  comments across the full codebase. Use this composite end-to-end loop instead of individual
  refactoring or documentation skills when the full three-phase production-readiness review is needed
  together in one pass. Use when: code review prep, before PR, full Rails quality sweep, quality audit,
  production-ready review, end-to-end quality check.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when conducting full production-readiness review or code quality sweep before PR"
  phases: "Phase 1: Conventions Review, Phase 2: Refactoring, Phase 3: Documentation"
  hard_gates: "Conventions Check, Refactoring Test Gate, Quality Before Merge"
  dependencies:
    - source: self
      skills: [apply-code-conventions, apply-stack-conventions, refactor-code, code-review]
    - source: ruby-core-skills
      skills: [write-yard-docs, refactor-process, review-process]
  keywords: rails, quality, conventions, refactoring, documentation, yard, review
---
# Quality Agent

Orchestrates systematic code quality checks, safe refactoring, and documentation updates across three phases. Use this instead of individual refactoring or documentation skills when full production-readiness is required end-to-end.

## When to Use

- Conducting full production-readiness review before PR
- Running comprehensive code quality sweep across codebase
- Preparing code for external review or audit
- Reducing technical debt in existing Rails application
- Enforcing coding standards across team

## Agent Phases

### Phase 1: Conventions Review

Check code against Rails standards via **skills/code-quality/apply-code-conventions** (DRY/YAGNI/PORO/CoC/KISS compliance, linter as style source of truth, structured logging) and **skills/code-quality/apply-stack-conventions** (Rails + PostgreSQL patterns, Hotwire + Tailwind conventions, security best practices).

**Complexity Metrics to Evaluate:**
- **Cyclomatic Complexity:** > 10 indicates high complexity (extract method)
- **Method Length:** > 20 lines indicates potential extraction need
- **Parameter Count:** > 4 parameters indicates parameter object need
- **Nesting Depth:** > 3 levels indicates potential extraction need
- **Duplication:** > 3 similar code blocks indicates DRY violation
- **Class Length:** > 300 lines indicates potential class extraction need

**Specific File Patterns to Check:**
- `app/controllers/**/*.rb` — Check for fat controllers, callback chains
- `app/models/**/*.rb` — Check for fat models, business logic in models
- `app/services/**/*.rb` — Check for service object violations
- `app/jobs/**/*.rb` — Check for job object violations
- `spec/**/*.rb` — Check for test duplication and complexity

**Tool Integration Guidance:**
```bash
# Run rubocop with specific complexity cops
bundle exec rubocop --only Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/ParameterLists

# Check for code duplication
bundle exec rubocop --only Metrics/AbcSize,Metrics/PerceivedComplexity

# Security scan
bundle exec brakeman --no-pager

# SQL injection scan
bundle exec bundle-audit check --update
```

**Example Violations:**

**DRY Violation:**
```ruby
# Before: Logic duplicated across OrderService and CartService
def apply_discount(price, pct) = price - (price * pct / 100.0)

# After: Extracted to shared PORO
class DiscountCalculator
  def self.apply(price, pct) = price - (price * pct / 100.0)
end
```

**SRP Violation:**
```ruby
# Before: Class handles multiple responsibilities
class OrderProcessor
  def process(order)
    validate(order)
    calculate_total(order)
    send_email(order)
    update_inventory(order)
  end
end

# After: Single responsibility per class
class OrderValidator
  def validate(order) # validation only
end

class OrderCalculator
  def calculate_total(order) # calculation only
end

class OrderNotifier
  def send_email(order) # notification only
end
```

**Long Method Violation:**
```ruby
# Before: 35 lines, multiple responsibilities
def process_order(order)
  # validation logic (10 lines)
  # calculation logic (15 lines)
  # notification logic (10 lines)
end

# After: Extracted to focused methods
def process_order(order)
  validate_order(order)
  calculate_order_totals(order)
  send_order_confirmation(order)
end
```

**Output Format:**
```markdown
# Conventions Report — [Date]

## Critical Violations (Must Fix)
- [CRITICAL] app/controllers/orders_controller.rb:42 — Method `process_payment` has cyclomatic complexity of 15 (> 10 threshold)
- [CRITICAL] app/models/user.rb:28 — Class has 450 lines (> 300 threshold), extract to service objects

## Warning Violations (Should Fix)
- [WARNING] app/services/order_service.rb:17 — Method `calculate_discount` has 6 parameters (> 4 threshold)
- [WARNING] app/controllers/users_controller.rb:35 — Nesting depth of 5 levels (> 3 threshold)

## Suggestion Violations (Nice to Have)
- [SUGGESTION] spec/models/order_spec.rb:12 — Test duplication detected, extract to shared examples
```

---

### Phase 2: Refactoring (Optional)

**Decision Gate — Need Refactoring?**
- Cyclomatic complexity > 10? → Proceed
- Method length > 20 lines? → Proceed
- Parameter count > 4? → Proceed
- Nesting depth > 3? → Proceed
- Duplication > 3 similar blocks? → Proceed
- Class length > 300 lines? → Proceed
- Otherwise → Skip to Phase 3

**If refactoring is needed, follow TDD discipline:**

### TDD Enforcement for Refactoring

**Before any code change:**
1. **testing/plan-tests** — Choose the best characterization test to document current behavior
2. **testing/write-tests** — Write characterization test and verify it PASSES (documents current behavior)
3. **Refactoring Checkpoint** — Propose specific refactoring (e.g., "Extract `calculate_discount` method to `DiscountCalculator` class")
4. **User Approval** — Wait for explicit confirmation
5. **Implement Refactoring** — Make the structural change only
6. **Verify PASS** — Run characterization test to confirm behavior is preserved
7. **Regression Check** — Run full test suite to ensure no regressions

**HARD GATE — Test Verification:**
- Characterization test EXISTS and PASSES before refactoring
- Characterization test PASSES after refactoring (behavior preserved)
- Full test suite PASSES (no regressions)
- If test fails: Fix the refactoring, not the test

Follow **skills/code-quality/refactor-code** for specific extraction patterns and safety guidelines.

**HARD GATE — Tests Pass:**
```bash
bundle exec rspec   # All tests must pass before proceeding
```

**If gate fails:** Fix the failing test or refactoring before proceeding to Phase 3.

---

### Phase 3: Documentation

Document public APIs via **write-yard-docs** *(from ruby-core-skills)* (annotate all public methods with params, return values, and examples; update README/diagrams for architecture or API changes).

**Output:** Updated YARD comments, refreshed README sections

---

## Integration

| Predecessor | This Agent | Successor |
|-------------|---------------|-----------|
| tdd | quality | review |
| refactor-code | quality | write-yard-docs |
| None (standalone) | quality | PR submission |

## When to Use This vs. Individual Skills

- **Full pre-PR sweep (all three phases):** Use this agent
- **Only fix linting / conventions:** Use `apply-code-conventions`
- **Only refactor a specific file:** Use `refactor-code`
- **Only add YARD docs:** Use `write-yard-docs`
- **Not sure which skill applies:** Use `skill-router`

## HARD-GATE: Quality Before Merge

**NEVER open PR before:**
```bash
bundle exec rubocop        # Linter must pass
bundle exec erblint --lint-all  # ERB linter must pass
bundle exec rspec          # All tests must pass
bundle exec brakeman       # Security scan must pass
```
Plus: YARD docs complete for all public APIs.

**If gate fails:** Fix the failing item before opening PR.

## Output Style

```markdown
# Quality Report — [Date]

## Conventions Check
- [x] DRY: No duplication found
- [x] PORO: Service objects properly structured
- [ ] YAGNI: Remove unused method `calculate_total`?

## Refactoring
- Characterization tests added, methods extracted, all tests passing

## Documentation
- YARD coverage: 87% (improved from 65%)
- README updated: YES
```