# Rails Persona Template

This template defines the standard structure for all Rails Agent Skills personas. Use this when creating new personas or refactoring existing ones.

## Frontmatter Template

```yaml
---
name: persona-name
type: persona
tags: [personas]
license: MIT
description: >
  Clear one-sentence summary of what this persona orchestrates.
  Use when [specific trigger scenarios or user intents].
keywords: comma, separated, discovery, terms, for, mcp, tools
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Description of when to invoke this persona"
  phases: "Phase 1: Name, Phase 2: Name, Phase 3: Name"
  hard_gates: "Gate 1: Name, Gate 2: Name"
  dependencies: "skill-name-1, skill-name-2, skill-name-3"
---
```

## Body Structure Template

```markdown
# Persona Name

Brief paragraph (2-3 sentences) explaining what this persona orchestrates and its primary value proposition.

## When to Use

- Trigger scenario 1 with specific context
- Trigger scenario 2 with specific context
- Trigger scenario 3 with specific context

## Persona Phases

### Phase 1: Name

**Objective:** What this phase accomplishes

**Steps:**
1. **skill-name** — Brief description of what the skill does
2. **skill-name** — Brief description of what the skill does

**HARD GATE — Gate Name:**
- Criterion 1: Specific, measurable condition
- Criterion 2: Specific, measurable condition
- Criterion 3: Specific, measurable condition

**If gate fails:** Specific recovery action (e.g., "Return to Phase 1, Step 2")

**Example output format:**
```markdown
## Phase 1 Complete
- Criterion 1: PASSED
- Criterion 2: PASSED
- Criterion 3: FAILED
```

---

### Phase 2: Name

**Decision Gate — Decision Name:**
- Condition A? → Proceed to Branch A
- Condition B? → Proceed to Branch B
- Otherwise → Skip to Phase 3

**Branch A — [If Condition A]:**
1. **skill-name** — Description
2. **skill-name** — Description

**Branch B — [If Condition B]:**
1. **skill-name** — Description
2. **skill-name** — Description

---

### Phase 3: Name

[Continue phases as needed...]

## Integration

| Predecessor | This Persona | Successor |
|-------------|--------------|-----------|
| skill-name  | persona-name | skill-name |
| None        | persona-name | skill-name |

## Output Style

**Expected output format:**

```markdown
# Persona Report — [Date]

## Phase 1 Results
- [x] Checkpoint 1: PASSED
- [x] Checkpoint 2: PASSED

## Phase 2 Results
- Branch taken: A
- Findings: 3 Critical, 2 Suggestions

## Next Steps
Proceed to successor-persona or manual next action
```

## Complexity Metrics (For Refactoring/Quality Personas)

When evaluating code complexity, use these concrete metrics:

- **Cyclomatic Complexity:** > 10 indicates high complexity
- **Method Length:** > 20 lines indicates potential extraction need
- **Parameter Count:** > 4 parameters indicates parameter object need
- **Nesting Depth:** > 3 levels indicates potential extraction need
- **Duplication:** > 3 similar code blocks indicate DRY violation

## Example Violations (For Refactoring/Quality Personas)

Include concrete before/after examples for common violations:

**DRY Violation Example:**
```ruby
# Before: Logic duplicated
def calculate_discount(price, percentage)
  price - (price * percentage / 100.0)
end

def apply_promo(price, percentage)
  price - (price * percentage / 100.0)
end

# After: Extracted to shared method
class PriceCalculator
  def self.apply_discount(price, percentage)
    price - (price * percentage / 100.0)
  end
end
```

**SRP Violation Example:**
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

## HARD-GATE Checklist

**NEVER proceed to next phase before:**
- [ ] Gate 1: Specific condition met
- [ ] Gate 2: Specific condition met
- [ ] Gate 3: Specific condition met

## Anti-Patterns to Avoid

- **Anti-pattern 1:** Description and why it's problematic
- **Anti-pattern 2:** Description and why it's problematic
- **Anti-pattern 3:** Description and why it's problematic
```

## TDD Enforcement Guidelines

For personas that involve code changes, include explicit TDD steps:

```markdown
### TDD Enforcement

**Before any code change:**
1. **plan-tests** — Choose the best first failing spec
2. **write-tests** — Write the test and verify it FAILS for the right reason
3. **Implementation Checkpoint** — Propose minimal implementation
4. **User Approval** — Wait for explicit confirmation
5. **Implement** — Make smallest change to pass test
6. **Verify PASS** — Run test and confirm it passes
7. **Refactor** — Improve code structure while keeping tests green

**HARD GATE — Test Verification:**
- Test EXISTS and is RUN
- Test FAILS for correct reason (not syntax/config error)
- Implementation makes test PASS
- No regressions in existing tests
```

## Error Handling Guidelines

For personas that can encounter errors:

```markdown
### Error Recovery

**If [Specific Error] occurs:**
1. Diagnostic step: How to identify the error
2. Recovery action: Specific steps to resolve
3. Verification: How to confirm the error is resolved
4. Fallback: What to do if recovery fails

**Example:**
**If database connection fails:**
1. Check `config/database.yml` credentials
2. Verify database server is running: `rails db:ping`
3. Test connection: `rails db:create`
4. Fallback: Contact DevOps or check infrastructure status
```

## Naming Conventions

- **Persona names:** Use kebab-case (e.g., `tdd`, `quality`, `review`, `setup`, `engine`, `bug-fix`, `graphql`, `migration`, `background-job`)
- **Directory names:** Match persona name (e.g., `skills/tdd/SKILL.md`)
- **Skill references:** Use full skill path (e.g., `skills/write-tests`)
- **Phase names:** Use descriptive, action-oriented names (e.g., "Context & Test Design", not "Phase 1")

## Documentation Quality Checklist

- [ ] Frontmatter complete with all required fields
- [ ] Description is clear and concise
- [ ] Keywords cover discovery scenarios
- [ ] When to Use section has 3+ specific scenarios
- [ ] Each phase has clear objective
- [ ] HARD GATES are specific and measurable
- [ ] Error recovery paths are defined
- [ ] Examples are concrete and copy-pasteable
- [ ] Integration table shows predecessor/successor
- [ ] Output style is clearly defined
- [ ] Anti-patterns section included if applicable
- [ ] TDD enforcement included for code-changing personas
