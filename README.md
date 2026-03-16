# My Best Practices Skills (Rails Edition)

A curated library of AI agent skills for **Ruby on Rails** development. These skills provide specialized knowledge, conventions, and workflow patterns that AI coding assistants use to deliver higher-quality code.

## Methodology

This skill library is built on three core principles that shape how every skill operates.

### 1. Tests Gate Implementation

The central methodology of this project. Tests are not a phase that happens "after" or "alongside" development — they are a **gate** that must be passed before any implementation code can be written.

```
PRD → Tasks → [GATE] → Implementation
                 │
                 ├── 1. Test EXISTS (written and saved)
                 ├── 2. Test has been RUN
                 └── 3. Test FAILS for the correct reason
                        (feature missing, not a typo)

        Only after all 3 conditions are met
        can implementation code be written.
```

This applies to every skill that produces code: service objects, background jobs, API integrations, engine components, refactoring, and bug fixes. Every implementation skill in this library includes a **HARD-GATE: Tests Gate Implementation** section enforcing this discipline.

Why this matters:
- A test that passes immediately proves nothing — you don't know if it tests the right thing
- A test you never saw fail could be testing existing behavior, not the new feature
- Implementation code written before the test is biased by what you built, not what's required

### 2. Structured Skill Design

Each skill follows a consistent structure inspired by [superpowers](https://github.com/obra/superpowers) best practices:

| Section | Purpose |
|---------|---------|
| **YAML Frontmatter** | Discovery triggers ("Use when...") — helps AI agents find the right skill |
| **Quick Reference** | Scannable table for fast lookup |
| **HARD-GATE** | Non-negotiable rules that cannot be skipped |
| **Common Mistakes** | "Mistake vs Reality" table that prevents rationalizations |
| **Red Flags** | Signals that the skill is being violated |
| **Integration** | Related skills and when to chain them |

HARD-GATEs use explicit blocking language ("DO NOT", "CANNOT", "ONLY THEN") because AI agents are susceptible to rationalization — vague guidelines get optimized away under pressure.

### 3. Workflow Chaining

Skills are designed to be used in sequence, not in isolation. Each skill's **Integration** table points to the next skill in the chain. The typical flow is:

```
Planning (create-prd, generate-tasks)
    ↓
Testing (rspec-best-practices — write and validate tests)
    ↓
Implementation (ruby-service-objects, rails-*, etc.)
    ↓
Review (rails-code-review, rails-security-review)
```

See [docs/workflow-guide.md](docs/workflow-guide.md) for detailed workflow diagrams.

## Platforms

Works with **Cursor**, **Codex**, and **Claude Code**.

| Platform | Installation |
|----------|-------------|
| **Cursor** | Symlink or clone to `~/.cursor/skills/` |
| **Codex** | See [`.codex/INSTALL.md`](.codex/INSTALL.md) |
| **Claude Code** | Install as plugin via `.claude-plugin/` |

See [docs/implementation-guide.md](docs/implementation-guide.md) for detailed setup instructions.

## Quick Start

### Cursor

```bash
# Option A: Symlink (if you already have the repo cloned)
ln -s /path/to/my-cursor-skills ~/.cursor/skills-cursor/my-cursor-skills

# Option B: Clone directly
git clone <your-repo-url> ~/.cursor/skills-cursor/my-cursor-skills
```

### Codex

```bash
git clone <your-repo-url> ~/.codex/my-cursor-skills
mkdir -p ~/.agents/skills
ln -s ~/.codex/my-cursor-skills ~/.agents/skills/my-cursor-skills
```

### Claude Code

```bash
# From the Claude Code interface, add as a plugin:
/add-plugin /path/to/my-cursor-skills
```

## Skills Catalog

### Planning & Tasks

| Skill | Description |
|-------|-------------|
| [create-prd](create-prd/) | Generate Product Requirements Documents from feature descriptions |
| [generate-tasks](generate-tasks/) | Break down PRDs into step-by-step implementation task lists |

### Rails Code Quality

| Skill | Description |
|-------|-------------|
| [rails-code-review](rails-code-review/) | Review Rails code following The Rails Way conventions |
| [rails-architecture-review](rails-architecture-review/) | Review application structure, boundaries, and responsibilities |
| [rails-security-review](rails-security-review/) | Audit for auth, XSS, CSRF, SQLi, and other vulnerabilities |
| [rails-migration-safety](rails-migration-safety/) | Plan production-safe database migrations |
| [rails-stack-conventions](rails-stack-conventions/) | Apply Rails + PostgreSQL + Hotwire + Tailwind conventions |
| [rails-background-jobs](rails-background-jobs/) | Design idempotent background jobs with Active Job / Solid Queue |

### Ruby Patterns

| Skill | Description |
|-------|-------------|
| [ruby-service-objects](ruby-service-objects/) | Build service objects with .call, standardized responses, transactions |
| [ruby-api-client-integration](ruby-api-client-integration/) | Integrate external APIs with the layered Auth/Client/Fetcher/Builder pattern |
| [strategy-factory-null-calculator](strategy-factory-null-calculator/) | Implement variant-based calculators with Strategy + Factory + Null Object |

### Testing

| Skill | Description |
|-------|-------------|
| [rspec-best-practices](rspec-best-practices/) | Write maintainable, deterministic RSpec tests with TDD discipline |
| [rspec-service-testing](rspec-service-testing/) | Test service objects with instance_double, hash factories, shared_examples |

### Rails Engines

| Skill | Description |
|-------|-------------|
| [rails-engine-author](rails-engine-author/) | Design and scaffold Rails engines with proper namespace isolation |
| [rails-engine-testing](rails-engine-testing/) | Set up dummy apps and engine-specific specs |
| [rails-engine-reviewer](rails-engine-reviewer/) | Review engine architecture, coupling, and maintainability |
| [rails-engine-release](rails-engine-release/) | Prepare versioned releases with changelogs and upgrade notes |
| [rails-engine-docs](rails-engine-docs/) | Write comprehensive engine documentation |
| [rails-engine-installers](rails-engine-installers/) | Create idempotent install generators |
| [rails-engine-extraction](rails-engine-extraction/) | Extract host app code into engines incrementally |
| [rails-engine-compatibility](rails-engine-compatibility/) | Maintain cross-version compatibility |

### Refactoring

| Skill | Description |
|-------|-------------|
| [refactor-safely](refactor-safely/) | Restructure code with characterization tests and safe extraction |

### Meta

| Skill | Description |
|-------|-------------|
| [using-my-skills](using-my-skills/) | Discover and invoke the right skill for the current task |

## Skill Relationships

```mermaid
flowchart TD
    createPRD[create-prd] --> generateTasks[generate-tasks]
    generateTasks --> testGate["GATE: Write tests, run, verify failure"]
    testGate --> stackConventions[rails-stack-conventions]
    stackConventions --> codeReview[rails-code-review]

    codeReview --> archReview[rails-architecture-review]
    codeReview --> secReview[rails-security-review]
    codeReview --> migrationSafety[rails-migration-safety]

    archReview --> refactorSafely[refactor-safely]
    refactorSafely --> serviceObjects[ruby-service-objects]

    serviceObjects --> apiClient[ruby-api-client-integration]
    serviceObjects --> strategyFactory[strategy-factory-null-calculator]

    rspecBest[rspec-best-practices] --> testGate
    rspecService[rspec-service-testing] --> testGate

    engineAuthor[rails-engine-author] --> engineTestGate["GATE: Write engine specs, verify failure"]
    engineTestGate --> engineTesting[rails-engine-testing]
    engineAuthor --> engineDocs[rails-engine-docs]
    engineAuthor --> engineInstallers[rails-engine-installers]
    engineTesting --> engineReviewer[rails-engine-reviewer]
    engineReviewer --> engineRelease[rails-engine-release]
    engineRelease --> engineCompat[rails-engine-compatibility]
    engineExtraction[rails-engine-extraction] --> engineAuthor
```

## How Skills Work

Each skill is a `SKILL.md` file in its own directory. Skills follow a consistent structure:

1. **YAML Frontmatter** — `name` and `description` (triggers for skill discovery)
2. **Quick Reference** — Scannable table at the top
3. **Core Rules / Process** — The main instructions
4. **HARD-GATE** — Non-negotiable blockers (where applicable)
5. **Common Mistakes** — "Mistake vs Reality" table
6. **Red Flags** — Signals something is going wrong
7. **Integration** — Related skills and when to chain them

See [docs/architecture.md](docs/architecture.md) for the full conventions spec.

## Typical Workflows

Tests are a **gate** between planning and implementation. See [docs/workflow-guide.md](docs/workflow-guide.md).

| Workflow | Skill Chain |
|----------|-------------|
| **New feature** | create-prd -> generate-tasks -> **[write tests, verify failure]** -> implement -> rails-code-review |
| **Code review** | rails-code-review + rails-security-review + rails-architecture-review |
| **New engine** | rails-engine-author -> **[write specs, verify failure]** -> implement -> rails-engine-docs |
| **Refactoring** | refactor-safely -> **[characterization tests]** -> refactor -> verify tests pass |
| **New service** | **[write .call spec, verify failure]** -> ruby-service-objects -> verify passes |
| **API integration** | **[write layer specs, verify failure]** -> ruby-api-client-integration -> verify passes |
| **Bug fix** | **[write test reproducing bug, verify failure]** -> fix -> verify passes |

## Creating New Skills

See [docs/skill-template.md](docs/skill-template.md) for the template and conventions.
