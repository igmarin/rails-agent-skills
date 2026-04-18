---
name: ddd-boundaries-review
description: >
  Use when reviewing a Ruby on Rails app for Domain-Driven Design boundaries,
  bounded contexts, language leakage, cross-context orchestration, or unclear
  ownership. Identifies misplaced domain models, detects cross-context coupling,
  names ownership conflicts, and recommends the smallest credible boundary
  improvement. Covers context mapping and leakage detection.
---

# DDD Boundaries Review

Use this skill when the main problem is not syntax or style, but unclear domain boundaries.

**Core principle:** Fix context leakage before adding more patterns.

## Quick Reference

| Area | What to check |
|------|---------------|
| Bounded contexts | Distinct language, rules, and ownership |
| Context leakage | One area reaching across another's concepts casually |
| Shared models | Same object name used with conflicting meanings |
| Orchestration | Use cases coordinating multiple contexts without a clear owner |
| Ownership | Who owns invariants, transitions, and side effects |

## HARD-GATE

```text
DO NOT recommend splitting code into new contexts unless the business boundary is explicit enough to name.
DO NOT treat every large module as a bounded context automatically.
ALWAYS identify the leaked language or ownership conflict before proposing structural changes.
```

## When to Use

- The repo appears to mix multiple business concepts under one model or service namespace.
- Teams are debating ownership, boundaries, or where a rule belongs.
- A Rails architecture review reveals cross-domain coupling.
- **Next step:** Chain to `ddd-rails-modeling` when a context is clear enough to model tactically, or to `refactor-safely` when boundaries need incremental extraction.

## Review Order

1. **Map entry points:** Start from controllers, jobs, services, APIs, and UI flows that expose business behavior.
2. **Name the contexts:** Group flows and rules by business capability, not by current folder names alone.
3. **Find leakage:** Look for terms, validations, workflows, or side effects crossing context boundaries.
4. **Check ownership:** Decide which context should own invariants, transitions, and external side effects.
5. **Propose the smallest credible improvement:** Rename, extract, isolate, or wrap before attempting large reorganizations.

## Output Style

Write findings first.

For each finding include:

- **Severity**
- **Contexts involved**
- **Leaked term / ownership conflict**
- **Why the current boundary is risky**
- **Smallest credible improvement**

Then list open questions and recommended next skills.

## Detecting Leakage

Use ripgrep to find cross-context references before reading code manually:

```bash
# Find references from one context into another
rg 'Billing.*Fleet|Fleet.*Billing' app/

# Find cross-namespace constant usage
rg 'Billing::[A-Z]' app/services/fleet/
rg 'Fleet::[A-Z]' app/services/billing/

# Find callbacks that touch foreign concepts
rg 'after_(create|update|save).*Job|after_(create|update|save).*Mailer' app/models/
```

See [EXAMPLES.md](./EXAMPLES.md) for a worked leakage example, a sample finding block, and pitfalls.

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | When the review is blocked by fuzzy or overloaded terminology |
| **ddd-rails-modeling** | When a context is clear and needs entities/value objects/services modeled cleanly |
| **rails-architecture-review** | When the same problem also needs a broader Rails structure review |
| **refactor-safely** | When the recommended improvement needs incremental extraction instead of a rewrite |
