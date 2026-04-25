---
name: rails-architecture-review
license: MIT
description: >
  Use when reviewing Rails application structure, identifying fat models or controllers,
  auditing callbacks, concerns, service extraction, domain boundaries, or general Rails
  architecture decisions. Recommends service object extractions, simplifies callback
  chains, identifies abstraction quality issues, and produces severity-classified
  findings with the smallest credible improvement for each.
license: MIT
---

# Rails Architecture Review

Use this skill when the task is to review or improve the structure of a Rails application or library.

**Core principle:** Prioritize boundary problems over style. Prefer simple objects and explicit flow over hidden behavior.

## Quick Reference

| Area | What to check |
|------|--------------|
| Controllers | Coordinate only — no domain logic |
| Models | Own persistence + cohesive domain rules, not orchestration |
| Services | Create real boundaries, not just moved code |
| Callbacks | Small and unsurprising — no hidden business logic |
| Concerns | One coherent capability per concern |
| External integrations | Behind dedicated collaborators |

## Review Order

1. Identify the main entry points: controllers, jobs, models, services.
2. Check where domain logic lives.
3. Inspect model responsibilities, callbacks, and associations.
4. Inspect controller size and orchestration.
5. **Check concerns, helpers, and presenters** — read each one: does it do one coherent thing, or does it mix auditing + notifications + emails + external API calls? Mixed concerns are High or Medium severity depending on blast radius. **Treat any concern used by only one class as a candidate for deletion — inline it instead.**
6. Check whether abstractions clarify the design or only move code around.
7. **Verify each High-severity finding** by reading the actual code — confirm it is a real structural problem, not just a pattern match on file size or line count.

## Severity Levels

### High-Severity Findings

- Business logic hidden in callbacks or broad concerns
- Controllers orchestrating multi-step domain workflows inline
- Models coupled directly to HTTP, jobs, mailers, or external APIs
- Abstractions that add indirection without a clear responsibility
- Cross-layer constant reach that makes code hard to change

### Medium-Severity Findings

- Duplicated workflow logic across controllers or jobs
- Scopes or class methods carrying too much query or policy logic
- Helpers or presenters leaking domain behavior
- Service objects wrapping trivial one-liners
- Concerns combining unrelated responsibilities — check EVERY concern in the app

## Output Format

Every finding uses this four-field structure:

```
**Severity:** High
**Affected file:** app/controllers/orders_controller.rb — OrdersController#create
**Risk:** Controller runs a 5-step domain workflow. Partial state on failure; untestable without HTTP.
**Improvement:** Extract to Orders::CreateOrder.call(params). Controller handles response/redirect only.
```

**High-severity callback example:**

```ruby
# Bad — hidden side effects on every save
module Auditable
  included do
    after_create :log_creation
  end
  def log_creation
    AuditLog.create!(...)
    Slack.notify(...)      # external API in callback
    UserMailer.admin_alert(...).deliver_later  # mailer in callback
  end
end
```

Fix: keep only `AuditLog.create!` in the callback; move Slack/mailer to an explicit service call at the call site.

See [EXAMPLES.md](./EXAMPLES.md) for mixed-concern and controller workflow patterns.

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| "Fat model is fine, controllers should be skinny" | Both should be focused — extract to services, not models |
| "Service objects for everything" | Trivial one-liner wrappers add indirection without value |
| Model with 500+ lines and multiple concerns | Extract domain logic to services or query objects |
| Controller action > 15 lines | Extract to service — controller coordinates, not implements |

## Output Style

**Begin with entry points.** Open the review by identifying the application's entry points (controllers, jobs, public API surface) before listing findings. Then write findings ordered by review area — boundary problems first, then model/callback issues, then concerns/helpers.

For each finding include:

- Severity
- Affected files or area
- Why the structure is risky
- The smallest credible improvement

Then list open assumptions and recommended next refactor steps.

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-boundaries-review** | When the architecture issue is really about bounded contexts, ownership, or language leakage |
| **ddd-rails-modeling** | When the review identifies unclear domain modeling choices inside a context |
| **rails-code-review** | For detailed code-level review after architecture review |
| **refactor-safely** | When architecture review identifies extraction candidates |
| **ruby-service-objects** | When recommending service extraction |
| **rails-security-review** | When architecture review reveals security boundary concerns |
