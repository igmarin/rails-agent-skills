---
name: rails-agent-skills
type: catalog
description: >
  Entry point for Rails development workflows covering TDD, RSpec, Service Objects, DDD, GraphQL,
  Engines, and Code Quality. Use when the user asks about Ruby on Rails development patterns,
  needs RSpec test suites generated, wants service objects scaffolded, is setting up GraphQL schemas,
  performing Rails code review, refactoring .rb files, working with domain-driven design, implementing
  background jobs, conducting Rails security checks, or building Rails engines. Generates RSpec tests,
  structures service objects, enforces TDD workflows, configures GraphQL schemas, and coordinates
  domain-driven design patterns. Trigger keywords: Rails, RSpec, TDD, Rails testing, Rails refactor,
  Rails API, Rails code review, domain driven design, service objects, GraphQL, Rails engine, Ruby,
  .rb, background jobs, Rails migrations, Rails security check.
---

# Rails Agent Skills

This skill coordinates disciplined Rails development by sequencing atomic skills for each task. It defines what to run, in what order, and how to validate each step.

**Core principle:** Atomic, task-specific instructions that turn AI coding assistants into reliable Rails collaborators through TDD and idiomatic patterns.

## Activating Atomic Skills

To activate an atomic skill, read its corresponding Markdown file from the skills bundle and follow its instructions as the operative prompt for that step. If a skill file is unavailable, use the inline fallback guidance in the Skill Catalog below rather than halting entirely — note any gaps in output and proceed with best-effort idiomatic Rails conventions.

## HARD-GATES

### 1. Context First (Pre-flight)

1. Do not perform any implementation or review action without first running `load-context`.
2. Synchronize with the host application's schema, routes, and established patterns before producing any output.

### 2. Tests Gate Implementation

1. Implementation code cannot be written until a test exists for the target behaviour.
2. The test must be executed via `bundle exec rspec <spec_file>` before implementation begins.
3. The test must fail for the correct reason (feature missing, not a syntax error) before proceeding.

## Core Process

1. **Context Initialization (CRITICAL):** Activate `load-context`. Confirm schema, routes, and patterns are loaded before any other step.
2. **Discovery:** Identify which atomic skills from the catalog match the current task.
3. **Execution Loop:**
   - **Plan:** Activate `plan-tests`. Output: a list of pending test cases with descriptions.
   - **Act:** Activate `write-tests`. Run `bundle exec rspec <spec_file>` — confirm output shows red (failure for the right reason). Then activate `implement`. Run `bundle exec rspec <spec_file>` — confirm green. Then activate `apply-code-conventions`.
   - **Polish:** Activate `write-yard-docs` and `code-review`.
4. **Validation:** After each atomic skill completes, verify its declared `Output Style` checklist before proceeding to the next step. If a step produces unexpected failures, re-run `load-context` before retrying.

## Worked Example: Adding a Service Object with Tests

```
Step 1 — load-context
  Input:  project root directory
  Action: Read schema.rb, routes.rb, and existing service objects
  Output: Confirmed patterns (e.g., services inherit ApplicationService, use call)

Step 2 — plan-tests
  Input:  "Create an OrderFulfillmentService"
  Output: [
    "returns success when inventory is available",
    "returns failure when inventory is insufficient",
    "enqueues FulfillmentJob on success"
  ]

Step 3 — write-tests
  Input:  test plan above
  Output: spec/services/order_fulfillment_service_spec.rb (written, not passing)
  Validate: bundle exec rspec spec/services/order_fulfillment_service_spec.rb
            → Expect: 3 examples, 3 failures (NameError or similar — feature missing)

Step 4 — implement
  Input:  failing spec
  Output: app/services/order_fulfillment_service.rb
  Validate: bundle exec rspec spec/services/order_fulfillment_service_spec.rb
            → Expect: 3 examples, 0 failures

Step 5 — apply-code-conventions + write-yard-docs + code-review
  Output: Linted file with YARD docs and review comments resolved
```

## Skill Catalog

| Category | Skill | Fallback Guidance (if file unavailable) |
|----------|-------|------------------------------------------|
| **Context** | `load-context` | Read `schema.rb`, `routes.rb`, and a sample service/model; note conventions manually |
| **Testing** | `plan-tests` | List expected behaviours as RSpec `it` descriptions before writing code |
| **Testing** | `write-tests` | Write RSpec examples using `described_class`, `let`, `expect`, `have_received` idioms |
| **Testing** | `test-service`, `triage-bug` | Follow standard RSpec unit-test patterns; isolate dependencies with doubles |
| **DDD** | `define-domain-language`, `model-domain`, `review-domain-boundaries` | Apply standard DDD vocabulary; group by bounded context |
| **Quality** | `code-review`, `security-check`, `apply-code-conventions`, `refactor-code` | Apply Rails best practices, Brakeman findings, and RuboCop rules inline |
| **API/Infra** | `implement-graphql`, `integrate-api-client`, `implement-background-job`, `review-migration` | Follow graphql-ruby conventions, ActiveJob patterns, and strong-migration rules |
| **Engines** | `create-engine`, `test-engine`, `release-engine`, `document-engine` | Use `rails plugin new --mountable`; isolate specs under `spec/` inside the engine root |
| **Patterns** | `create-service-object`, `write-yard-docs` | Inherit `ApplicationService`, expose `.call`, document with `@param`/`@return` YARD tags |
| **Setup** | `setup-environment` | Verify Ruby version, `bundle install`, and `bin/rails db:setup` |

*The complete list of all 28 local atomic skills and 9 personas is defined in `directory.json` at the project root. This repository also depends on `igmarin/ruby-core-skills` for 15 additional core skills (Process, Code Quality, Orchestration, DDD, and Ruby patterns).*

## Integration

- **`directory.json`** (project root): Canonical registry of all 28 local atomic skills and 9 personas — names, file paths, and metadata. This is the source of truth for skill discovery.
- **`docs/reference/skill-catalog.md`**: Human-readable reference with usage notes for each skill; useful for manual lookup when `directory.json` is unavailable.
- **`skill-router`**: Orchestration layer that maps incoming tasks to the correct atomic skill sequence; invoked automatically when this entry-point skill is activated.

## Core Dependencies

This repository depends on `igmarin/ruby-core-skills` for foundational DDD and Ruby pattern skills. The following 15 core skills are auto-detected and available when this plugin is installed alongside `ruby-core-skills`:

**DDD Skills (3):**
- `define-domain-language` — Domain terms glossary
- `review-domain-boundaries` — Review bounded contexts and language leakage
- `model-domain` — Map DDD to Rails (models, services, value objects)

**Ruby Pattern Skills (4):**
- `create-service-object` — `.call` pattern, response contract, YARD
- `integrate-api-client` — Layered architecture for external APIs
- `implement-calculator-pattern` — Variant-based calculators
- `write-yard-docs` — Inline documentation with YARD

**Process Skills (5):**
- `tdd-process` — TDD discipline and workflow
- `refactor-process` — Refactor preserving behavior
- `review-process` — Systematic code review
- `security-review-process` — Security audit workflow
- `test-planning-process` — Test planning and selection

**Code Quality Skills (2):**
- `triage-bug` — Bug diagnosis and reproduction
- `respond-to-review` — Respond to review feedback

**Orchestration Skills (1):**
- `skill-router` — Routes to correct specialized skill

---
