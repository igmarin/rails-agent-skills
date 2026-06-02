---
name: quality
type: persona
tags: [personas]
license: MIT
description: >
  Complete code quality loop for Rails projects with hard gates: enforce naming conventions and linter compliance (rubocop/brakeman/erblint must pass) → refactor only after characterization tests PASS on current code, verify behavior preserved after each extraction → generate YARD docstrings for all public APIs → NEVER open PR before linter, ERB linter, full test suite, security scan, and YARD docs all pass; phases conventions review→refactoring→documentation. Use this composite end-to-end loop instead of individual refactoring or documentation skills when full three-phase production-readiness review is needed in one pass. Trigger: code review prep, before PR, full Rails quality sweep, quality audit, production-ready review, end-to-end quality check.
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
# Quality Persona

Orchestrates systematic code quality checks, safe refactoring, and documentation updates across three phases. Use this instead of individual refactoring or documentation skills when full production-readiness is required end-to-end. If unsure which skill applies, use `skill-router`.

## Complexity Thresholds

| Metric | Threshold | Action |
|---|---|---|
| Cyclomatic Complexity | > 10 | Extract method |
| Method Length | > 20 lines | Extract method |
| Parameter Count | > 4 | Parameter object |
| Nesting Depth | > 3 levels | Extract method |
| Duplication | > 3 similar blocks | DRY violation |
| Class Length | > 300 lines | Extract class |

## Agent Phases

### Phase 1: Conventions Review

Check code against Rails standards via **skills/code-quality/apply-code-conventions** (DRY/YAGNI/PORO/CoC/KISS compliance, linter as style source of truth, structured logging) and **skills/code-quality/apply-stack-conventions** (Rails + PostgreSQL patterns, Hotwire + Tailwind conventions, security best practices).

**Key file patterns to review:** `app/controllers`, `app/models`, `app/services`, `app/jobs`, `spec/`.

**Tool Integration:**
```bash
# Complexity and duplication
bundle exec rubocop --only Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/ParameterLists,Metrics/AbcSize,Metrics/PerceivedComplexity

# Security
bundle exec brakeman --no-pager
bundle exec bundle-audit check --update
```

---

### Phase 2: Refactoring (Optional)

**Decision Gate — Proceed if any threshold from the table above is exceeded; otherwise skip to Phase 3.**

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

```bash
bundle exec rspec   # All tests must pass before proceeding to Phase 3
```

**If gate fails:** Fix the failing test or refactoring before proceeding to Phase 3.

---

### Phase 3: Documentation

Document public APIs via **skills/ruby-core-skills/write-yard-docs** (annotate all public methods with params, return values, and examples; update README/diagrams for architecture or API changes).

**Output:** Updated YARD comments, refreshed README sections

---

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

## Output Format

```markdown
# Quality Report — [Date]

## Conventions Check
### Critical Violations (Must Fix)
- [CRITICAL] app/controllers/orders_controller.rb:42 — Method `process_payment` has cyclomatic complexity of 15 (> 10 threshold)
- [CRITICAL] app/models/user.rb:28 — Class has 450 lines (> 300 threshold), extract to service objects

### Warning Violations (Should Fix)
- [WARNING] app/services/order_service.rb:17 — Method `calculate_discount` has 6 parameters (> 4 threshold)

### Suggestion Violations (Nice to Have)
- [SUGGESTION] spec/models/order_spec.rb:12 — Test duplication detected, extract to shared examples

## Refactoring
- [x] / [ ] Required (threshold exceeded)
- Characterization tests added, methods extracted, all tests passing

## Documentation
- YARD coverage: 87% (improved from 65%)
- README updated: YES
```

---

## Error Recovery

**RuboCop offenses after refactoring:**
1. Run `bundle exec rubocop -a` for auto-correctable offenses
2. Fix remaining offenses manually — refactoring may have introduced style violations
3. Re-run full suite to ensure fixes don't break behavior

**Characterization test fails after refactoring:**
1. The refactoring changed behavior — this is a regression, not a test problem
2. Revert the refactoring change
3. Re-examine the extraction — ensure the new method/class preserves the exact contract
4. Try a smaller, more focused refactoring step

**YARD generation errors:**
1. Check for syntax errors in YARD tags (`@param`, `@return`, `@raise`)
2. Verify method signatures match YARD annotations
3. Run `yard stats` to identify undocumented public methods

---

## Anti-Patterns to Avoid

- **Refactoring without tests:** NEVER refactor without characterization tests passing first
- **Fixing tests to match refactoring:** If a test fails after refactoring, the refactoring broke behavior — fix the code, not the test
- **Scope creep during quality pass:** Don't add features during a quality review — only fix conventions, refactor, and document
- **Skipping ERB linter:** `erblint` catches view-layer issues that RuboCop misses
- **Ignoring Brakeman warnings:** Every Brakeman warning MUST be assessed — false positives should be annotated, not silently ignored
- **Partial YARD coverage:** All public methods MUST have YARD docs — don't skip "obvious" methods
