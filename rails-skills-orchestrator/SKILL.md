---
name: rails-skills-orchestrator
description: >
  Use as the entry point when the task scope is unclear or spans multiple concerns —
  this skill routes and gates only; it does not implement anything itself. Identifies
  which specialized skill to invoke next (rspec-best-practices, rails-code-review,
  rails-tdd-slices, rails-migration-safety, rails-engine-author, ruby-service-objects,
  etc.) and enforces the Tests Gate Implementation mandate across all code-producing
  tasks. Select this INSTEAD of individual Rails skills when you don't yet know which
  specialist applies. Trigger words: where do I start, not sure how to approach this,
  don't know which skill to use, multi-step Rails task, unclear scope, spans multiple
  concerns, new complex Rails feature, how do I begin, what should I do first.
---

# Rails Skills Orchestrator

Routes to the correct specialized skill for any Ruby on Rails task and enforces the Tests Gate Implementation mandate across all code-producing work.

When a task arrives, identify the matching skill from the tables below and **name it explicitly as the next skill to use** before responding further. Generated artifacts (YARD docs, Postman collections, READMEs) must be in **English** unless the user explicitly requests another language.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

Non-negotiable across every code-producing skill. Workflow: **PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR**. No implementation code until the test exists, has been run, and fails for the right reason.

**Gate cycle per behavior:**

1. Write test → `bundle exec rspec path/to/spec` → confirm failure reason is *feature missing*, not a config or syntax error
2. **CHECKPOINT — Test Feedback:** verify right behavior, right boundary, edge cases covered — only proceed once confirmed
3. **CHECKPOINT — Implementation Proposal:** name classes/methods to create or modify, state data flow, wait for explicit approval
4. Write minimal implementation → `bundle exec rspec path/to/spec` → confirm green; full suite → confirm no regressions
5. Refactor — tests stay green → repeat from step 1 for next behavior

**After all behaviors pass:** GATE — `bundle exec rubocop && bundle exec rspec` → YARD docs → README/diagrams → `rails-code-review` self-review → PR → `rails-review-response` on feedback

## Available Skills

### Planning & Tasks

| Skill | Use when... |
| ----- | ----------- |
| **create-prd** | Planning a feature or writing requirements |
| **generate-tasks** | Breaking a PRD into implementation tasks |
| **ticket-planning** | Creating tickets from a plan |

### Rails Code Quality

| Skill | Use when... |
| ----- | ----------- |
| **rails-code-review** | Reviewing Rails PRs, controllers, models, migrations, or queries |
| **rails-review-response** | Evaluating or implementing code review feedback |
| **rails-architecture-review** | Reviewing structure, boundaries, fat models/controllers |
| **rails-security-review** | Auditing for XSS, CSRF, SQL injection, auth flaws |
| **rails-migration-safety** | Planning or reviewing production-safe migrations |
| **rails-stack-conventions** | Writing Rails code for PostgreSQL + Hotwire + Tailwind stack |
| **rails-code-conventions** | Daily coding checklist: DRY/YAGNI/PORO/CoC/KISS, linters, structured logging |
| **rails-background-jobs** | Adding or reviewing background jobs |
| **rails-graphql-best-practices** | Building or reviewing GraphQL APIs with `graphql-ruby` |

### DDD & Domain Modeling

| Skill | Use when... |
| ----- | ----------- |
| **ddd-ubiquitous-language** | Clarifying domain terms or building a shared business glossary |
| **ddd-boundaries-review** | Reviewing bounded contexts and language leakage |
| **ddd-rails-modeling** | Mapping DDD concepts to Rails models, services, and value objects |

### Ruby Patterns

| Skill | Use when... |
| ----- | ----------- |
| **ruby-service-objects** | Creating service classes with `.call` pattern |
| **ruby-api-client-integration** | Integrating external APIs with the layered Auth/Client/Fetcher/Builder pattern |
| **strategy-factory-null-calculator** | Building variant-based calculators with SERVICE_MAP dispatch |
| **yard-documentation** | Writing or reviewing YARD docs for Ruby classes and public methods |

### Context & Setup

| Skill | Use when... |
| ----- | ----------- |
| **rails-context-engineering** | Before any code/spec/PRD in an existing Rails codebase — load schema, routes, nearest patterns, surface ambiguity |

### Testing

| Skill | Use when... |
| ----- | ----------- |
| **rspec-best-practices** | Writing, reviewing, or cleaning up RSpec tests; TDD discipline for all implementation |
| **rails-tdd-slices** | Choosing the best first failing spec for a Rails change |
| **rails-bug-triage** | Turning a bug report into a reproduction spec and fix plan |
| **rspec-service-testing** | Testing service objects (`spec/services/`) |

### Rails Engines

| Skill | Use when... |
| ----- | ----------- |
| **rails-engine-author** | Creating or scaffolding a Rails engine |
| **rails-engine-testing** | Setting up dummy app and engine specs |
| **rails-engine-reviewer** | Reviewing an existing engine |
| **rails-engine-release** | Preparing an engine release |
| **rails-engine-docs** | Writing engine documentation |
| **rails-engine-installers** | Creating install generators |
| **rails-engine-extraction** | Extracting host app code into an engine |
| **rails-engine-compatibility** | Ensuring cross-version compatibility |
| **api-rest-collection** | Generating or updating Postman collections for REST endpoints |

### Refactoring

| Skill | Use when... |
| ----- | ----------- |
| **refactor-safely** | Restructuring code while preserving behavior |

## Skill Priority

When multiple skills could apply: TDD → Planning → Domain discovery → Process (refactor-safely) → Domain implementation (rails-\*, ruby-\*). Use rails-tdd-slices when the first failing spec is not obvious.

## Typical Workflows

Sub-skills are invoked by stating their name as the next skill to apply, e.g. *"Next skill: rails-tdd-slices"*, before proceeding with that skill's instructions.

**TDD Feature Loop** *(primary daily workflow)*:
rails-context-engineering → rails-tdd-slices → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → yard-documentation → rails-code-review → rails-review-response (on feedback) → PR

**Feature (standard):** rails-context-engineering → create-prd → generate-tasks → *TDD Feature Loop*

**Feature (DDD-first):** rails-context-engineering → create-prd → ddd-ubiquitous-language → ddd-boundaries-review → ddd-rails-modeling → generate-tasks → *TDD Feature Loop*

**Code review + response:** rails-code-review → rails-review-response (on feedback) → re-review if Critical items addressed

**Bug fix:** rails-bug-triage → rails-tdd-slices → **[GATE: reproduction spec fails]** → fix → verify passes

**New engine:** rails-engine-author → **[GATE: engine specs fail]** → implement → rails-engine-docs

**Refactoring:** refactor-safely → **[GATE: characterization tests pass on current code]** → refactor → verify still pass

**GraphQL:** ddd-ubiquitous-language → rails-graphql-best-practices → *TDD Feature Loop* → rails-security-review
