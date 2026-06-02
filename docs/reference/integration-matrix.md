# Integration Matrix — Rails Agent Skills

Integration matrix: which skill connects to which and in what order.

---

## Format

- `A → B` means: after A, B typically follows
- `[checkpoint]` indicates explicit pause point
- `[gate]` indicates mandatory gate

---

## Complete Agent Loops

### TDD Feature Loop (Main)

```text
skills/context/load-context
    ↓
skills/testing/plan-tests
    ↓
skills/testing/write-tests → [checkpoint: Test Feedback]
    ↓
[checkpoint: Implementation Proposal]
    ↓
Implement
    ↓
[gate: Linters + Full Suite]
    ↓
write-yard-docs *(from ruby-core-skills)*
    ↓
code-review → respond-to-review *(from ruby-core-skills)* (if feedback) → PR
```

### Feature from Scratch

```text
skills/context/load-context
    ↓
define-domain-language *(from ruby-core-skills)* → review-domain-boundaries *(from ruby-core-skills)* → model-domain *(from ruby-core-skills)*
    ↓
[TDD Feature Loop]
```

### Bug Fix

```text
triage-bug *(from ruby-core-skills)*
    ↓
plan-tests
    ↓
[gate: Write failing reproduction spec]
    ↓
Minimal fix
    ↓
Verify passes + no regressions
    ↓
code-review
```

### Refactoring

```text
refactor-code
    ↓
[gate: Characterization tests pass]
    ↓
Extract in small steps
    ↓
Verify after each step
    ↓
code-review
```

### New Engine

```text
create-engine
    ↓
[gate: Engine specs fail]
    ↓
test-engine
    ↓
document-engine
    ↓
create-engine-installer
    ↓
review-engine
    ↓
release-engine
    ↓
upgrade-engine
```

### Engine Extraction

```text
extract-engine
    ↓
refactor-code
    ↓
[gate: Characterization tests]
    ↓
create-engine
    ↓
test-engine
```

### GraphQL Feature

```text
define-domain-language *(from ruby-core-skills)*
    ↓
implement-graphql
    ↓
plan-tests
    ↓
[TDD Feature Loop]
    ↓
review-migration (if DB changes)
    ↓
security-check
```

### External API Integration

```text
plan-tests
    ↓
integrate-api-client *(from ruby-core-skills)*
    ↓
write-yard-docs *(from ruby-core-skills)*
    ↓
code-review
```

---

## Integrations by Skill



### plan-tests
| Next | When |
|------|------|
| write-tests | To write the spec |

### write-tests
| Next | When |
|------|------|
| create-service-object *(from ruby-core-skills)* | If feature requires service |
| integrate-api-client *(from ruby-core-skills)* | If integrating external API |
| implement-background-job | If there are jobs |
| review-migration | If there is a migration |
| implement-graphql | If it's GraphQL |

### create-service-object *(from ruby-core-skills)*
| Next | When |
|------|------|
| test-service | To test the service |
| write-yard-docs *(from ruby-core-skills)* | Document the public service |

### code-review

| Next | When |
|------|------|
| security-check | If there are security concerns |
| review-architecture | If there are architecture issues |
| respond-to-review *(from ruby-core-skills)* | If feedback received |

---

## Quick Decision Matrix

```text
New to project?
  ├─ Yes → load-context → setup-environment
  └─ No → What do you need?

       Refactor?
            ├─ Yes → refactor-code
            └─ No → plan-tests → write-tests

                      Type?
                      ├─ Service → create-service-object *(from ruby-core-skills)* → test-service
                      ├─ API integration → integrate-api-client *(from ruby-core-skills)*
                      ├─ Background job → implement-background-job
                      ├─ Migration → review-migration
                      ├─ GraphQL → implement-graphql
                      ├─ Authorization → implement-authorization
                      ├─ Performance → optimize-performance
                      └─ Engine → create-engine

Review?
  └─ code-review → (security-check | review-architecture) → respond-to-review *(from ruby-core-skills)*
```

---

## Checkpoints and Gates

| Name | Type | Defined in | Purpose |
|------|------|------------|---------|
| Test Feedback | checkpoint | plan-tests | Confirm correct test before implementing |
| Implementation Proposal | checkpoint | write-tests | Approve approach before code |
| Linters + Suite | gate | persona-guide.md | All linters and tests pass |
| Characterization Tests | gate | refactor-code | Tests pass on current code before refactor |
| Engine Specs | gate | create-engine | Specs fail before implementing engine |

---

## See also

- [Skill Catalog](skill-catalog.md) — Complete skills list
- [Persona Guide](../persona-guide.md) — Narrative workflows and variations
- [Persona Guides Index](../personas/) — Step-by-step persona stages
