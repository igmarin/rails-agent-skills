# Workflow: Development (30)

**When to use:** Write code, implement features, fix bugs, or build APIs/services.

---

## Main Flow: TDD Feature Loop

```mermaid
graph TB
    subgraph Test [🧪 Phase 1: Test First]
        direction TB
        A[Feature / Task] --> B[rails-context-engineering]
        B --> C[rails-tdd-slices]
        C --> D[rspec-best-practices]
        D --> E{Test feedback OK?}
        E -- No --> D
    end

    subgraph Implement [💻 Phase 2: Implement]
        direction TB
        E -- Yes --> F{Proposal OK?}
        F -- No --> F
        F -- Yes --> G[Implement minimal]
        G --> H{Test passes?}
        H -- No --> G
    end

    subgraph Iterate [🔄 Phase 3: Iterate]
        direction TB
        H -- Yes --> I{More behaviors?}
        I -- Yes --> D
    end

    subgraph Finish [✅ Phase 4: Finish]
        direction TB
        I -- No --> J[Linters + Suite]
        J --> K[yard-documentation]
        K --> L[rails-code-review]
        L --> M((PR))
    end

    %% Styling
    style Test fill:#f5f5f5,stroke:#333,stroke-dasharray: 5 5
    style Implement fill:#e1f5fe,stroke:#01579b
    style Iterate fill:#fff3e0,stroke:#e65100
    style Finish fill:#e8f5e9,stroke:#1b5e20
    style E fill:#ffd54f
    style F fill:#ffd54f
    style H fill:#ffd54f
    style I fill:#ffd54f
    style M fill:#c8e6c9,stroke:#1b5e20,stroke-width:3px
```

---

## Step 1: rails-tdd-slices

**Goal:** Choose the correct first failing spec.

### Decision Table: Best First Spec

| Change | Start with |
|--------|------------|
| Pure domain logic | Model or PORO service spec |
| HTTP endpoint behavior | Request spec |
| Background processing | Job spec |
| Cross-layer journey | System spec (sparingly) |
| Bug fix | rails-bug-triage first |
| Engine feature | Engine spec with dummy app |

---

## Step 2: rspec-best-practices

**Goal:** Write the test and verify it fails.

### TDD Cycle

1. **RED:** Write failing test
2. **GREEN:** Minimal code to pass
3. **REFACTOR:** Clean up while green

### Checkpoints

- **Test Feedback Checkpoint:** Present test before implementing. Confirm: correct behavior? correct boundary? edge cases?
- **Implementation Proposal Checkpoint:** Propose approach in plain language before writing code. Confirm: which classes/methods? structure? risks?

---

## Specializations by Code Type

### Service Objects

```
rails-tdd-slices → rspec-service-testing → ruby-service-objects
```

- **Pattern:** `.call` with response contract `{ success: true/false, response: {} }`
- **Test:** `describe '.call'`, `subject(:result)`, test success and error paths

### API Integration

```
rails-tdd-slices → ruby-api-client-integration → rspec-best-practices
```

- **Layers:** Auth → Client → Fetcher → Builder → Domain Entity
- **Testing:** Stub external with `allow(Service).to receive(:method)`

### GraphQL

```
ddd-ubiquitous-language → rails-graphql-best-practices → rails-tdd-slices
```

- **Schema design:** Types, mutations, resolvers
- **N+1 prevention:** Dataloaders mandatory
- **Auth:** Field-level, disable introspection in prod

### Background Jobs

```
rails-background-jobs → rails-tdd-slices
```

- **Idempotency:** Jobs must be safe to re-run
- **Retry strategy:** Configure in job or queue adapter
- **Testing:** `have_enqueued_job`, `perform_enqueued_jobs`

### Migrations

```
rails-migration-safety → rails-tdd-slices → implement → verify up/down
```

- **Never combine:** Schema changes + data backfills
- **Always test:** `up`, `down`, data integrity
- **Large tables:** `algorithm: :concurrent` on indexes

### Authorization

```
rails-authorization-policies → rails-tdd-slices
```

- **Patterns:** Pundit vs CanCanCan
- **Testing:** Request specs with different roles

### Performance

```
rails-performance-optimization → rspec-best-practices → optimize
```

- **Regression spec:** Query count before optimizing
- **Tools:** Bullet, rack-mini-profiler, EXPLAIN ANALYZE

---

## Bug Fix Loop

```mermaid
graph TB
    subgraph Triage [🐛 Phase 1: Triage]
        direction TB
        A[Bug report] --> B[rails-bug-triage]
        B --> C{Reproducible?}
        C -- No --> B
    end

    subgraph Fix [🔧 Phase 2: Fix]
        direction TB
        C -- Yes --> D[rails-tdd-slices]
        D --> E[Write failing spec]
        E --> F{Spec fails for bug?}
        F -- No --> E
        F -- Yes --> G[Minimal fix]
        G --> H[Verify passes]
    end

    H --> I[rails-code-review]

    %% Styling
    style Triage fill:#ffebee,stroke:#c62828
    style Fix fill:#e1f5fe,stroke:#01579b
    style C fill:#ffd54f
    style F fill:#ffd54f
```

**Key rule:** Bug triage and bug fix are distinct phases. Triage produces a failing spec; fix follows TDD loop.

---

## External API Integration

```mermaid
graph TB
    subgraph Plan [📝 Phase 1: Plan]
        direction TB
        A[Need API integration] --> B[create-prd]
        B --> C[generate-tasks]
    end

    subgraph Build [💻 Phase 2: Build]
        direction TB
        C --> D[rails-tdd-slices]
        D --> E[ruby-api-client-integration]
    end

    subgraph Document [📚 Phase 3: Document]
        direction TB
        E --> F[yard-documentation]
        F --> G[rails-code-review]
    end

    %% Styling
    style Plan fill:#f5f5f5,stroke:#333,stroke-dasharray: 5 5
    style Build fill:#e1f5fe,stroke:#01579b
    style Document fill:#e8f5e9,stroke:#1b5e20
```

### Layered Architecture

| Layer | Responsibility | Test Strategy |
|-------|---------------|---------------|
| **Auth** | Tokens, refresh | Stub network |
| **Client** | HTTP, retries, timeout | Stub responses |
| **Fetcher** | Pagination, rate limiting | Mock client |
| **Builder** | JSON → Domain objects | Unit test |
| **Entity** | Domain model | Model spec |

---

## Skills in this Workflow

| Skill | Description | Trigger words |
|-------|-------------|---------------|
| **rails-tdd-slices** | Choose first failing spec | "where to start testing", "what test first", "TDD" |
| **rspec-best-practices** | TDD discipline, spec types | "write test", "RSpec", "test-driven" |
| **rspec-service-testing** | Service object tests | "test service", "spec/services" |
| **ruby-service-objects** | .call pattern, service design | "create service", "extract service", ".call" |
| **ruby-api-client-integration** | External API layers | "API integration", "HTTP client", "external API" |
| **rails-background-jobs** | Active Job, Solid Queue, Sidekiq | "background job", "Active Job", "async" |
| **rails-migration-safety** | Safe DB migrations | "migration", "add column", "index" |
| **rails-graphql-best-practices** | GraphQL schema design | "GraphQL", "resolver", "mutation" |
| **rails-bug-triage** | Bug reproduction | "bug", "debug", "fix", "broken" |
| **rails-authorization-policies** | Roles, permissions | "authorization", "Pundit", "CanCanCan", "roles" |
| **rails-performance-optimization** | Query optimization | "N+1", "slow", "performance", "optimize" |
| **strategy-factory-null-calculator** | Variant calculators | "calculator", "strategy pattern", "dispatch" |

---

## Gates

```text
GATE 1: Test must exist and FAIL before implementation
GATE 2: Linters + Full Suite must pass before docs
GATE 3: Code review findings addressed before merge
```
