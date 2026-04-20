# Rails Agent Skills — Agent Guidance

This file tells AI agents how to use this repository effectively.

## What This Repository Is

A curated library of 36 AI agent skills for Ruby on Rails development. Each skill encodes specialized workflow knowledge, conventions, and hard gates for a specific Rails domain. Skills are not documentation — they are executable instructions that guide agents through structured workflows.

## How Skills Are Organized

Each skill lives in its own directory with a `SKILL.md` as the entry point. Some skills have supporting files for templates, examples, or extended patterns:

```
skill-name/
├── SKILL.md          # Entry point — always read this first
├── EXAMPLES.md       # Concrete input/output examples (when present)
├── TESTING.md        # Test templates and spec checklists (when present)
├── TASK_TEMPLATES.md # Output templates for generated artifacts (when present)
├── PATTERNS.md       # Extended patterns and factory examples (when present)
└── HEURISTICS.md     # Reference tables too large for inline use (when present)
```

Read `SKILL.md` first. Load supporting files only when the skill links to them and the content is needed.

## Skill Selection

Load the skill that best matches the current task. The bootstrap skill `rails-agent-skills/SKILL.md` maps tasks to skill names. Skills are grouped into:

| Group | Skills |
|-------|--------|
| Planning | `create-prd`, `generate-tasks`, `ticket-planning` |
| Rails code quality | `rails-code-review`, `rails-review-response`, `rails-architecture-review`, `rails-security-review`, `rails-migration-safety`, `rails-stack-conventions`, `rails-code-conventions`, `rails-background-jobs`, `rails-graphql-best-practices`, `rails-authorization-policies`, `rails-performance-optimization`, `rails-api-versioning`, `rails-database-seeding`, `rails-frontend-hotwire`, `api-rest-collection` |
| DDD | `ddd-ubiquitous-language`, `ddd-boundaries-review`, `ddd-rails-modeling` |
| Ruby patterns | `ruby-service-objects`, `ruby-api-client-integration`, `strategy-factory-null-calculator`, `yard-documentation` |
| Context & Setup | `rails-context-engineering`, `rails-project-onboarding` |
| Testing | `rspec-best-practices`, `rails-tdd-slices`, `rails-bug-triage`, `rspec-service-testing` |
| Rails engines | `rails-engine-author`, `rails-engine-testing`, `rails-engine-reviewer`, `rails-engine-release`, `rails-engine-docs`, `rails-engine-installers`, `rails-engine-extraction`, `rails-engine-compatibility` |
| Refactoring | `refactor-safely` |

## Non-Negotiable Workflow Rule

**Tests gate implementation.** This applies to every skill that produces code:

```
Write test → Run test → Verify it FAILS for the right reason → Implement → Verify it PASSES
```

Do not write implementation code before the test exists and fails. Every skill that produces code contains a `HARD-GATE` section enforcing this. Honor it.

## Primary Workflow

The default daily workflow for a Rails feature:

```
rails-context-engineering → post Context Summary
  → rails-tdd-slices → write failing test
  → [CHECKPOINT: confirm test boundary and behavior]
  → [CHECKPOINT: confirm implementation approach]
  → implement (minimal code to pass test)
  → [GATE: linters + full test suite]
  → yard-documentation
  → rails-code-review
  → rails-review-response (when feedback is received)
  → PR
```

For a full feature from scratch: `rails-context-engineering` → `create-prd` → `generate-tasks` → TDD Feature Loop above.

See `docs/workflow-guide.md` for all workflow variants (bug fix, GraphQL, engine, migration, refactor, etc.).

## Workflow Chaining

Each skill's **Integration** table names the next skill to load. Follow it. Skills are building blocks; workflows are the unit of value.

## Output Language

All generated artifacts (YARD docs, Postman collections, task lists, PRDs, READMEs, examples) must be in **English** unless the user explicitly requests another language.

## Eval Strategy

Skills are scored on two axes: **skill-specific criteria** AND **model performance baseline-vs-with-context**. A skill that only beats baseline marginally is under-specified — it should change the model's output meaningfully. See `docs/skill-optimization-guide.md` for the optimization loop and per-skill targets.

## Key Constraints

- Do not generate tickets unless the user asks explicitly — `ticket-planning` is optional.
- Do not skip the verify-failure step in the TDD gate.
- Do not add repositories, aggregates, or domain events just because a task looks "DDD" — see `ddd-rails-modeling`.
- Do not use `rails-graphql-best-practices` for REST endpoints or `api-rest-collection` for GraphQL endpoints.
