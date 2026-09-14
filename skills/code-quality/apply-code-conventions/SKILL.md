---
name: apply-code-conventions
type: atomic
license: MIT
description: >
  Use when applying daily Rails conventions by path (DRY, YAGNI, PORO, CoC, KISS).
  Style defers to the project linter. Trigger words: conventions, clean code,
  RuboCop, DRY, YAGNI.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Apply Code Conventions

Apply the [execution contract](../../../docs/agent-contract.md) before this procedure.

**Style source of truth:** Style and formatting defer to the project's configured linter(s). This skill adds **non-style behavior** and **architecture guidance** only. For Hotwire + Tailwind specifics, see **apply-stack-conventions**.

## Quick Reference

| Topic | Rule |
|-------|------|
| Principles | DRY, YAGNI, PORO where it helps, CoC, KISS |
| Comments / tags | Explain **why**; tagged notes need actionable context |
| Logging | First arg: static string; second arg: hash with `event:` key; no interpolation; backtrace on errors |
| Deep stacks | Chain **apply-stack-conventions** → domain skills (services, jobs, RSpec) |

## HARD-GATE

```text
TESTS GATE IMPLEMENTATION:
When this skill guides new behavior, the tests gate still applies:
PRD → TASKS → TEST (write, run, fail) → IMPLEMENTATION → …
No implementation code before a failing test. See write-tests.
```

## Core Process

When reviewing or refactoring Rails code, follow this sequence. Each step maps to a required checkpoint in your output.

1. **Run linter** — Detect config (e.g. `.rubocop.yml` or `.standard.yml`), run the appropriate tool, note absence if none found. *Output: linter detected (or absent); style defers to it.*
2. **Apply area-specific rules** — Check path patterns and apply targeted guidance from the Apply by area table. *Output: concrete per-path recommendations for every relevant changed file.*
3. **Verify tests gate** — Confirm failing tests exist before any new behavior. *Output: failing spec, run command, expected failure, minimal implementation step, passing rerun.*
4. **Enforce structured logging** — Ensure all `Rails.logger` calls use static strings + structured hashes with an `event:` key, plus backtrace for errors. *Output: apply structured logging rules from Sub-Rules below.*
5. **Enforce comment discipline** — Ensure all tags (`TODO:`, `FIXME:`) have actionable context (owner, ticket). *Output: apply comment discipline rules from Sub-Rules below.*
6. **Chain to specialised skills** — Use the Integration table to pull in deeper guidance (security, jobs, specs) as needed.

> **Language:** English unless explicitly requested otherwise.

## Sub-Rules

### Comments and tagged notes
Comment **why**, not **what**. Tags — `TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:` — must carry actionable context (owner, ticket, next step). Naked tags fail review.
```ruby
# BAD — naked tag, no context
# TODO: fix this

# GOOD — TODO with next step + dependency
# TODO(jsmith, JIRA-1234): replace TIER_RATES with DB-backed lookup once billing API v2 is stable.
```

### Structured Logging
Use the project's installed logger interface. Standard Ruby/Rails loggers accept one message argument; a two-argument structured call requires a verified custom adapter. Log once at the recovery boundary, redact sensitive data, and preserve unexpected exceptions.

```ruby
rescue Timeout::Error => e
  Rails.logger.error({ event: "order.processing_failed", error_class: e.class.name }.to_json)
  raise
end
```

### Apply by area (path patterns)
| Area | Path pattern | Guidance |
|------|--------------|----------|
| **ActiveRecord performance** | `app/models/**/*.rb` | Eager load in loops; prefer `pluck` / `exists?` / `find_each`. |
| **Controllers** | `app/controllers/**/*_controller.rb` | Strong params; thin actions → services; IDOR / PII → **security-check**. |
| **RSpec** | `spec/**/*_spec.rb` | FactoryBot; `let` > `let!` unless eager setup required. |
| **Service objects** | `app/services/**/*.rb` | Single responsibility; `.call` / injected deps. |
| **Background jobs** | `app/jobs/**/*.rb` / `app/workers/**/*.rb` | Idempotency, retries, queue choice, and side-effect boundaries → **implement-background-job**. |

### RSpec and `let_it_be` (test-prof)
Only recommend `let_it_be` if `test-prof` is already in `Gemfile.lock`. Otherwise default to `let`; reach for `let!` only when lazy evaluation would break the example. Don't introduce `test-prof` unless asked.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/checklist.md](assets/checklist.md)** — Use for detailed code review checklists.
- **[assets/snippets.md](assets/snippets.md)** — Use for quick code snippets of common patterns.

Document which assets were loaded and why in your output so the process is verifiable.

## Integration

| Skill | When to chain |
|-------|---------------|
| **apply-stack-conventions** | Stack-specific: PostgreSQL, Hotwire, Tailwind |
| **model-domain** | When domain concepts and invariants need clearer Rails-first modeling choices |
| **create-service-object** | Implementing or refining service objects |
| **implement-background-job** | Workers, queues, retries, idempotency |
| **write-tests** | Spec style, **tests gate** (red/green/refactor), request vs controller specs |
| **security-check** | Controllers, params, IDOR, PII |
| **code-review** | Full PR pass before merge |
