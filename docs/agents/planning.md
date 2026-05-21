# Agent Stage: Planning & Design (10)

**When to use:** You are building a new feature and need to plan before coding.

---

## Main Flow: Standard Planning

```mermaid
graph TB
    subgraph Define [📝 Phase 1: Define]
        direction TB
        A[Feature idea] --> B[load-context]
        B --> C[create-prd]
        C --> D{PRD approved?}
        D -- No --> C
    end

    subgraph Plan [📋 Phase 2: Plan]
        direction TB
        D -- Yes --> E[generate-tasks]
        E --> F{Needs DDD?}
    end

    subgraph Design [🎯 Phase 3: Design - Optional]
        direction TB
        F -- Yes --> G[define-domain-language]
        G --> H[review-domain-boundaries]
        H --> I[model-domain]
    end

    subgraph Track [🎫 Phase 4: Track - Optional]
        direction TB
        F -- No --> J[plan-tickets]
        I --> J
    end

    J --> K((Start Development))

    %% Styling
    style Define fill:#f5f5f5,stroke:#333,stroke-dasharray: 5 5
    style Plan fill:#e1f5fe,stroke:#01579b
    style Design fill:#f3e5f5,stroke:#4a148c
    style Track fill:#e8f5e9,stroke:#1b5e20
    style D fill:#ffd54f
    style F fill:#ffd54f
    style K fill:#c8e6c9,stroke:#1b5e20,stroke-width:3px
```

---

## Step 1: create-prd

**Goal:** Define the feature before implementing.

**Output:** `/tasks/prd-[feature-name].md` with:
- Goals and non-goals
- User stories
- Functional requirements
- Success metrics
- Open questions

**Gate:** Do not implement until PRD is approved.

---

## Step 2: generate-tasks

**Goal:** Convert PRD into TDD-ready tasks.

**Output:** `/tasks/tasks-[feature-name].md` with:
- Task 0.0: Create feature branch
- TDD task groups (4 sub-tasks each)
- YARD documentation task
- README/docs update task
- Code review gate

**Rules:**
- Each sub-task: 2-5 minutes
- All file paths are exact
- No scope creep

---

## Step 3 (optional): DDD-First Design

When the problem is the **domain itself**: ambiguous language, confusing ownership, or uncertainty about where logic belongs.

### DDD Sequence

1. **define-domain-language**: Glossary, canonical terms, overloaded words
2. **review-domain-boundaries**: Bounded contexts, language leakage, ownership
3. **model-domain**: Model, value object, service, repository, event — or simpler alternative

**Key rules:**
- Start with language and invariants, not patterns
- Do not introduce repositories or domain events without real boundary pressure
- Prefer the smallest credible boundary improvement over DDD rewrite

---

## Step 4 (optional): plan-tickets

When the team uses an issue tracker (Jira, Linear, GitHub Issues).

**Goal:** Map planning output to board-ready tickets.

**Does not replace:** PRD/tasks artifacts. It is an additional mapping.

---

## Integration with Development

| Planning output | Next step |
|-----------------|-----------|
| Tasks ready | `plan-tests` → [development](development.md) |
| Need additional architecture | `review-architecture` → [review](review.md) |
| Need migration | `review-migration` → [development](development.md) |

---

## Skills in this Stage

| Skill | Description | Trigger words |
|-------|-------------|---------------|
| **create-prd** | Write requirements document | "plan feature", "create PRD", "requirements" |
| **generate-tasks** | Break PRD into TDD tasks | "break into tasks", "implementation plan", "task list" |
| **plan-tickets** | Create tracker tickets | "create tickets", "Jira", "Linear", "GitHub Issues" |
| **define-domain-language** | Domain language glossary | "domain terms", "ubiquitous language", "what should we call this" |
| **review-domain-boundaries** | Bounded context review | "context boundaries", "language leakage", "ownership" |
| **model-domain** | DDD → Rails mapping | "aggregate", "value object", "domain event", "repository" |

---

## Planning Flows

### Standard Feature
```
load-context → create-prd → generate-tasks → plan-tests
```

### Feature with DDD
```
load-context → create-prd → define-domain-language → review-domain-boundaries → model-domain → generate-tasks → plan-tests
```

### Planning with Tickets
```
create-prd → generate-tasks → plan-tickets → tracker
```

---

## Key Gates

```text
DO NOT implement until PRD is approved.
DO NOT generate tasks until PRD is stable.
DO NOT skip DDD phase when domain language is fuzzy.
```
