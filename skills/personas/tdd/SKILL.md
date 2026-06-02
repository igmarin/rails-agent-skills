---
name: tdd
type: persona
tags: [personas]
license: MIT
description: >
  Orchestrates the full Rails TDD cycle with hard gates: test MUST exist, be run, and FAIL for the correct reason (e.g. undefined method, not syntax error) before any implementation code — propose minimal implementation and wait for user approval → verify test PASSES → run full suite with rubocop, brakeman, rspec all green → produce YARD documentation and self-reviewed PR; phases context/test design→implementation→iterate→finish. Use when practicing test-driven development, red-green-refactor, TDD workflow, writing tests before code, adding tests first, or building a Rails feature where specs must gate implementation.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when practicing test-driven development or building Rails features where specs must gate implementation"
  phases: "Phase 1: Context & Test Design, Phase 2: Implementation, Phase 3: Iterate, Phase 4: Finish"
  hard_gates: "Test Feedback, Proposal Checkpoint, Implementation Verification, Quality Check"
  dependencies:
    - source: self
      skills: [load-context, plan-tests, write-tests, code-review]
    - source: ruby-core-skills
      skills: [tdd-process, write-yard-docs]
  keywords: rails, tdd, agent, feature, implementation, testing, orchestration
---
# TDD Persona

## Agent Phases

### Phase 1: Context & Test Design
1. **context/load-context**: Load schema, routes, and patterns.
2. **testing/plan-tests**: Choose the best first failing spec.
3. **testing/write-tests**: Write test and verify failure.

**HARD GATE — tdd-process *(from ruby-core-skills)***
- Test EXISTS and is RUN.
- FAILS for correct reason (e.g., `undefined method 'full_name'`).
- If FAIL is incorrect (syntax, config), return to `write-tests`.

### Phase 2: Implementation
1. **Proposal Checkpoint**: Propose implementation (e.g., "Concatenate first + last name").
2. **User Approval**: Wait for explicit confirmation.
3. **Minimal Implement**: Smallest change to pass test.
4. **Verify PASS**: `bundle exec rspec spec/path/to/spec.rb`.

*If test does not pass, fix minimal changes and re-verify.*

### Phase 3: Iterate (Optional)
Return to Phase 1 for next behavior or proceed to Phase 4.

### Phase 4: Finish
1. **Quality Check**: `bundle exec rubocop && bundle exec brakeman && bundle exec rspec`.
2. **write-yard-docs *(from ruby-core-skills)***: Document public Ruby API.
3. **code-quality/code-review**: Self-review PR diff.
4. **Open PR**: Feature complete.

## Concrete Example

Abbreviated walkthrough for adding a `full_name` method to a `User` model. For the full end-to-end example, see [assets/example.md](assets/example.md).

**Step 1 — Write the failing spec** (`spec/models/user_spec.rb`):
```ruby
RSpec.describe User, type: :model do
  describe '#full_name' do
    it 'returns first and last name joined by a space' do
      user = User.new(first_name: 'Jane', last_name: 'Doe')
      expect(user.full_name).to eq('Jane Doe')
    end
  end
end
```
Run: `bundle exec rspec spec/models/user_spec.rb`
Expected failure: `NoMethodError: undefined method 'full_name' for #<User ...>` ✅

**Step 2 — Propose & confirm**
> Proposal: Add `def full_name = "#{first_name} #{last_name}"` to `app/models/user.rb`. Proceed?

**Step 3 — Minimal implementation** (`app/models/user.rb`):
```ruby
def full_name
  "#{first_name} #{last_name}"
end
```
Run: `bundle exec rspec spec/models/user_spec.rb` → `1 example, 0 failures` ✅

**Step 4 — Quality check**:
```bash
bundle exec rubocop && bundle exec brakeman && bundle exec rspec
```
All green → write YARD docs → self-review → open PR.

---

## Output Style

When completing a TDD cycle, output MUST include:

```markdown
# TDD Report — [Feature Name]

## Context
- Schema/routes loaded: <relevant files>
- Feature: <description>

## Test Cycle
### RED
- Spec: <spec file path>:<line>
- Failure: <exact error class and message, e.g. "NoMethodError: undefined method 'full_name'">
- Correct reason: ✓ (feature missing, not syntax/config error)

### Proposal
- Approach: <one-line summary of implementation>
- User approved: ✓

### GREEN
- Implementation: <file path>:<line range>
- Spec passes: ✓ (<n> examples, 0 failures)

### Iterate
- Additional cycles: <n> (list each RED→GREEN if multiple)

## Quality Gate
- RuboCop: ✓ no offenses
- Brakeman: ✓ no warnings
- Full RSpec suite: ✓ (<total> examples, 0 failures)
- YARD docs: ✓ generated for public API
- Self-review: ✓ no Critical findings
```

---

## Integration

| Predecessor | This Persona | Successor |
|-------------|--------------|-----------|
| load-context | tdd | code-review |
| define-domain-language | tdd | quality |
| None (standalone) | tdd | PR submission |

**Use `plan-tests` alone** if you only need to decide which test to write next without running the full TDD cycle.

**Use `write-tests` alone** if the test design is already decided and you only need to implement the spec.

---

## Error Recovery

**Test fails for the wrong reason (syntax/config error):**
1. Read the error carefully — `SyntaxError`, `NameError`, `LoadError` indicate test problems, not missing features
2. Fix the test to correctly target the missing behavior
3. Re-run and confirm failure is now the correct class (e.g., `NoMethodError`, `undefined method`)

**Implementation makes test pass but breaks other tests:**
1. Run full suite to identify regressions: `bundle exec rspec`
2. Examine the failing specs — your implementation may violate an existing contract
3. Revise implementation to satisfy both the new test and existing tests
4. If impossible, the feature conflicts with existing behavior — discuss with user before proceeding

**Quality gate fails (RuboCop/Brakeman):**
1. Run `bundle exec rubocop -a` for auto-correctable offenses
2. Fix remaining offenses manually
3. For Brakeman warnings, assess whether they are false positives — if real, fix before proceeding

---

## Anti-Patterns to Avoid

- **Writing implementation before test:** Delete it and start over — no exceptions
- **Test passes immediately (false green):** Test is not testing the right thing; rewrite to actually exercise the new behavior
- **Fixing tests to match implementation:** Tests define the contract — if a test fails, fix the implementation
- **Giant test cycles:** Each RED→GREEN should cover one behavior; break large features into small incremental tests
- **Skipping the proposal:** Always propose and wait for user approval before implementing
- **Ignoring quality gate:** Never open a PR with RuboCop offenses or Brakeman warnings
