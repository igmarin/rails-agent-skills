# Skill Catalog — Rails Agent Skills

Complete catalog of 34+ skills organized by development lifecycle stage.

---

## Index by Stage

- [00 — Discovery & Context](#00--discovery--context)
- [10 — Planning & Design](#10--planning--design)
- [20 — Setup & Configuration](#20--setup--configuration)
- [30 — Development](#30--development)
- [40 — Code Quality](#40--code-quality)
- [50 — Review & Validation](#50--review--validation)
- [60 — Engines](#60--engines)

---

## 00 — Discovery & Context

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **rails-context-engineering** | Load minimum context before coding (schema, routes, neighbors) | "load context", "before I code", "match existing style", "what does this codebase use" |
| **rails-project-onboarding** *(NEW)* | Complete dev environment setup (Docker, env vars, db) | "onboarding", "new dev", "setup project", "Docker", "environment" |

---

## 10 — Planning & Design

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **create-prd** | Generate PRD with goals, user stories, requirements | "plan feature", "create PRD", "requirements", "feature spec" |
| **generate-tasks** | Convert PRD into TDD-ready tasks with exact paths | "break into tasks", "implementation plan", "task list", "generate tasks" |
| **ticket-planning** | Create tickets in issue tracker from plan | "create tickets", "Jira", "Linear", "GitHub Issues" |
| **ddd-ubiquitous-language** | Domain terms glossary | "domain terms", "ubiquitous language", "what should we call this", "naming" |
| **ddd-boundaries-review** | Review bounded contexts and language leakage | "context boundaries", "language leakage", "ownership", "cross-context" |
| **ddd-rails-modeling** | Map DDD to Rails (models, services, VO) | "aggregate", "value object", "domain event", "repository", "DDD" |

---

## 20 — Setup & Configuration

*No shipped skills in this stage yet. See [Roadmap](#proposed-new-skills-roadmap) for `rails-ci-cd-setup`.*

---

## 30 — Development

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **rails-tdd-slices** | Choose the best first failing spec | "where to start testing", "what test first", "TDD", "first failing spec" |
| **rspec-best-practices** | TDD discipline, spec types, factory design | "write test", "RSpec", "test-driven", "spec type" |
| **rspec-service-testing** | Service object specific testing | "test service", "spec/services", "service spec" |
| **ruby-service-objects** | `.call` pattern, response contract, YARD | "create service", "extract service", ".call", "service object" |
| **ruby-api-client-integration** | Layered architecture for external APIs | "API integration", "HTTP client", "external API", "third party" |
| **rails-background-jobs** | Active Job, Solid Queue, Sidekiq, idempotency | "background job", "Active Job", "async", "Sidekiq", "worker" |
| **rails-migration-safety** | Safe migrations for production | "migration", "add column", "index", "backfill", "zero-downtime" |
| **rails-graphql-best-practices** | Schema design, N+1 prevention, auth | "GraphQL", "resolver", "mutation", "dataloader" |
| **rails-bug-triage** | Bug diagnosis and reproduction | "bug", "debug", "fix", "broken", "error", "regression" |
| **rails-authorization-policies** *(NEW)* | Pundit/CanCanCan, roles, permissions | "authorization", "Pundit", "CanCanCan", "roles", "permissions", "policy" |
| **rails-performance-optimization** *(NEW)* | N+1s, profiling, caching, query optimization | "N+1", "slow", "performance", "optimize", "caching", "profiling" |
| **rails-api-versioning** *(NEW)* | REST API versioning | "API version", "v1", "v2", "versioning", "deprecation" |
| **rails-database-seeding** *(NEW)* | Fixtures vs Seeds for dev/test | "seeds", "fixtures", "test data", "development data" |
| **rails-frontend-hotwire** *(NEW)* | Turbo/Stimulus integration | "Hotwire", "Turbo", "Stimulus", "SPA", "frames", "streams" |
| **strategy-factory-null-calculator** | Variant-based calculators | "calculator", "strategy pattern", "factory", "dispatch", "variant" |

---

## 40 — Code Quality

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **refactor-safely** | Refactor preserving behavior | "refactor", "extract", "restructure", "clean up" |
| **rails-code-conventions** | DRY/YAGNI/PORO/CoC/KISS by path | "code review", "conventions", "clean code", "DRY", "YAGNI" |
| **yard-documentation** | Inline documentation with YARD | "YARD", "documentation", "@param", "@return", "inline docs" |
| **rails-stack-conventions** | Stack-specific conventions (PostgreSQL, Hotwire, Tailwind) | "stack", "PostgreSQL", "Hotwire", "Tailwind", "conventions" |

---

## 50 — Review & Validation

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **rails-code-review** | Systematic Rails PR review | "review PR", "code review", "check this code", "CR" |
| **rails-review-response** | Respond to review feedback | "feedback", "review comments", "address feedback", "respond" |
| **rails-security-review** | Deep security audit | "security", "audit", "vulnerability", "XSS", "SQL injection", "CSRF" |
| **rails-architecture-review** | Structural boundary review | "architecture", "structure", "boundaries", "fat model", "extract" |
| **api-rest-collection** | Generate Postman collections for APIs | "Postman", "API collection", "REST", "test endpoints" |

---

## 60 — Engines

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **rails-engine-author** | Rails engine scaffolding | "create engine", "new engine", "mountable engine" |
| **rails-engine-testing** | Engine testing setup | "test engine", "dummy app", "engine specs" |
| **rails-engine-docs** | Engine documentation | "engine README", "install guide", "engine docs" |
| **rails-engine-installers** | Install generators | "install generator", "engine setup", "copy migrations" |
| **rails-engine-reviewer** | Complete engine review | "review engine", "engine quality", "engine audit" |
| **rails-engine-release** | Versioned engine release | "release engine", "version bump", "publish gem", "changelog" |
| **rails-engine-compatibility** | Cross-version compatibility | "Zeitwerk", "compatibility", "Rails upgrade", "cross-version" |
| **rails-engine-extraction** | Extract code to engine | "extract to engine", "move feature", "host coupling" |

---

## Skills by Objective (Quick Lookup)

### If you need...

| You need... | Recommended Skill(s) |
|-------------|----------------------|
| **Understand codebase** | `rails-context-engineering` |
| **New project setup** | `rails-project-onboarding` |
| **Plan feature** | `create-prd` → `generate-tasks` |
| **Start coding** | `rails-tdd-slices` → `rspec-best-practices` |
| **Fix bug** | `rails-bug-triage` |
| **Refactor** | `refactor-safely` |
| **Create service** | `ruby-service-objects` |
| **Integrate external API** | `ruby-api-client-integration` |
| **Add auth/roles** | `rails-authorization-policies` |
| **Optimize performance** | `rails-performance-optimization` |
| **Create engine** | `rails-engine-author` |
| **Review code** | `rails-code-review` |
| **Respond to feedback** | `rails-review-response` |
| **Setup CI/CD** | *(roadmap — `rails-ci-cd-setup`)* |
| **Not sure** | `rails-skills-orchestrator` |

---

## Proposed New Skills (Roadmap)

| Skill | Priority | Status |
|-------|----------|--------|
| rails-ci-cd-setup | 🔴 Critical | Not yet implemented |

---

## See also

- [Integration Matrix](integration-matrix.md) — Which skill connects to which
- [Workflows Index](../workflows/) — Complete step-by-step flows
- [Orchestrator](../../rails-skills-orchestrator/) — Entry skill when you don't know which to use
