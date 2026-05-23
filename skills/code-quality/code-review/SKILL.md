---
name: code-review
license: MIT
description: >
  Reviews Rails pull requests, focusing on controller/model conventions,
  migration safety, query performance, and Rails Way compliance. Covers
  routing, ActiveRecord, security, caching, and background jobs. Use when
  reviewing existing Rails code for quality, conducting a PR review, or
  doing a code review on Ruby on Rails (RoR) code.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Code Review

## Quick Reference

| Area | Key Checks |
|------|------------|
| Routing | RESTful, shallow nesting, named routes |
| Controllers | Skinny, strong params, scoped `before_action` |
| Models | Structure order, enums, scopes, `inverse_of` |
| Queries | N+1 prevention, `exists?`, `find_each` batches |
| Migrations | Reversible, concurrent indexes on large tables |
| Security | Strong params, no `html_safe` on user input |
| Jobs | Idempotent, retriable, appropriate backend |

## HARD-GATE

```text
After green tests + linters pass + YARD + doc updates:
1. Self-review the actual full branch diff using the Review Order below.
2. Fix Critical items; resolve or ticket Suggestion items.
3. Only then open the PR.
```

## Core Process

When **reviewing** Rails code, analyze it against the following areas. When **writing** new code, follow **apply-code-conventions** and **apply-stack-conventions**.

**Core principle:** Review early, review often. Self-review before PR. Re-review after significant changes.

### Review Order

Work through the diff in this sequence. Detailed criteria: [REVIEW_CHECKLIST.md](./REVIEW_CHECKLIST.md).
Ground every finding in a real changed file/line from the branch diff. If the task does not provide a diff or file contents, say that no concrete findings can be made yet and list the exact diff/files needed.

Configuration → Routing → Controllers → Views → Models → Associations → Queries → Migrations → Validations → I18n → Sessions → Security → Caching → Jobs → Tests

**Edge case handling:**
- **Empty diff**: State "No code changes to review" and stop.
- **Large diff (>50 files)**: Prioritize **Critical** checks first; sample key files for **Suggestion** items.
- **Single file**: Apply all relevant review areas to that file.
- **Test-only changes**: Focus on test quality and organization.

### Severity Levels

Use **only** these labels:

- **`Critical`** — security, data loss, crash, or **Always Critical** (see below). Block merge.
- **`Suggestion`** — conventions, performance, or "Thin controller -> fat model" anti-patterns.
- **`Nice to have`** — small style or micro-optimization.

**Always Critical (flag every occurrence):**
- `params.require(...).permit!` — privilege escalation
- `html_safe` or `raw` on user-supplied content — XSS
- **Business logic inside a controller action** — pricing, tax, or domain calculation
- Unparameterized / string-interpolated SQL — injection
- Destructive migration without a safe path on large tables

### Re-review Criteria

Re-diff the branch after:
1. **Any** Critical fix (mandatory).
2. **>3** Suggestion fixes or any architecture change.
3. Changes affecting queries, auth, or migrations.

## Extended Resources

- [assets/checklist.md](assets/checklist.md)
- [assets/examples.md](assets/examples.md)

## Output Style

Group findings by severity. See [assets/examples.md](./assets/examples.md) for JSON/PR comment shapes.

0. **Review principle** — State: "Review early, review often. Self-review before PR. Re-review after significant changes."
1. **Findings Format**: 
   ```text
   ## Review — <PR title or area>

   ### Critical
   - [path/to/file.rb:LINE] (Area) One-line risk. **Mitigation:** concrete next step.

   ### Suggestion
   - [path/to/file.rb:LINE] (Area) ... **Mitigation:** ...

   **Actions required:** <one line per severity level found — e.g. Critical -> block merge>
   ```
   Findings must come from an actual diff or provided file contents. Do not present a simulated PR review as if it were a completed review of real code.
2. **Tagging**: Tag (Area) from Controllers, Routing, Views, Models, Queries, Migrations, Validations, Security, Caching, Jobs, Tests. Cover **≥4** distinct areas if applicable.
3. **Task-list handoff** — Always include a `Code review before merge` task or task-list line.
4. **Re-review trigger** — State whether Critical fixes, more than three Suggestion fixes, architecture changes, query changes, auth changes, or migration changes require a re-diff before PR approval.
5. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **respond-to-review** | When receiving feedback and deciding implementation |
| **review-architecture** | When review reveals structural problems |
| **review-migration** | When reviewing migrations on large tables |
