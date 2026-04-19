# Workflow: Engine Development (60)

**When to use:** Create, extract, or maintain Rails engines.

---

## Main Flow: New Engine

```mermaid
graph TB
    subgraph Scaffold [🔧 Phase 1: Scaffold]
        direction TB
        A[rails-engine-author] --> B[rails-engine-testing]
        B --> C{Tests pass?}
        C -- No --> D[Fix setup]
        D --> B
    end

    subgraph Document [📝 Phase 2: Document]
        direction TB
        C -- Yes --> E[rails-engine-docs]
        E --> F[rails-engine-installers]
    end

    subgraph Review [🔍 Phase 3: Review]
        direction TB
        F --> G[rails-engine-reviewer]
        G --> H{Findings?}
        H -- Yes --> I[Fix issues]
        I --> G
    end

    subgraph Release [🚀 Phase 4: Release]
        direction TB
        H -- No --> J[rails-engine-release]
        J --> K[rails-engine-compatibility]
        K --> L((Release gem))
    end

    %% Minimalist styling
    style Scaffold fill:#f5f5f5,stroke:#333,stroke-dasharray: 5 5
    style Document fill:#e1f5fe,stroke:#01579b
    style Review fill:#f3e5f5,stroke:#4a148c
    style Release fill:#e8f5e9,stroke:#1b5e20
    style C fill:#ffd54f
    style H fill:#ffd54f
```

---

## Engine Skills Sequence

### 1. rails-engine-author

**Goal:** Initial scaffolding.

- Engine type (Plain, Railtie, Engine, Mountable)
- Namespace isolation
- Host-app contract
- File structure

### 2. rails-engine-testing

**Goal:** Testing framework.

- Dummy app setup
- Request specs
- Routing specs
- Generator specs

### 3. rails-engine-docs

**Goal:** Complete documentation.

- README: installation, mounting, configuration
- Usage examples
- Extension points

### 4. rails-engine-installers

**Goal:** Installation generators.

- Idempotent setup tasks
- Copy migrations
- Initializer generator
- Route mount setup

### 5. rails-engine-reviewer

**Goal:** Complete review.

- Namespace boundaries
- Host integration
- Safe initialization
- Test coverage

### 6. rails-engine-release

**Goal:** Versioned release.

- Changelog
- Migration guide
- Version bump
- Gem build & publish

### 7. rails-engine-compatibility

**Goal:** Cross-version stability.

- Zeitwerk autoloading
- CI matrix (Rails versions)
- Feature detection (no Rails.version branching)

---

## Alternative Flow: Extraction

```mermaid
flowchart LR
    A[Host app code] --> B[rails-engine-extraction]
    B --> C[refactor-safely]
    C --> D[Characterization tests]
    D --> E[rails-engine-author]
    E --> F[rails-engine-testing]
```

**Key rule:** Don't extract and change behavior in the same step.

---

## API Endpoints in Engines

If the engine exposes HTTP endpoints:

```
rails-engine-* → api-rest-collection
```

Generate or update Postman Collection for testing.

---

## Skills in this Workflow

| Skill | Description | Trigger words |
|-------|-------------|---------------|
| **rails-engine-author** | Scaffold engine | "create engine", "new engine", "extract to engine" |
| **rails-engine-testing** | Engine test setup | "test engine", "dummy app", "engine specs" |
| **rails-engine-docs** | Engine documentation | "engine README", "install guide", "engine docs" |
| **rails-engine-installers** | Install generators | "install generator", "engine setup", "copy migrations" |
| **rails-engine-reviewer** | Engine review | "review engine", "engine quality" |
| **rails-engine-release** | Engine release | "release engine", "version bump", "publish gem" |
| **rails-engine-compatibility** | Cross-version support | "Zeitwerk", "compatibility", "Rails upgrade" |
| **rails-engine-extraction** | Extract to engine | "extract feature", "move to engine", "host coupling" |
| **api-rest-collection** | API docs | "Postman", "API collection", "test endpoints" |
