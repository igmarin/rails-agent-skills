# Integration Matrix — Rails Agent Skills

Integration matrix: which skill connects to which and in what order.

---

## Format

- `A → B` means: after A, B typically follows
- `[checkpoint]` indicates explicit pause point
- `[gate]` indicates mandatory gate

---

## Complete Workflows

### TDD Feature Loop (Main)

```text
rails-context-engineering
    ↓
rails-tdd-slices
    ↓
rspec-best-practices → [checkpoint: Test Feedback]
    ↓
[checkpoint: Implementation Proposal]
    ↓
Implement
    ↓
[gate: Linters + Full Suite]
    ↓
yard-documentation
    ↓
rails-code-review → rails-review-response (if feedback) → PR
```

### Feature from Scratch

```text
rails-context-engineering
    ↓
create-prd → [gate: PRD approved]
    ↓
generate-tasks
    ↓
[TDD Feature Loop for each task]
```

### Feature DDD-First

```text
rails-context-engineering
    ↓
create-prd
    ↓
ddd-ubiquitous-language → ddd-boundaries-review → ddd-rails-modeling
    ↓
generate-tasks
    ↓
[TDD Feature Loop]
```

### Bug Fix

```text
rails-bug-triage
    ↓
rails-tdd-slices
    ↓
[gate: Write failing reproduction spec]
    ↓
Minimal fix
    ↓
Verify passes + no regressions
    ↓
rails-code-review
```

### Refactoring

```text
refactor-safely
    ↓
[gate: Characterization tests pass]
    ↓
Extract in small steps
    ↓
Verify after each step
    ↓
rails-code-review
```

### New Engine

```text
rails-engine-author
    ↓
[gate: Engine specs fail]
    ↓
rails-engine-testing
    ↓
rails-engine-docs
    ↓
rails-engine-installers
    ↓
rails-engine-reviewer
    ↓
rails-engine-release
    ↓
rails-engine-compatibility
```

### Engine Extraction

```text
rails-engine-extraction
    ↓
refactor-safely
    ↓
[gate: Characterization tests]
    ↓
rails-engine-author
    ↓
rails-engine-testing
```

### GraphQL Feature

```text
ddd-ubiquitous-language
    ↓
rails-graphql-best-practices
    ↓
rails-tdd-slices
    ↓
[TDD Feature Loop]
    ↓
rails-migration-safety (if DB changes)
    ↓
rails-security-review
```

### External API Integration

```text
create-prd
    ↓
generate-tasks
    ↓
rails-tdd-slices
    ↓
ruby-api-client-integration
    ↓
yard-documentation
    ↓
rails-code-review
```

---

## Integrations by Skill

### create-prd
| Next | When |
|------|------|
| generate-tasks | Always after PRD approved |
| ticket-planning | Optional — if tickets needed in tracker |

### generate-tasks
| Next | When |
|------|------|
| rails-tdd-slices | To start development |
| ticket-planning | If tickets needed on board |

### rails-tdd-slices
| Next | When |
|------|------|
| rspec-best-practices | To write the spec |

### rspec-best-practices
| Next | When |
|------|------|
| ruby-service-objects | If feature requires service |
| ruby-api-client-integration | If integrating external API |
| rails-background-jobs | If there are jobs |
| rails-migration-safety | If there is a migration |
| rails-graphql-best-practices | If it's GraphQL |

### ruby-service-objects
| Next | When |
|------|------|
| rspec-service-testing | To test the service |
| yard-documentation | Document the public service |

### rails-code-review
| Next | When |
|------|------|
| rails-security-review | If there are security concerns |
| rails-architecture-review | If there are architecture issues |
| rails-review-response | If feedback received |

---

## Quick Decision Matrix

```text
New to project?
  ├─ Yes → rails-context-engineering → rails-project-onboarding
  └─ No → What do you need?

       Plan?
       ├─ Yes → create-prd → generate-tasks
       └─ No → Implement?

            Bug?
            ├─ Yes → rails-bug-triage
            └─ No → Refactor?
                 ├─ Yes → refactor-safely
                 └─ No → rails-tdd-slices → rspec-best-practices

                      Type?
                      ├─ Service → ruby-service-objects → rspec-service-testing
                      ├─ API integration → ruby-api-client-integration
                      ├─ Background job → rails-background-jobs
                      ├─ Migration → rails-migration-safety
                      ├─ GraphQL → rails-graphql-best-practices
                      ├─ Authorization → rails-authorization-policies
                      ├─ Performance → rails-performance-optimization
                      └─ Engine → rails-engine-author

Review?
  └─ rails-code-review → (rails-security-review | rails-architecture-review) → rails-review-response
```

---

## Checkpoints and Gates

| Name | Type | Defined in | Purpose |
|------|------|------------|---------|
| Test Feedback | checkpoint | rails-tdd-slices | Confirm correct test before implementing |
| Implementation Proposal | checkpoint | rspec-best-practices | Approve approach before code |
| Linters + Suite | gate | workflow-guide.md | All linters and tests pass |
| PRD Approved | gate | create-prd | Don't implement without approved PRD |
| Characterization Tests | gate | refactor-safely | Tests pass on current code before refactor |
| Engine Specs | gate | rails-engine-author | Specs fail before implementing engine |

---

## See also

- [Skill Catalog](skill-catalog.md) — Complete skills list
- [Workflows Index](../workflows/) — Step-by-step workflows
