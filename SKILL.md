---
name: rails-agent-skills
description: >
  Master orchestrator for the Rails Agent Skills library. Use to discover and activate 41 atomic
  Rails development skills as listed in tile.json. Covers TDD (RSpec), Service Objects, DDD,
  GraphQL, Engines, and Code Quality. Enforces strict engineering discipline.
  rails, rspec, tdd, service objects, graphql, ddd, ruby on rails.
---

# Rails Agent Skills

Master entry point for the library. This skill helps you navigate and activate the 41 atomic skills required for disciplined Rails development.

**Core principle:** Atomic, task-specific instructions that turn AI coding assistants into reliable Rails collaborators through TDD and idiomatic patterns.

## Quick Reference (Atomic Paths)

| Task | Primary Atomic Skill |
|------|----------------------|
| **Testing** | `plan-tests`, `write-tests`, `test-service` |
| **Quality** | `code-review`, `security-check`, `refactor-code` |
| **Patterns** | `create-service-object`, `write-yard-docs` |
| **Setup** | `load-context`, `setup-environment` |

## HARD-GATES

### 1. Context First (Pre-flight)
```text
DO NOT perform any atomic implementation or review action without first
running 'load-context'. You must synchronize with the host application's
schema, routes, and established patterns before providing any output.
```

### 2. Tests Gate Implementation
```text
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.
Implementation code CANNOT be written until:
  1. The test EXISTS
  2. The test has been RUN
  3. The test FAILS for the right reason (feature missing, not a typo)
```

## Core Process

1. **Context Initialization:** (CRITICAL) Start every session by activating `load-context`.
2. **Discovery:** Use this skill to identify which atomic skills from the 41-skill catalog match the current task.
3. **Execution Loop:**
   - **Plan:** Activate `plan-tests`.
   - **Act:** Activate `write-tests` -> `implement` -> `apply-code-conventions`.
   - **Polish:** Activate `write-yard-docs` and `code-review`.
4. **Validation:** Ensure all atomic outputs adhere to the `Output Style` of the activated skill.

## Skill Catalog (Categorized)

| Category | Skills |
|----------|--------|
| **Testing** | `plan-tests`, `write-tests`, `test-service`, `triage-bug` |
| **DDD** | `define-domain-language`, `model-domain`, `review-domain-boundaries` |
| **Quality** | `code-review`, `security-check`, `apply-code-conventions`, `refactor-code` |
| **API/Infra** | `implement-graphql`, `integrate-api-client`, `implement-background-job`, `review-migration` |
| **Engines** | `create-engine`, `test-engine`, `release-engine`, `document-engine` |

*See `tile.json` for the complete list of 41 skills.*

## Integration

- **Source of Truth:** `tile.json` (List of all 41 atomic skills)
- **Manual Discovery:** `docs/reference/skill-catalog.md`
- **Orchestration:** `skill-router`

---
