---
name: rails-authorization-policies
license: MIT
description: >
  Implement and test authorization in Rails applications using Pundit or CanCanCan.
  Covers policy objects, role-based access control, permission checks, and testing
  strategies. Use when the user needs to implement or troubleshoot authorization in
  a Rails app, set up user roles and permissions, or mentions Pundit, CanCanCan,
  policy objects, access control, roles, or permissions.
---

# Rails Authorization Policies

Implement and test authorization patterns in Rails applications.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md)

## HARD-GATE

```text
ALWAYS test authorization with multiple roles (admin, user, guest)
NEVER rely on presence checks alone — check specific permissions
ALWAYS use policy objects, never inline authorization logic in controllers
```

## Quick Reference

| Gem | Pattern | Best For |
|-----|---------|----------|
| **Pundit** | Explicit policy classes | Complex per-resource rules |
| **CanCanCan** | Centralized Ability class | Simple role-based permissions |

## Implementation Workflow

1. **Add gem** — add `pundit` or `cancancan` to Gemfile and run `bundle install`
2. **Generate base** — run the gem's installer (`rails g pundit:install` or `rails g cancan:ability`)
3. **Define policies/abilities** — create policy classes (Pundit) or populate the Ability class (CanCanCan)
4. **Authorize in controllers** — call `authorize @record` (Pundit) or `authorize! :action, @record` (CanCanCan) in each action
5. **Verify authorization** — attempt an unauthorized action in the browser or console and confirm it raises `Pundit::NotAuthorizedError` or `CanCan::AccessDenied` as expected
6. **Scope queries** — use `policy_scope(Model)` or `accessible_by(current_ability)` for index actions
7. **Test all roles** — write policy specs and request specs covering admin, owner, and guest

See [references/workflow.md](references/workflow.md) for the complete implementation guide with additional detail.

## Patterns

### Pundit

```ruby
class PostPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user_id == user.id
  end
end
```

### CanCanCan

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :update, Post, user_id: user.id
    can :manage, :all if user.admin?
  end
end
```

## Troubleshooting

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `Pundit::NotDefinedError` | No policy class found for the record | Create `app/policies/model_policy.rb` inheriting from `ApplicationPolicy` |
| `Pundit::AuthorizationNotPerformedError` | `authorize` not called in a controller action | Add `authorize @record` in the action, or `after_action :verify_authorized` to catch misses |
| `CanCan::AccessDenied` unexpectedly raised | Ability rules not matching the current user/role | Inspect `current_ability.can?(:action, @record)` in the console to debug rule evaluation |

## Testing

Cover every role (admin, owner, guest) in both policy specs and request specs.

### Inline Policy Spec Example (Pundit)

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

See [EXAMPLES.md](EXAMPLES.md) for complete testing examples including:
- Policy specs with `permit_action` matchers
- Request specs with role matrix
- Shared examples for reusable patterns
