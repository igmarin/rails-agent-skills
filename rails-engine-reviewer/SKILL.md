---
name: rails-engine-reviewer
description: >
  Use when reviewing a Rails engine, mountable engine, engine.rb, host-app integration,
  install generators, dummy app coverage, namespace boundaries, or engine best practices.
  Trigger words: review, engine.rb, isolate_namespace, host integration, dummy app,
  coupling, architecture.
---
# Rails Engine Reviewer

Use this skill when the task is to review an existing Rails engine or propose improvements.

Prioritize architectural risks over style comments. The main review targets are coupling, unclear host contracts, unsafe initialization, and weak integration coverage.

## Quick Reference

| Review Area | Key Checks |
|-------------|------------|
| Namespace | `isolate_namespace` used; clear boundaries; no host constant leakage |
| Host integration | Configuration seams, adapters; no direct host model access |
| Init | No side effects at load time; reload-safe hooks in `config.to_prepare` |
| Migrations | Documented, copied via generator; no implicit or destructive steps |
| Dummy app | Present in spec/; used for integration tests; exercises real mount and config |

## Review Order

1. Identify the engine type and purpose.
2. Inspect the namespace and public API surface.
3. Check host-app integration points.
4. Check initialization and reload behavior.
5. Check migrations, generators, and install flow.
6. Check dummy-app and integration tests.
7. Summarize findings by severity.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Reviewing code style before architecture | Style is low impact; coupling, host assumptions, and unsafe init cause production failures |
| Missing dummy app coverage check | Dummy app must exist and be used; engines without it cannot prove host integration works |
| Ignoring engine.rb | engine.rb often contains boot-time side effects; always inspect it |

## Red Flags

- engine.rb with side effects at load time (writes, mutations, eager loading of host code)
- No namespace isolation; engine routes or models collide with host
- Test suite passes only with a specific host app; no dummy app or generic integration coverage

## What Good Looks Like

- Clear namespace boundaries.
- `isolate_namespace` used when the engine owns routes/controllers/views.
- Small public API and explicit configuration surface.
- Minimal assumptions about host authentication, user model, jobs, assets, and persistence.
- Idempotent generators and documented setup.
- Integration tests through a dummy app.

## High-Severity Findings

Flag these first:

- Hidden dependency on a specific host model or constant.
- Initializers that mutate global state unsafely or perform writes at boot.
- Engine code reaching into host internals without an adapter or configuration seam.
- Migrations or setup steps that are implicit, undocumented, or destructive.
- Reload-unsafe decorators or patches outside `config.to_prepare`.

## Medium-Severity Findings

- Public API spread across many constants or modules.
- Engine routes/controllers not properly namespaced.
- Asset, helper, or route naming collisions.
- Missing generator coverage or weak install story.
- Dummy app present but not used for meaningful integration tests.

## Low-Severity Findings

- Inconsistent file layout.
- Overly clever metaprogramming where plain objects would be clearer.
- Readme/setup docs that drift from the code.

## Output Format

Write findings first. For each finding include:

- severity
- affected file or area
- why it is risky
- the smallest credible fix

Then include:

- open assumptions
- recommended next changes

If no meaningful findings exist, say so explicitly and mention any residual testing gaps.

## Common Fixes To Suggest

- Add a configuration object instead of hardcoded host constants.
- Move host integration behind adapters or service interfaces.
- Add `isolate_namespace`.
- Move reload-sensitive hooks into `config.to_prepare`.
- Add install generators for migrations or initializer setup.
- Add dummy-app request/integration coverage.

## Examples

**High-severity finding (engine reaching into host):**

```ruby
# Bad: engine assumes host model
class MyEngine::SomeService
  def call
    User.find(current_user_id)  # User is host app; engine is coupled
  end
end
```

- **Severity:** High. **Area:** `MyEngine::SomeService`. **Risk:** Engine depends on host `User`; breaks when used in another app. **Fix:** Introduce config: `MyEngine.config.user_finder = ->(id) { User.find(id) }` (or an adapter), and use that in the engine.

**Good (configuration seam):**

```ruby
# Good: engine uses configured dependency
class MyEngine::SomeService
  def call
    MyEngine.config.user_finder.call(current_user_id)
  end
end
```

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When implementing suggested fixes or refactoring the engine |
| rails-engine-testing | When adding missing dummy-app or integration coverage |
| rails-engine-compatibility | When assessing Rails/Ruby version support or deprecation impact |
