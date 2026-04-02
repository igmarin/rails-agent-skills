# Rails Agent Skills

**Rails Agent Skills** is a curated library of AI agent skills for **Ruby on Rails** development. Skills encode specialized knowledge, conventions, and workflow patterns so assistants deliver higher-quality code.

- **Repository / install path:** `rails-agent-skills` (see [Quick Start](#quick-start) and [docs/implementation-guide.md](docs/implementation-guide.md))
- **Bootstrap discovery skill:** [`rails-agent-skills`](rails-agent-skills/) (session hook loads `rails-agent-skills/SKILL.md` where applicable)
- **Workflows:** [docs/workflow-guide.md](docs/workflow-guide.md) — **Skill structure:** [docs/architecture.md](docs/architecture.md)
- **How to invoke a skill or workflow:** [docs/workflow-guide.md#how-to-invoke](docs/workflow-guide.md#how-to-invoke-a-skill-or-workflow-claude-code)

## Methodology

This skill library is built on three core principles that shape how every skill operates.

### 1. Tests Gate Implementation

The central methodology of this project. Tests are not a phase that happens "after" or "alongside" development — they are a **gate** that must be passed before any implementation code can be written.

```text
PRD → Tasks → [GATE] → Implementation → YARD → Docs → Code review → PR
                 │
                 ├── 1. Test EXISTS (written and saved)
                 ├── 2. Test has been RUN
                 └── 3. Test FAILS for the correct reason
                        (feature missing, not a typo)

        Only after all 3 conditions are met
        can implementation code be written.

After tests pass: document public Ruby API (YARD), update README/diagrams/
related docs, then self-review (rails-code-review) before opening the PR.
Task lists from generate-tasks include these steps explicitly.
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

**Generated output:** All generated artifacts (documentation, YARD comments, Postman collections, examples) must be in **English** unless the user explicitly requests another language. This is reflected in the skill template and in `yard-documentation` and `api-postman-collection`.

### 3. Workflow Chaining

Skills are designed to be used in sequence, not in isolation. Each skill's **Integration** table points to the next skill in the chain. The primary daily workflow is:

```text
rails-tdd-slices → rspec-best-practices (write failing test)
    ↓
[CHECKPOINT: Test Design Review — confirm boundary, behavior, edge cases]
    ↓
[CHECKPOINT: Implementation Proposal — confirm approach before coding]
    ↓
Implement (minimal code to pass test) → Refactor
    ↓
[GATE: Linters + Full Test Suite]
    ↓
yard-documentation → Update docs
    ↓
rails-code-review (self-review) → rails-review-response (on feedback)
    ↓
PR
```

See [docs/workflow-guide.md](docs/workflow-guide.md) for the full TDD Feature Loop and all workflow diagrams.

**Note:** `jira-ticket-planning` is an **optional** step. The assistant should **not** push for Jira ticket generation unless the user asks explicitly (e.g. "turn this into Jira tickets") or the context clearly indicates work should be mapped to a Jira board/sprint.

### 4. Rails-First Pattern Reuse

This library intentionally reuses proven patterns from broader agent-skill libraries, but translates them into a **Rails-first** workflow instead of copying generic frontend-oriented skills one-to-one.

| Reused pattern | Rails-first destination in this repo |
|----------------|--------------------------------------|
| PRD interview + scope control | `create-prd` |
| Planning from requirements | `generate-tasks` |
| TDD loop and smallest safe slice | `rspec-best-practices` + `rails-tdd-slices` |
| Bug investigation to reproducible test | `rails-bug-triage` |
| Domain language and context design | `ddd-ubiquitous-language` + `ddd-boundaries-review` + `ddd-rails-modeling` |
| Skill authoring conventions | `docs/skill-template.md` |

The rule of thumb is: **reuse patterns, not names**. If a broader skill maps cleanly to Rails/RSpec/YARD workflows, absorb the pattern into the existing chain. Create a new skill only when there is a real Rails-specific workflow gap.

## Platforms

Works with **Gemini CLI**, **Claude Code**, **Cursor**, **Windsurf**, **Codex**, and **VS Code** (with AI extensions).

| Platform | Setup | Docs |
|----------|-------|------|
| **Gemini CLI** | Global config symlink | [Setup Guide](docs/implementation-guide.md) |
| **Claude Code** | Shell function with `--plugin-dir` in `~/.zshrc` / `~/.bashrc` | [Setup Guide](docs/implementation-guide.md) |
| **Cursor** | Symlink to `~/.cursor/skills/` | [Setup Guide](docs/implementation-guide.md) |
| **Windsurf** | Symlink to `~/.windsurf/skills/` | [Setup Guide](docs/implementation-guide.md) |
| **Codex** | Clone or symlink | [`.codex/INSTALL.md`](.codex/INSTALL.md) |
| **VS Code** | Install AI extension (Cline, Continue, Aider) | [VS Code Setup](docs/vs-code-setup.md) |

For detailed platform-specific setup, see [docs/implementation-guide.md](docs/implementation-guide.md) and [docs/vs-code-setup.md](docs/vs-code-setup.md).

## Quick Start

### Gemini CLI

```bash
# 1. Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# 2. Symlink GEMINI.md to the Gemini CLI global config directory
ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
```

### Cursor

```bash
# Option A: Symlink (if you already have the repo cloned)
ln -s /path/to/rails-agent-skills ~/.cursor/skills-cursor/rails-agent-skills

# Option B: Clone directly
git clone git@github.com:igmarin/rails-agent-skills.git ~/.cursor/skills-cursor/rails-agent-skills
```

### Codex

```bash
# Option A: Clone directly into Codex skills
git clone git@github.com:igmarin/rails-agent-skills.git ~/.codex/skills/rails-agent-skills

# Option B: Symlink (if you already have the repo cloned)
ln -s /path/to/rails-agent-skills ~/.codex/skills/rails-agent-skills
```

### Claude Code

```bash
# 1. Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# 2. Add a shell function to your ~/.zshrc (or ~/.bashrc)
echo '
claude() {
  command claude --plugin-dir ~/skills/rails-agent-skills "$@"
}' >> ~/.zshrc

# 3. Reload your shell
source ~/.zshrc
```

Skills are now available automatically in every project, including `claude resume <id>` and any other subcommand.

**Updating:** `git pull` inside `~/skills/rails-agent-skills` — no restart needed, the function always loads the latest version.

**New machine:** repeat the three steps above.

## Skills Catalog

### Planning & Tasks

| Skill | Description |
|-------|-------------|
| [create-prd](create-prd/) | Generate Product Requirements Documents from feature descriptions |
| [generate-tasks](generate-tasks/) | Break down PRDs into step-by-step implementation task lists |
| [jira-ticket-planning](jira-ticket-planning/) | Draft or create Jira tickets from plans; sprint placement and classification |

### Rails Code Quality

| Skill | Description |
|-------|-------------|
| [rails-code-review](rails-code-review/) | Review Rails code following The Rails Way conventions — giving a review |
| [rails-review-response](rails-review-response/) | Respond to review feedback — evaluate, push back, implement safely, trigger re-review |
| [rails-architecture-review](rails-architecture-review/) | Review application structure, boundaries, and responsibilities |
| [rails-security-review](rails-security-review/) | Audit for auth, XSS, CSRF, SQLi, and other vulnerabilities |
| [rails-migration-safety](rails-migration-safety/) | Plan production-safe database migrations |
| [rails-stack-conventions](rails-stack-conventions/) | Apply Rails + PostgreSQL + Hotwire + Tailwind conventions |
| [rails-code-conventions](rails-code-conventions/) | Daily coding checklist: DRY/YAGNI/PORO/CoC/KISS; linter as style SoT; structured logging; per-path rules |
| [rails-background-jobs](rails-background-jobs/) | Design idempotent background jobs with Active Job / Solid Queue |
| [rails-graphql-best-practices](rails-graphql-best-practices/) | GraphQL schema design, N+1 prevention, authorization, error handling, and testing with graphql-ruby |
| [api-postman-collection](api-postman-collection/) | Generate or update Postman Collection (JSON v2.1) for REST endpoints; use Insomnia for GraphQL |

### DDD & Domain Modeling

| Skill | Description |
|-------|-------------|
| [ddd-ubiquitous-language](ddd-ubiquitous-language/) | Build a shared domain glossary, resolve synonyms, and clarify business terminology |
| [ddd-boundaries-review](ddd-boundaries-review/) | Review bounded contexts, ownership, and language leakage in Rails codebases |
| [ddd-rails-modeling](ddd-rails-modeling/) | Map DDD concepts to Rails models, services, value objects, and boundaries without over-engineering |

### Ruby Patterns

| Skill | Description |
|-------|-------------|
| [ruby-service-objects](ruby-service-objects/) | Build service objects with .call, standardized responses, transactions |
| [ruby-api-client-integration](ruby-api-client-integration/) | Integrate external APIs with the layered Auth/Client/Fetcher/Builder pattern |
| [strategy-factory-null-calculator](strategy-factory-null-calculator/) | Implement variant-based calculators with Strategy + Factory + Null Object |
| [yard-documentation](yard-documentation/) | Write YARD docs for Ruby classes and public methods (all output in English) |

### Testing

| Skill | Description |
|-------|-------------|
| [rspec-best-practices](rspec-best-practices/) | Write maintainable, deterministic RSpec tests with TDD discipline |
| [rails-tdd-slices](rails-tdd-slices/) | Pick the best first failing spec for a Rails change before implementation |
| [rails-bug-triage](rails-bug-triage/) | Turn a Rails bug report into a reproducible failing spec and fix plan |
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
| [rails-agent-skills](rails-agent-skills/) | Discover and invoke the right skill for the current Rails task |
| [docs/skill-template.md](docs/skill-template.md) | Authoring template and checklist for expanding the library |

## Skill Relationships

```mermaid
flowchart TD
    createPRD[create-prd] --> generateTasks[generate-tasks]
    createPRD --> dddLanguage[ddd-ubiquitous-language]
    dddLanguage --> dddBoundaries[ddd-boundaries-review]
    dddBoundaries --> dddModeling[ddd-rails-modeling]
    dddBoundaries --> archReview
    dddModeling --> generateTasks
    dddModeling --> railsConventions

    generateTasks --> jiraPlanning[jira-ticket-planning]
    generateTasks --> tddSlices[rails-tdd-slices]

    tddSlices --> rspecBest[rspec-best-practices]
    rspecBest --> testFeedback["CHECKPOINT: Test Feedback"]
    testFeedback --> implProposal["CHECKPOINT: Implementation Proposal"]
    implProposal --> implement["Implement"]
    implement --> lintersGate["GATE: Linters + Full Suite"]

    lintersGate --> railsConventions[rails-code-conventions]
    railsConventions --> stackConventions[rails-stack-conventions]
    lintersGate --> yardDoc[yard-documentation]
    yardDoc --> docUpdates[README diagrams docs]
    docUpdates --> codeReview[rails-code-review]

    codeReview --> reviewResponse[rails-review-response]
    reviewResponse --> codeReview

    codeReview --> archReview[rails-architecture-review]
    codeReview --> secReview[rails-security-review]
    codeReview --> migrationSafety[rails-migration-safety]

    archReview --> refactorSafely[refactor-safely]
    refactorSafely --> serviceObjects[ruby-service-objects]

    serviceObjects --> apiClient[ruby-api-client-integration]
    serviceObjects --> strategyFactory[strategy-factory-null-calculator]
    serviceObjects --> yardDoc
    apiClient --> yardDoc

    graphql[rails-graphql-best-practices] --> tddSlices
    graphql --> secReview
    graphql --> yardDoc

    engineAuthor --> postman[api-postman-collection]
    engineDocs[rails-engine-docs] --> postman

    bugTriage[rails-bug-triage] --> tddSlices
    rspecService[rspec-service-testing] --> rspecBest

    engineAuthor[rails-engine-author] --> engineTestGate["GATE: Write engine specs, verify failure"]
    engineTestGate --> engineTesting[rails-engine-testing]
    engineAuthor --> engineDocs
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

Tests are a **gate** between planning and implementation. See [docs/workflow-guide.md](docs/workflow-guide.md) for full diagrams.

| Workflow | Skill Chain |
|----------|-------------|
| **TDD Feature Loop** *(primary daily workflow)* | rails-tdd-slices → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → yard-documentation → rails-code-review → rails-review-response (on feedback) → PR |
| **New feature** | create-prd → generate-tasks → (optional **jira-ticket-planning**) → *TDD Feature Loop* |
| **DDD-first feature** | create-prd → ddd-ubiquitous-language → ddd-boundaries-review → ddd-rails-modeling → generate-tasks → *TDD Feature Loop* |
| **Bug fix** | rails-bug-triage → rails-tdd-slices → **[write reproduction spec, verify failure]** → fix → verify passes → rails-code-review |
| **Code review + response** | rails-code-review → rails-review-response (on feedback) → re-review if Critical items addressed |
| **Security audit** | rails-security-review → rails-code-review (verify fixes) → PR |
| **Performance optimization** | rails-code-conventions (ActiveRecord rules) → **[regression spec]** → optimize → rails-code-review |
| **Migration** | rails-migration-safety → **[test up + down]** → implement → rails-code-review |
| **GraphQL feature** | ddd-ubiquitous-language → rails-graphql-best-practices → *TDD Feature Loop* → rails-security-review |
| **New engine** | rails-engine-author → **[write specs, verify failure]** → implement → rails-engine-docs |
| **Refactoring** | refactor-safely → **[characterization tests]** → refactor → verify tests pass |
| **New service** | rails-tdd-slices → **[write .call spec, verify failure]** → ruby-service-objects → verify passes |
| **API integration** | rails-tdd-slices → **[write layer specs, verify failure]** → ruby-api-client-integration → verify passes |

## Creating New Skills

See [docs/skill-template.md](docs/skill-template.md) for the template and conventions.

Prefer extending an existing skill when the new behavior is just a tighter Rails adaptation of a pattern the library already covers. Create a new skill when the workflow has:

- a distinct trigger
- a different decision tree
- a different HARD-GATE or verification loop
- clear integration points that would otherwise bloat an existing skill

## Acknowledgments

Huge thanks to **[Mumo Carlos (@mumoc)](https://github.com/mumoc)**. His mentorship has shaped my growth as a developer and influenced many of the habits and practices reflected in this library — not only the **jira-ticket-planning** workflow he shared, but the broader discipline around quality, clarity, and thoughtful use of tools. This repo and the learning behind it would not be what they are without him.
