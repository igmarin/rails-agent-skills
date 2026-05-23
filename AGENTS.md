# Rails Agent Skills — Agent Guidance

This file tells AI agents how to use this repository effectively.

## What This Repository Is

A curated library of 41 public atomic skills for Ruby on Rails development, plus 9 callable agents. Each skill encodes specialized workflow knowledge, conventions, and hard gates for a specific Rails domain. Skills are not documentation — they are executable instructions that guide agents through structured workflows.

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

Load the skill that best matches the current task. The bootstrap skill `skill-router` routes to specialized skills. All skills are organized by category in `skills/<category>/`:

| Category | Path | Skills |
|----------|------|--------|
| **Testing** | `skills/testing/` | `write-tests`, `test-service`, `plan-tests`, `triage-bug` |
| **Code Quality** | `skills/code-quality/` | `code-review`, `respond-to-review`, `review-architecture`, `security-check`, `apply-stack-conventions`, `apply-code-conventions`, `implement-authorization`, `refactor-code` |
| **DDD** | `skills/ddd/` | `define-domain-language`, `review-domain-boundaries`, `model-domain` |
| **Engines** | `skills/engines/` | `create-engine`, `test-engine`, `review-engine`, `release-engine`, `document-engine`, `create-engine-installer`, `extract-engine`, `upgrade-engine` |
| **Infrastructure** | `skills/infrastructure/` | `review-migration`, `implement-background-job`, `seed-database`, `optimize-performance`, `version-api`, `implement-hotwire` |
| **API** | `skills/api/` | `generate-api-collection`, `implement-graphql`, `integrate-api-client` |
| **Patterns** | `skills/patterns/` | `create-service-object`, `implement-calculator-pattern`, `write-yard-docs` |
| **Context** | `skills/context/` | `load-context`, `setup-environment` |
| **Orchestration** | `skills/orchestration/` | `skill-router` |
| **Agents** | `agents/` | `tdd`, `review`, `setup`, `quality`, `engine`, `bug-fix`, `graphql`, `migration`, `background-job` |

## Non-Negotiable Workflow Rule

**Tests gate implementation.** This applies to every skill that produces code:

```
Write test → Run test → Verify it FAILS for the right reason → Implement → Verify it PASSES
```

Do not write implementation code before the test exists and fails. Every skill that produces code contains a `HARD-GATE` section enforcing this. Honor it.

## Primary Agents

### Quick Reference

| Goal | Agent | Atomic Skills |
|------|-------|---------------|
| Implement feature with TDD | `agents/tdd` | Full orchestrated cycle |
| Review PR systematically | `agents/review` | Review → deep dive → response |
| Set up project / CI/CD | `agents/setup` | Context → onboarding → CI/CD |
| Quality check before PR | `agents/quality` | Conventions → refactor → docs |
| Build Rails engine | `agents/engine` | Author → test → review → release |
| Fix reported bug | `agents/bug-fix` | Triage → reproduce → fix → verify |
| Build GraphQL API | `agents/graphql` | Domain modeling → schema → TDD → security |
| Database migration | `agents/migration` | Plan → test → staging → production |
| Background job | `agents/background-job` | Design → TDD → retry config → monitoring |

### TDD Feature Loop (Recommended)

The default daily workflow — orchestrated by `tdd`:

```
skills/context/load-context
  → agents/tdd (orchestrates below)
    → skills/testing/plan-tests
    → skills/testing/write-tests
    → [GATE: test feedback OK]
    → implement
    → [GATE: linters + suite]
    → skills/patterns/write-yard-docs
    → skills/code-quality/code-review
    → PR
```

For a full feature from scratch: `skills/context/load-context` → `agents/tdd`.

See `docs/agent-guide.md` for all workflow variants (bug fix, GraphQL, engine, migration, refactor, etc.).

## Workflow Chaining

Each skill's **Integration** table names the next skill to load. Follow it. Skills are building blocks; agents are the unit of value.

## Output Language

All generated artifacts (YARD docs, Postman collections, task lists, PRDs, READMEs, examples) must be in **English** unless the user explicitly requests another language.

## Eval Strategy

Skills are scored on two axes: **skill-specific criteria** AND **model performance baseline-vs-with-context**. A skill that only beats baseline marginally is under-specified — it should change the model's output meaningfully. See `docs/skill-optimization-guide.md` for the optimization loop and per-skill targets.

## Key Constraints

- **The `evals/` directory is READ-ONLY.** These files contain intentional bugs, missing documentation, or non-standard patterns used to evaluate agent performance. Never "fix" or "improve" files in `evals/` unless explicitly instructed to update a test case scenario.
- Do not skip the verify-failure step in the TDD gate.
- Do not add repositories, aggregates, or domain events just because a task looks "DDD" — see `model-domain`.
- Do not use `implement-graphql` for REST endpoints or `generate-api-collection` for GraphQL endpoints.

<!-- lean-ctx -->
## lean-ctx

Prefer lean-ctx tools over native equivalents for token savings.
Full rules: @LEAN-CTX.md
<!-- /lean-ctx -->
