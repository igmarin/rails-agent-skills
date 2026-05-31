---
name: tdd
license: MIT
description: >
  Orchestrates the full Rails test-driven development cycle: generates a failing spec first, implements minimal code to pass, refactors, then produces YARD documentation and a self-reviewed PR. Use when practicing test-driven development, red-green-refactor, TDD workflow, writing tests before code, adding tests first, or building a Rails feature where specs must gate implementation.
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
# TDD Agent

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
