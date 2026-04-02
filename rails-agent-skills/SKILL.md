---
name: rails-agent-skills
description: >
  This skill is the starting point for all Rails tasks. It identifies the
  correct, more specialized skill to use for a given task, like code reviews,
  TDD, or documentation, and enforces the 'Tests Gate Implementation' mandate.
---

# Rails Agent Skills: Orchestration and Discovery

**Core principle:** This skill serves as the central hub for discovering, understanding, and orchestrating specialized Ruby on Rails development skills. It guides agents to select the most appropriate skill for a given task and ensures adherence to core development mandates.

When a skill might apply to the current task, invoke it before responding. If a task requires coding, always adhere to the Tests Gate Implementation mandate.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

```text
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.

THE WORKFLOW IS: PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR

Tests are a GATE. Implementation code CANNOT be written until:
1. The test for that behavior EXISTS
2. The test has been RUN
3. The test FAILS for the right reason (feature missing, not a typo)

ONLY THEN can implementation code be written.
```

**The full cycle for each piece of behavior:**

1. **Write the test** for the behavior described in the PRD/task
2. **Run the test** — confirm it fails because the feature does not exist yet
3. **CHECKPOINT — Test Feedback:** Present the failing test. Confirm: right behavior? right boundary? edge cases covered? Only proceed once approved.
4. **CHECKPOINT — Implementation Proposal:** Propose the approach in plain language (classes, methods, structure). Wait for confirmation before writing code.
5. **Only now:** write the simplest implementation code to make the test pass
6. **Run the test again** — confirm it passes and no other tests break
7. **Refactor** if needed — tests must stay green
8. **Move to the next behavior** — repeat from step 1

**After all targeted tests pass for the feature:**

1. **GATE — Linters + Full Suite:** Run linters and the full test suite. Fix all failures before continuing.
2. **YARD** — Document new/changed public Ruby API (yard-documentation).
3. **Docs** — Update README, diagrams, and related docs touched by the change.
4. **Code review** — Self-review with rails-code-review, then PR. Use rails-review-response when feedback is received.

**This applies when using:** ruby-service-objects, ruby-api-client-integration, strategy-factory-null-calculator, rails-background-jobs, rails-code-conventions, rails-stack-conventions, rails-engine-author, refactor-safely, and any other skill that results in writing Ruby/Rails code.

**Wrote implementation code before the test?** Delete it. Start over. No exceptions.

**Skipped running the test before implementing?** You don't know if the test works. Stop. Run it. Confirm the failure. Then implement.

## Available Skills

### Planning & Tasks

| Skill | Use when... |
| ----- | ----------- |
| **create-prd** | Planning a new feature, defining requirements, or creating a Product Requirements Document (PRD). |
| **generate-tasks** | Breaking down a PRD or feature into actionable implementation steps, tasks, or a checklist. |
| **ticket-planning** | Drafting or creating Jira tickets from a plan, including sprint placement and issue classification. |

### Rails Code Quality

| Skill | Use when... |
| ----- | ----------- |
| **rails-code-review** | Conducting a code review of Rails pull requests, controllers, models, migrations, or queries. |
| **rails-review-response** | Evaluating, responding to, or implementing feedback received from a code review. |
| **rails-architecture-review** | Reviewing the application\'s structure, domain boundaries, or addressing issues like \'fat models\' or \'fat controllers\'. |
| **rails-security-review** | Auditing for common Rails vulnerabilities (e.g., authentication flaws, XSS, CSRF, SQL injection). |
| **rails-migration-safety** | Planning or reviewing database migrations to ensure safety in production environments. |
| **rails-stack-conventions** | Writing new Rails code specifically for a PostgreSQL, Hotwire, and Tailwind CSS stack, adhering to established conventions. |
| **rails-code-conventions** | Applying daily coding checklist items such as DRY/YAGNI/PORO/CoC/KISS principles, using linters as style guides, structured logging, and path-specific rules. |
| **rails-background-jobs** | Adding or reviewing background jobs |
| **rails-graphql-best-practices** | Building or reviewing GraphQL APIs with \`graphql-ruby\`, covering schema design, N+1 prevention, authorization, error handling, and testing. |

### DDD & Domain Modeling

| Skill | Use when... |
| ----- | ----------- |
| **ddd-ubiquitous-language** | Clarifying domain terms, resolving synonyms, or building a shared business glossary before modeling or refactoring. |
| **ddd-boundaries-review** | Reviewing bounded contexts, ownership, and identifying language leakage within a Rails codebase. |
| **ddd-rails-modeling** | Mapping Domain-Driven Design (DDD) concepts (entities, value objects, services, repositories, events) to Rails without over-engineering. |

### Ruby Patterns

| Skill | Use when... |
| ----- | ----------- |
| **ruby-service-objects** | Creating service classes following the \`.call\` pattern, standardized responses, and transaction management. |
| **ruby-api-client-integration** | Integrating external APIs using the layered Auth/Client/Fetcher/Builder pattern. |
| **strategy-factory-null-calculator** | Building variant-based calculators |
| **yard-documentation** | Writing or reviewing YARD documentation for Ruby classes and public methods. |

### Testing

| Skill | Use when... |
| ----- | ----------- |
| **rspec-best-practices** | Writing, reviewing, or cleaning up RSpec tests — AND the TDD discipline that applies to ALL implementation |
| **rails-tdd-slices** | Choosing the best first failing spec or vertical slice for a Rails change |
| **rails-bug-triage** | Turning a Rails bug report into reproduction, failing spec, and fix plan |
| **rspec-service-testing** | Testing service objects (spec/services/) |

### Rails Engines

| Skill | Use when... |
| ----- | ----------- |
| **rails-engine-author** | Creating or scaffolding a Rails engine |
| **rails-engine-testing** | Setting up dummy app and engine specs |
| **rails-engine-reviewer** | Reviewing an existing engine |
| **rails-engine-release** | Preparing an engine release |
| **rails-engine-docs** | Writing engine documentation |
| **rails-engine-installers** | Creating install generators |
| **rails-engine-extraction** | Extracting code from host app to engine |
| **rails-engine-compatibility** | Ensuring cross-version compatibility |
| **api-rest-collection** | Creating or modifying REST API endpoints — generate/update Postman collection (not for GraphQL) |

### Refactoring

| Skill | Use when... |
| ----- | ----------- |
| **refactor-safely** | Restructuring code while preserving behavior |

## Skill Priority

When multiple skills could apply:

1. **TDD always** — rspec-best-practices TDD discipline applies whenever code is produced; use rails-tdd-slices when the first spec is not obvious
2. **Planning skills first** (create-prd, generate-tasks; **ticket-planning** when the team tracks work in Jira) — determine WHAT to build
3. **Domain discovery skills next** (`ddd-ubiquitous-language`, `ddd-boundaries-review`, `ddd-rails-modeling`) — clarify business language when the domain is the hard part
4. **Process skills second** (refactor-safely) — determine HOW to approach
5. **Domain skills third** (rails-*, ruby-*) — guide specific implementation

## How to Use

1. When a task arrives, check if any skill applies.
2. If a skill applies, read it and follow its instructions.
3. **If the task produces code, TDD applies.** Write the test first.
4. Skills override default behavior but **user instructions always take priority**.
5. If a skill has a HARD-GATE, you must not skip it.
6. When done with a task, check the skill's Integration table for follow-up skills.
7. **Generated artifacts** (documentation, YARD comments, Postman collections, README, examples) must be in **English** unless the user explicitly requests another language.

## Typical Workflows

**TDD Feature Loop** *(primary daily workflow)*:
rails-tdd-slices → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → yard-documentation → rails-code-review → rails-review-response (on feedback) → PR

**New feature:**
create-prd → generate-tasks → (optional ticket-planning) → *TDD Feature Loop*

**DDD-first feature design:**
create-prd → ddd-ubiquitous-language → ddd-boundaries-review → ddd-rails-modeling → generate-tasks → *TDD Feature Loop*

**Code review + response:**
rails-code-review → rails-review-response (on feedback) → re-review if Critical items addressed

**Bug fix:**
rails-bug-triage → rails-tdd-slices → **[GATE: write reproduction spec, run, verify failure]** → fix → verify passes

**GraphQL feature:**
ddd-ubiquitous-language → rails-graphql-best-practices → *TDD Feature Loop* → rails-security-review

**New engine:**
rails-engine-author → **[GATE: write engine specs, run, verify failure]** → implement → rails-engine-docs

**Refactoring:**
refactor-safely → **[GATE: characterization tests, run, verify they pass on current code]** → refactor → verify tests still pass

**New service object:**
rails-tdd-slices → rspec-service-testing → **[GATE: write .call spec, run, verify failure]** → ruby-service-objects → verify spec passes

**External API integration:**
rails-tdd-slices → **[GATE: write layer specs, run, verify failure]** → ruby-api-client-integration → verify → yard-documentation → docs
