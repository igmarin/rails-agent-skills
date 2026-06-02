---
name: implement-authorization
type: atomic
license: MIT
description: >
  Use when implementing or testing authorization in Rails using Pundit or CanCanCan — must always verify authorization by attempting an unauthorized action in the browser or console and confirming it raises Pundit::NotAuthorizedError or CanCan::AccessDenied as expected, use policy objects rather than inline controller logic, test with multiple roles, and check specific permissions instead of presence checks alone. Covers policy objects, role-based access control, permission checks, testing strategies. Use when implementing authorization, setting up roles/permissions, or mentions Pundit/CanCanCan.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Implement Authorization

## Quick Reference

| Gem | Pattern | Best For |
|-----|---------|----------|
| **Pundit** | Explicit policy classes | Complex per-resource rules |
| **CanCanCan** | Centralized Ability class | Simple role-based permissions |

## HARD-GATE

```text
ALWAYS test authorization with multiple roles (admin, user, guest)
NEVER rely on presence checks alone — check specific permissions
ALWAYS use policy objects, never inline authorization logic in controllers
```

## Core Process

### Implementation Workflow

1. **Add gem** — add `pundit` or `cancancan` to Gemfile and run `bundle install`
2. **Generate base** — run the gem's installer (`rails g pundit:install` or `rails g cancan:ability`)
3. **Define policies/abilities** — create policy classes (Pundit) or populate the Ability class (CanCanCan)
4. **Authorize in controllers** — call `authorize @record` (Pundit) or `authorize! :action, @record` (CanCanCan) in each action
5. **Verify authorization** — attempt an unauthorized action in the browser or console and confirm it raises `Pundit::NotAuthorizedError` or `CanCan::AccessDenied` as expected
6. **Scope queries** — use `policy_scope(Model)` or `accessible_by(current_ability)` for index actions
7. **Test all roles** — write policy specs and request specs covering admin, owner, and guest

### Patterns

#### Pundit

```ruby
class PostPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user_id == user.id
  end
end
```

#### CanCanCan

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :update, Post, user_id: user.id
    can :manage, :all if user.admin?
  end
end
```

### Troubleshooting

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `Pundit::NotDefinedError` | No policy class found for the record | Create `app/policies/model_policy.rb` inheriting from `ApplicationPolicy` |
| `Pundit::AuthorizationNotPerformedError` | `authorize` not called in a controller action | Add `authorize @record` in the action, or `after_action :verify_authorized` to catch misses |
| `CanCan::AccessDenied` unexpectedly raised | Ability rules not matching the current user/role | Inspect `current_ability.can?(:action, @record)` in the console to debug rule evaluation |

### Testing

Cover every role (admin, owner, guest) in both policy specs and request specs.

#### Minimal Pundit policy spec

```ruby
RSpec.describe PostPolicy do
  subject { described_class.new(user, post) }

  let(:post) { create(:post, user: owner) }
  let(:owner) { create(:user) }

  context 'as admin' do
    let(:user) { create(:user, :admin) }
    it { is_expected.to permit_action(:update) }
  end

  context 'as owner' do
    let(:user) { owner }
    it { is_expected.to permit_action(:update) }
  end

  context 'as guest' do
    let(:user) { create(:user) }
    it { is_expected.not_to permit_action(:update) }
  end
end
```

## Output Style

When asked to implement or review authorization, your output `answer.md` MUST follow this style:

1. **Simulated Console Exception Output**:
   - In the verification steps, you MUST include a dedicated **Manual Denied-Action Verification** section.
   - Show simulated Rails console output blocks demonstrating Pundit or CanCanCan actually raising the appropriate authorization exception when an unauthorized action is attempted.
   - **CRITICAL**: Do NOT use unsaved records (e.g., `User.new` or `Post.new`) in the console examples; you MUST use persisted records (e.g., `User.create!` or `Post.create!`) to accurately reflect real Rails console verification.
   - Example format for Pundit:
     ```
     irb(main):001:0> user = User.create!(role: :guest)
     irb(main):002:0> post = Post.create!(user: User.create!(role: :admin))
     irb(main):003:0> Pundit.authorize(user, post, :update?)
     Pundit::NotAuthorizedError: not allowed to update? this #<Post...>
     ```
   - Example format for CanCanCan:
     ```
     irb(main):001:0> ability = Ability.new(User.create!(role: :guest))
     irb(main):002:0> post = Post.create!(user: User.create!(role: :admin))
     irb(main):003:0> ability.authorize!(:update, post)
     CanCan::AccessDenied: You are not authorized to access this page.
     ```
2. **HTTP and Policy Verification**:
   - Provide concrete `curl` requests or controller test commands with expected HTTP response codes (e.g. `403 Forbidden` or `302 Found` redirecting to unauthorized alerts) when access is denied.
3. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | When implementing authorization tests. |

## Additional Resources

- [EXAMPLES.md](EXAMPLES.md) — Complete code examples for Pundit and CanCanCan implementations
- [references/workflow.md](references/workflow.md) — Authorization implementation workflow
