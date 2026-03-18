---
name: rails-code-review
description: >
  Use when reviewing Rails pull requests, checking controller or model conventions,
  validating migration safety, auditing query performance, or when the user asks
  for a Rails code review. Covers routing, ActiveRecord, security, caching, jobs,
  and Rails Way compliance. Also applies when receiving review feedback on Rails code.
---

# Rails Code Review (The Rails Way)

When **reviewing** Rails code, analyze it against the following areas. When **writing** new code, follow **rails-stack-conventions** for style and structure.

**Core principle:** Review early, review often. Verify before implementing feedback.

## HARD-GATE: After implementation (before PR)

```
Code review is part of delivery, not only "when someone comments on GitHub."

After implementation + green tests + YARD + doc updates (per generate-tasks):

1. Run a self-review on the full branch diff using the Review Order below.
2. Fix Critical items; address Suggestion items or ticket follow-ups explicitly.
3. Only then open the PR or hand off for human review.

Skipping self-review treats the plan as unfinished. generate-tasks must end
with a "Code review before merge" parent task.
```

## Quick Reference

| Area | Key Checks |
|------|------------|
| Routing | RESTful, shallow nesting, named routes, constraints |
| Controllers | Skinny, strong params, `before_action` scoping |
| Models | Structure order, `inverse_of`, enum values, scopes over callbacks |
| Queries | N+1 prevention, `exists?` over `present?`, `find_each` for batches |
| Migrations | Reversible, indexed, foreign keys, concurrent indexes |
| Security | Strong params, parameterized queries, no `html_safe` abuse |
| Caching | Fragment caching, Russian doll, ETags |
| Jobs | Idempotent, retriable, appropriate backend |

## Review Order

1. **Configuration & Environments** — Encrypted credentials, Zeitwerk autoloading, per-environment logging.
2. **Routing** — RESTful `resources`/`resource`, max one level nesting (prefer shallow), named routes, constraints.
3. **Controllers** — Action order (index, show, new, edit, create, update, destroy), strong params with `permit`, `before_action` with `only:`/`except:`, skinny controllers, `respond_to` for formats.
4. **Action View** — Partials and layouts, no logic in views (use helpers/presenters), `content_for`/`yield`, Rails helpers over raw HTML.
5. **ActiveRecord Models** — Structure order: extends, includes, constants, attributes, enums, associations, delegations, validations, scopes, callbacks, class methods, instance methods. Use `inverse_of`, explicit enum values, `validates` (not `validates_presence_of`), scopes for reusable queries, limit callbacks.
6. **Associations** — `dependent:` for orphaned records, `through:` for many-to-many, STI only when justified.
7. **Queries** — `includes`/`preload`/`eager_load` for N+1, `exists?` over `present?`, `pluck` for arrays, `find_each` for large sets, `insert_all` for bulk, `load_async` (Rails 7+), transactions for atomicity.
8. **Migrations** — Reversible (`change`), indexes on WHERE/JOIN columns, `add_reference` with `foreign_key: true`.
9. **Validations** — Built-in validators, conditional (`if:`/`unless:`), custom validators for complex rules.
10. **I18n** — User-facing strings via I18n, lazy lookup in views, locale from user preferences or headers.
11. **Sessions & Cookies** — No complex objects in session, signed/encrypted cookies, flash for temporary messages.
12. **Security** — Strong params, parameterized queries, no unnecessary `raw`/`html_safe`, `protect_from_forgery`, CSP headers, masked sensitive data in logs.
13. **Caching & Performance** — Fragment caching, Russian doll, `Rails.cache`, ETags, `EXPLAIN` for slow queries.
14. **Background Jobs** — Active Job, idempotent and retriable, appropriate backend.
15. **Testing (RSpec)** — BDD, descriptive blocks, `let`/`let!`, FactoryBot, shared examples, mocked external services.

## Severity Levels

Use these levels when reporting findings:

| Level | Meaning | Action |
|-------|---------|--------|
| **Critical** | Security risk, data loss, or crash | Fix before merge |
| **Suggestion** | Convention violation or performance concern | Fix in this PR or create follow-up |
| **Nice to have** | Style improvement, minor optimization | Optional |

## HARD-GATE: Receiving Review Feedback

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate the technical requirement
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

**Forbidden responses:**
- "You're absolutely right!" (performative)
- "Great point!" / "Excellent feedback!" (performative)
- "Let me implement that now" (before verification)

**Instead:** Restate the technical requirement, ask clarifying questions, push back with technical reasoning if wrong, or just start working.

**Implementation order for multi-item feedback:**
1. Clarify anything unclear FIRST
2. Blocking issues (breaks, security)
3. Simple fixes (typos, imports)
4. Complex fixes (refactoring, logic)
5. Test each fix individually
6. Verify no regressions

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Skinny controller" means move everything to model | Move to services, not models — avoid fat models |
| Skipping N+1 check because "it's just one query" | One query per record in a collection is N+1 |
| Using `permit!` for convenience | Privilege escalation risk — always whitelist attributes |
| Adding index in same migration as column | On large tables, separate migration with `algorithm: :concurrent` |
| Callback for business logic | Callbacks are for persistence-level concerns, not orchestration |
| Blind implementation of review feedback | Verify against codebase first — reviewer may lack context |
| Performative agreement with reviewer | Technical acknowledgment or just fix it — actions over words |

## Red Flags

- Controller action longer than ~15 lines of logic
- Model with more than 3 callbacks
- `permit!` anywhere in production code
- Query without eager loading inside a loop
- Migration combining schema change and data backfill
- `html_safe` or `raw` on user-provided content
- Implementing review feedback without verifying it first
- Using "should", "probably" when claiming something passes

## Integration

| Skill | When to chain |
|-------|---------------|
| **api-postman-collection** | When reviewing API or endpoint changes (ensure Postman collection is updated) |
| **rails-stack-conventions** | When writing new code (not reviewing) |
| **rails-architecture-review** | When review reveals structural problems |
| **rails-security-review** | When review reveals security concerns |
| **rails-migration-safety** | When reviewing migrations on large tables |
| **rspec-best-practices** | When reviewing test quality |
| **refactor-safely** | When review suggests refactoring |
| **generate-tasks** | Task lists end with self-review / PR-readiness steps |
| **yard-documentation** | Confirm new public API is documented before approving |
