# Rails Agent Skills — Claude Code Context

This plugin provides a library of specialized Rails development skills. When a task arrives, check if any skill applies and read it before responding.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

```text
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.

WORKFLOW: PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR

Tests are a GATE. Implementation code CANNOT be written until:
1. The test EXISTS
2. The test has been RUN
3. The test FAILS for the right reason (feature missing, not a typo)
```

Wrote implementation code before the test? Delete it. Start over. No exceptions.

## Primary Workflow: TDD Feature Loop

For Claude Code, **workflow chaining is the primary mechanism**. Skills are building blocks — workflows are the story. The most common daily workflow:

```text
rails-tdd-slices → write failing test
  → [CHECKPOINT: Test Feedback — confirm behavior, boundary, edge cases]
  → [CHECKPOINT: Implementation Proposal — confirm approach before coding]
  → implement (minimal code to pass test) → refactor
  → [GATE: Linters + Full Test Suite]
  → yard-documentation
  → rails-code-review (self-review)
  → rails-review-response (when feedback is received)
  → re-review if Critical findings were addressed
  → PR
```

See [docs/workflow-guide.md](docs/workflow-guide.md) for all workflow diagrams.

## Available Skills

Skills are located in subdirectories of this plugin. Read the relevant `SKILL.md` before responding to any task that matches.

### Planning & Tasks
| Skill | Use when... |
|-------|-------------|
| `create-prd` | User asks to plan a feature or write requirements |
| `generate-tasks` | User asks for implementation steps or task breakdown |
| `ticket-planning` | User wants tickets from a plan |

### Rails Code Quality
| Skill | Use when... |
|-------|-------------|
| `rails-code-review` | Reviewing Rails PRs, controllers, models, migrations — giving a review |
| `rails-review-response` | Received review feedback and need to evaluate, respond, or implement it |
| `rails-architecture-review` | Reviewing app structure, boundaries, fat models/controllers |
| `rails-security-review` | Checking auth, params, XSS, CSRF, SQLi |
| `rails-migration-safety` | Planning or reviewing database migrations |
| `rails-stack-conventions` | Writing new Rails code for PostgreSQL + Hotwire + Tailwind stack |
| `rails-code-conventions` | Daily coding checklist: DRY/YAGNI/PORO/CoC/KISS, linter as style SoT, per-path rules |
| `rails-background-jobs` | Adding or reviewing background jobs |
| `rails-graphql-best-practices` | Building or reviewing GraphQL APIs with graphql-ruby |
| `rails-authorization-policies` | Adding or reviewing roles/permissions (Pundit, CanCanCan, policy objects) |
| `rails-performance-optimization` | Investigating N+1s, slow queries, profiling, caching, query plans |
| `rails-api-versioning` | Versioning REST APIs, deprecation policies, v1/v2 routing |
| `rails-database-seeding` | Designing seeds vs fixtures for dev/test data |
| `rails-frontend-hotwire` | Turbo/Stimulus integration, frames, streams |

### DDD & Domain Modeling
| Skill | Use when... |
|-------|-------------|
| `ddd-ubiquitous-language` | Clarifying domain terms before modeling or refactoring |
| `ddd-boundaries-review` | Reviewing bounded contexts and language leakage |
| `ddd-rails-modeling` | Mapping DDD concepts to Rails models, services, value objects |

### Ruby Patterns
| Skill | Use when... |
|-------|-------------|
| `ruby-service-objects` | Creating service classes with `.call` pattern |
| `ruby-api-client-integration` | Integrating external APIs (Auth/Client/Fetcher/Builder) |
| `strategy-factory-null-calculator` | Building variant-based calculators |
| `yard-documentation` | Writing or reviewing YARD docs |

### Context & Setup
| Skill | Use when... |
|-------|-------------|
| `rails-context-engineering` | Before any code/spec/PRD in an existing Rails codebase — loads schema, routes, nearest patterns, surfaces ambiguity |
| `rails-project-onboarding` | First-time dev environment setup — Docker, env vars, database, test suite |

### Testing
| Skill | Use when... |
|-------|-------------|
| `rspec-best-practices` | Writing, reviewing, or cleaning up RSpec tests |
| `rails-tdd-slices` | Choosing the best first failing spec for a Rails change |
| `rails-bug-triage` | Turning a bug report into a failing spec and fix plan |
| `rspec-service-testing` | Testing service objects |

### Rails Engines
| Skill | Use when... |
|-------|-------------|
| `rails-engine-author` | Creating or scaffolding a Rails engine |
| `rails-engine-testing` | Setting up dummy app and engine specs |
| `rails-engine-reviewer` | Reviewing an existing engine |
| `rails-engine-release` | Preparing an engine release |
| `rails-engine-docs` | Writing engine documentation |
| `rails-engine-installers` | Creating install generators |
| `rails-engine-extraction` | Extracting code from host app to engine |
| `rails-engine-compatibility` | Ensuring cross-version compatibility |
| `api-rest-collection` | Creating or updating Postman collections for REST API endpoints (not GraphQL) |

### Refactoring
| Skill | Use when... |
|-------|-------------|
| `refactor-safely` | Restructuring code while preserving behavior |

## Skill Priority

1. **TDD always** — `rspec-best-practices` applies whenever code is produced
2. **Planning first** — `create-prd`, `generate-tasks` (optionally `ticket-planning`)
3. **Domain discovery next** — `ddd-*` skills when domain is the hard part
4. **Process skills** — `refactor-safely`
5. **Domain skills** — `rails-*`, `ruby-*` for specific implementation

## Typical Workflows

**TDD Feature Loop** *(primary)*:
`rails-tdd-slices` → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → `yard-documentation` → `rails-code-review` → `rails-review-response` (on feedback) → PR

**New feature:**
`create-prd` → `generate-tasks` → *TDD Feature Loop*

**DDD-first:**
`create-prd` → `ddd-ubiquitous-language` → `ddd-boundaries-review` → `ddd-rails-modeling` → `generate-tasks` → *TDD Feature Loop*

**Code review + response:**
`rails-code-review` → `rails-review-response` (on feedback) → re-review if Critical items addressed

**Bug fix:**
`rails-bug-triage` → `rails-tdd-slices` → **[GATE: failing reproduction spec]** → fix → verify test passes

**GraphQL feature:**
`ddd-ubiquitous-language` → `rails-graphql-best-practices` → *TDD Feature Loop* → `rails-security-review`

**New engine:**
`rails-engine-author` → **[GATE: engine specs]** → implement → `rails-engine-docs`

**Refactoring:**
`refactor-safely` → **[GATE: characterization tests pass]** → refactor → verify tests still pass

## Code Quality Defaults

These apply to ALL generated Ruby/Rails code regardless of which skill is active:

**Service response format:** Always return `{ success: bool, response: { ... } }` — data under `response:`, errors under `response: { error: { message: '...' } }`.

**Ruby files:** Every `.rb` file begins with `# frozen_string_literal: true`.

**Error logging:** Every `rescue StandardError` block MUST log message AND backtrace: `Rails.logger.error(e.message)` and `Rails.logger.error(e.backtrace.first(5).join("\n"))`.

**YARD @raise:** Add one `@raise` tag per exception class for every public method that can raise — even internally rescued exceptions.

**RSpec time tests:** Time-dependent behavior MUST use `travel_to` — never stub `Time.now` or set dates in the past.

**Background jobs:** Always include `retry_on ExceptionClass, wait: :polynomially_longer, attempts: N` for transient errors and `discard_on` for permanent errors (e.g. `ActiveRecord::RecordNotFound`).

**Task lists (generate-tasks):** Task 0.0 ALWAYS creates the feature branch. Each implementation task MUST have four sub-tasks: (a) write spec, (b) run spec — verify fails, (c) implement, (d) run spec — verify passes. Always include a Relevant Files section.

## Output Language

Generated artifacts (YARD docs, Postman collections, READMEs, task descriptions) must be in **English** unless the user explicitly requests another language.

## Eval Strategy

Skills are scored on two axes: **skill-specific criteria** AND **model performance baseline-vs-with-context**. A skill that only beats baseline marginally is under-specified — it should change the model's output meaningfully. See [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) for the optimization loop and per-skill targets.
