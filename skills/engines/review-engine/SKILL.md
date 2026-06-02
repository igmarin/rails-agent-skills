---
name: review-engine
type: atomic
license: MIT
description: >
  Use when reviewing a Rails engine — must inspect namespace isolation (isolate_namespace), verify configuration seams and check host-app integration (flagging host constant references), verify initialization reload safety (use config.to_prepare, flag load-time global mutations), check that migrations are copied via generator without destructive/irreversible changes, confirm spec/dummy exists and is used for integration specs, and summarize findings by severity flagging High findings first. Suitable for engine code review, engine architecture review, and gem review.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Review Engine

Use this skill when the task is to review an existing Rails engine or propose improvements.

## Quick Reference

| Review Area | Key Checks |
|-------------|------------|
| Namespace | `isolate_namespace` used; clear boundaries; no host constant leakage |
| Host integration | Configuration seams, adapters; no direct host model access |
| Init | No side effects at load time; reload-safe hooks in `config.to_prepare` |
| Migrations | Documented, copied via generator; no implicit or destructive steps |
| Dummy app | Present in spec/; used for integration tests; exercises real mount and config |

## HARD-GATE

```text
Before writing findings, confirm every row in the Quick Reference table has been addressed:
- [ ] Namespace isolation verified
- [ ] Host integration points checked
- [ ] `engine.rb` initializer blocks inspected
- [ ] Migration/generator flow confirmed
- [ ] Dummy app presence and usage confirmed
- [ ] Integration tests exercise real mount

If any box cannot be checked (e.g., file not provided), record it as an open assumption.
```

## Core Process

1. **Identify the engine type and purpose.** Read `lib/<engine_name>/engine.rb` and `lib/<engine_name>/railtie.rb`. Confirm isolated vs plain.
2. **Inspect the namespace and public API surface.** Check for `isolate_namespace` and unqualified top-level constant references.
3. **Check host-app integration points.** Flag direct host constant references. Verify host dependencies flow through config seams.
4. **Check initialization and reload behavior.** Inspect `initializer`, `config.to_prepare`, and `ActiveSupport.on_load`. Flag anything that mutates global state at `require` time outside an initializer block.
5. **Check migrations, generators, and install flow.** Confirm migrations are copied via a generator. Check for destructive or irreversible migrations.
6. **Check dummy-app and integration tests.** Confirm `spec/dummy/` exists and exercises the mount point.
7. **Summarize findings by severity.** Flag High findings first. Do not surface Low findings before architecture issues.

**High-severity finding example (engine reaching into host):**

```ruby
# Bad: engine assumes host model
class MyEngine::SomeService
  def call
    User.find(current_user_id)  # User is host app; engine is coupled
  end
end
```
*Fix: Introduce config (`MyEngine.config.user_finder = ->(id) { User.find(id) }`) and use that.*

**Good (configuration seam):**

```ruby
# Good: engine uses configured dependency
class MyEngine::SomeService
  def call
    MyEngine.config.user_finder.call(current_user_id)
  end
end
```

**Bad (require-time patching — not reload-safe):**

```ruby
# Bad: patches at require time — double-includes on code reload
ActionController::Base.include(MyEngine::ControllerHelpers)
```

**Good (lazy-loaded with `ActiveSupport.on_load`):**

```ruby
# Good: patches only when the framework component is ready, reload-safe
ActiveSupport.on_load(:action_controller) do
  include MyEngine::ControllerHelpers
end
```

## Output Style

When asked to review an engine, your output `answer.md` MUST comply with:

1. **Findings First**: Write the findings section (ordered HIGH -> MEDIUM -> LOW) as the very first section in the concrete artifact `answer.md` (or immediately after the short plan if a plan is requested). For each finding include severity, affected file/area, risk, and smallest credible fix.
2. **Verification Commands**: Include verification commands used, including `grep -r "isolate_namespace" lib/` for namespace isolation, a migration audit such as `grep -R "remove_column\|drop_table\|change_column" db/migrate lib/**/db/migrate` for destructive or irreversible changes, and `grep -r "ActiveSupport.on_load" lib/` or `grep -r "initializer" lib/` to verify initialization reload safety.
3. Include open assumptions and recommended next changes.
4. If no meaningful findings exist, explicitly state so and mention residual testing gaps.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| create-engine | When implementing suggested fixes or refactoring the engine |
| test-engine | When adding missing dummy-app or integration coverage |
| upgrade-engine | When assessing Rails/Ruby version support or deprecation impact |

---

## Extended Reference

> Supplementary detail — consult after completing the Core Process.

**Severity Tiers**
- **High** — causes production failures or breaks host integration (e.g., direct host constant coupling, unsafe boot-time side effects, irreversible migrations without a `down` method).
- **Medium** — degrades maintainability or makes the engine fragile across host apps (e.g., undocumented configuration seams, missing install generator, no dummy app).
- **Low** — style or minor clarity issues; do not surface before architecture findings.

**Common Mistakes**
- Reviewing code style before architecture.
- Missing dummy app coverage check (dummy app must exist and be used).
- Ignoring `engine.rb` (often contains boot-time side effects).

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[FINDINGS.md](FINDINGS.md)** — Use when you need sample findings format and severity classification examples
- **[assets/examples.md](assets/examples.md)** — Use when you need complete engine review examples with findings and recommendations
- **[assets/finding-schema.json](assets/finding-schema.json)** — Use when you need the structured schema for engine review findings output
