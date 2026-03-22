---
name: ddd-boundaries-review
description: >
  Use when reviewing a Ruby on Rails app for Domain-Driven Design boundaries,
  bounded contexts, language leakage, cross-context orchestration, or unclear
  ownership. Covers context mapping, leakage detection, and smallest credible
  boundary improvements.
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

## Examples

### Good: Context Leakage Finding

```ruby
# Fleet::Reservation confirms booking rules,
# but Billing::InvoiceService reaches into reservation state transitions directly.
```

- **Finding:** Billing is orchestrating Fleet state changes. The boundary is unclear. Billing should react to a domain outcome from Fleet, not mutate Fleet internals directly.

### Bad: Pattern-First Review

```ruby
# Bad review:
# "Create five bounded contexts and event buses"
# without naming the business capabilities or ownership conflicts first.
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Everything should become a bounded context" | Many apps only have a few real contexts; over-splitting creates ceremony |
| Reviewing folders without reviewing language | Directory structure alone does not prove domain boundaries |
| Solving context leakage with shared utility modules | Shared utils often hide ownership problems instead of fixing them |
| Recommending a rewrite first | Start with the smallest credible boundary improvement |

## Red Flags

- One model serves unrelated workflows with different language
- Multiple services mutate the same concept with different rules
- Cross-context constants, callbacks, or direct state changes are common
- People describe ownership with "whoever needs it" instead of a named context

## Integration

| Skill | When to chain |
|-------|---------------|
| **ddd-ubiquitous-language** | When the review is blocked by fuzzy or overloaded terminology |
| **ddd-rails-modeling** | When a context is clear and needs entities/value objects/services modeled cleanly |
| **rails-architecture-review** | When the same problem also needs a broader Rails structure review |
| **refactor-safely** | When the recommended improvement needs incremental extraction instead of a rewrite |
