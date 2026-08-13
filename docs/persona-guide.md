# Persona Guide

How to chain skills. Install notes are in the [README](../README.md). `SKILL.md` rules are in [architecture.md](architecture.md).

## How to invoke

State the goal and name the persona or skill:

```text
Add a status column to orders. Follow review-migration.
Follow the TDD persona for the user profile page.
Use triage-bug *(from core)* on this avatar bug.
```

Checkpoints in the TDD loop wait for you. Say “skip the proposal” if you already know the approach.

Stage write-ups: [docs/personas/](personas/).

## TDD feature loop

```mermaid
flowchart TD
    A[Task] --> B[load-context]
    B --> C[plan-tests]
    C --> D[write-tests]
    D --> E{Test feedback}
    E -->|Revise| D
    E -->|Approved| F{Implementation proposal}
    F -->|Revise| F
    F -->|Approved| G[Implement]
    G --> H[GREEN + refactor]
    H --> I{More behaviors?}
    I -->|Yes| D
    I -->|No| J[Linters + suite]
    J --> K[write-yard-docs]
    K --> L[code-review]
    L --> M[PR]
```

Details: [personas/development.md](personas/development.md).

## Other loops

```mermaid
flowchart LR
    A[Bug report] --> B[triage-bug]
    B --> C[failing reproduction spec]
    C --> D[minimal fix]
    D --> E[code-review]
```

```mermaid
flowchart LR
    A[PR ready] --> B[code-review]
    B --> C{Security?}
    C -->|Yes| D[security-check]
    C -->|No| E{Architecture?}
    E -->|Yes| F[review-architecture]
    E -->|No| G[Approve]
    D --> G
    F --> G
    G --> H[respond-to-review]
```

```mermaid
flowchart LR
    A[create-engine] --> B[test-engine]
    B --> C[document-engine]
    C --> D[review-engine]
    D --> E[release-engine]
```

```mermaid
flowchart LR
    A[GraphQL feature] --> B[define-domain-language]
    B --> C[implement-graphql]
    C --> D[TDD loop]
    D --> E[security-check]
```

```mermaid
flowchart LR
    A[Migration] --> B[review-migration]
    B --> C[test up and down]
    C --> D[implement]
    D --> E[code-review]
```

| Need | Guide |
|------|-------|
| Discovery | [personas/discovery.md](personas/discovery.md) |
| Setup | [personas/setup.md](personas/setup.md) |
| Development | [personas/development.md](personas/development.md) |
| Quality | [personas/quality.md](personas/quality.md) |
| Review | [personas/review.md](personas/review.md) |
| Engines | [personas/engines.md](personas/engines.md) |

## Tests gate

A test must exist, run, and fail because the feature is missing before any implementation. That rule is in [AGENTS.md](../AGENTS.md). Skills add only the extra gates that belong to that skill.
