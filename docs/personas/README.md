# Persona Guides — Rails Agent Skills

Step-by-step guides for each stage of Rails development. Each stage defines a chain of skills executed in order.

**Note:** This repository depends on `igmarin/ruby-core-skills` for foundational Ruby skills. Install both repositories for complete functionality. Skills marked with `*(from core)*` are provided by the core dependency.

---

## Master Stage Diagram

```mermaid
flowchart TD
    START([What do you need to do?]) --> DECISION{What stage are you at?}

    DECISION -->|New project or setup| DISCOVERY[discovery]
    DECISION -->|Configure CI/CD or environment| SETUP[setup]
    DECISION -->|Develop code| DEV[development]
    DECISION -->|Review quality| QUALITY[quality]
    DECISION -->|Code review| REVIEW[review]
    DECISION -->|Build engine| ENGINES[engines]

    DISCOVERY --> NEXT{What next?}
    SETUP --> DEV

    NEXT -->|Implement| DEV
    NEXT -->|Done| END([PR / Merge])

    DEV -->|Tests pass| YARD[write-yard-docs *(from core)*]
    DEV -->|Need review| REVIEW

    YARD --> REVIEW
    REVIEW -->|Feedback received| RESPOND[respond-to-review *(from core)*]
    RESPOND -->|Re-implement| DEV
    RESPOND -->|OK| END

    QUALITY --> REVIEW
    ENGINES --> REVIEW
```

---

## Persona Stages Index

| Stage | Guide | Description | Primary Skills |
|-------|-------|-------------|----------------|
| **Discovery** | [Discovery & Context](discovery.md) | Understand codebase, project onboarding | `load-context`, `setup-environment` |
| **Setup** | [Setup & Configuration](setup.md) | Configure CI/CD, environment, deploy | `setup-environment` *(plus roadmap `setup-ci-cd`)* |
| **Development** | [Development](development.md) | TDD development, implementation | `plan-tests`, `testing skills`, implementation |
| **Quality** | [Code Quality](quality.md) | Conventions, refactoring, documentation | Local: `apply-code-conventions`, `refactor-code`. Core: `write-yard-docs`, `refactor-process`, `review-process` |
| **Review** | [Review & Validation](review.md) | Code review, security, architecture | `code-review`, `security-check`, `review-architecture`, `respond-to-review` *(from core)* |
| **Engines** | [Engine Development](engines.md) | Create and maintain Rails engines | `engine skills` |

---

## Docs vs. Callable Persona Skills

This directory contains **reference guides** describing each stage. For **executable orchestration**, use the callable personas under `skills/` (`tdd`, `review`, `setup`, `quality`, `engine`, and the rest):

| Stage Doc | Callable Skill | Status |
|-----------|----------------|--------|
| [development.md](development.md) | [`tdd`](../../skills/tdd/SKILL.md) | Active |
| [review.md](review.md) | [`review`](../../skills/review/SKILL.md) | Active |
| [setup.md](setup.md) | [`setup`](../../skills/setup/SKILL.md) | Active |
| [quality.md](quality.md) | [`quality`](../../skills/quality/SKILL.md) | Active |
| [engines.md](engines.md) | [`engine`](../../skills/engine/SKILL.md) | Active |
| [discovery.md](discovery.md) | *(none — linear, no orchestration needed)* | Doc only |

**When to use which:** Read the stage doc to understand the full context and rationale. Invoke the callable persona when you want the agent to execute the orchestration automatically.

---

## Specialized Personas

| Situation | Persona | Quick Entry |
|-----------|---------|-------------|
| **Bug fix** | [`bug-fix`](../../skills/bug-fix/SKILL.md) | `triage-bug` *(from core)* → reproduce test → fix → verify |
| **Refactoring** | [Refactor Safely](quality.md#refactor-code) | `refactor-code` → characterization tests → extract |
| **Performance** | [Performance Optimization](development.md#performance) | `optimize-performance` |
| **GraphQL** | [`graphql`](../../skills/graphql/SKILL.md) | domain modeling *(from core)* → schema → TDD → security |
| **Authorization** | [Authorization Setup](development.md#authorization) | `implement-authorization` |
| **External API** | [API Integration](development.md#external-api-integration) | `integrate-api-client` *(from core)* |
| **Database migration** | [`migration`](../../skills/migration/SKILL.md) | plan → test → staging → production |
| **Background job** | [`background-job`](../../skills/background-job/SKILL.md) | design → TDD → retry config → monitoring |

---

## Quick Decision Tree

```
New to the project?
  ├─ Yes → load-context → setup-environment
  └─ No → What do you need to do?

       Implement?
            Bug or refactor?
            ├─ Bug → triage-bug *(from core)*
            ├─ Refactor → refactor-code
            └─ New feature → plan-tests → write-tests

                 Code type?
                 ├─ Service → create-service-object *(from core)*
                 ├─ REST API → integrate-api-client *(from core)*
                 ├─ GraphQL → implement-graphql
                 ├─ Migration → review-migration
                 ├─ Background job → implement-background-job
                 └─ Engine → create-engine

                      Authorization/roles?
                      └─ implement-authorization

                           Performance?
                           └─ optimize-performance
```

---

## Cross-Cutting: Tests Gate Implementation

All code-producing personas include this gate:

```text
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
```

See details in each specific persona.

---

## Reference & Troubleshooting

- [Persona Guide](../persona-guide.md) - Narrative workflows and variations
- [Skill Catalog](../reference/skill-catalog.md) - Comprehensive catalog of all 28 public Rails skills, 9 personas, and 15 core skills
- [Architecture](../architecture.md) - SKILL.md rules and repository design
- [Root README](../../README.md) - Installation commands and platform setup guide
