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

## Core Process

### Implementation Workflow

1. **Add gem** — add `pundit` or `cancancan` to Gemfile and run `bundle install`
2. **Generate base** — run the gem's installer (`rails g pundit:install` or `rails g cancan:ability`)
3. **Define policies/abilities** — create policy classes (Pundit) or populate the Ability class (CanCanCan); always use policy objects, never inline authorization logic in controllers
4. **Authorize in controllers** — call `authorize @record` (Pundit) or `authorize! :action, @record` (CanCanCan) in each action
5. **Verify authorization** — attempt an unauthorized action in the browser or console and confirm it raises `Pundit::NotAuthorizedError` or `CanCan::AccessDenied` as expected; use persisted records (e.g., `User.create!`) not unsaved ones
6. **Scope queries** — use `policy_scope(Model)` or `accessible_by(current_ability)` for index actions
7. **Test all roles** — write policy specs and request specs covering admin, owner, and guest; check specific permissions, never presence checks alone

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

When implementing or reviewing authorization, the output `answer.md` must include:

1. **Manual Denied-Action Verification** — a dedicated section with simulated Rails console output showing the authorization exception raised when an unauthorized action is attempted. Always use persisted records (`User.create!`, `Post.create!`), never unsaved ones.
2. **HTTP and Policy Verification** — concrete `curl` requests or controller test commands with expected HTTP response codes (e.g. `403 Forbidden` or `302 Found`) when access is denied.
3. **Language** — English unless explicitly requested otherwise.

See **[references/output-style.md](references/output-style.md)** for full formatting examples including Pundit and CanCanCan console output templates.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | When implementing authorization tests. |

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](EXAMPLES.md)** — Use when you need complete Pundit or CanCanCan implementation examples beyond the inline samples
- **[references/workflow.md](references/workflow.md)** — Use when you need the step-by-step authorization implementation workflow diagram
- **[references/output-style.md](references/output-style.md)** — Use when you need full formatting templates for console verification output
