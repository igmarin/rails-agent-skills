# Skill Catalog — Rails Agent Skills

Complete catalog of 28 public skills and 9 callable agents organized by development lifecycle stage and by category.

---

## Quick Navigation

**By Stage:** [00 — Discovery](#00--discovery--context) · [30 — Development](#30--development) · [40 — Quality](#40--code-quality) · [50 — Review](#50--review--validation) · [60 — Engines](#60--engines)

**By Category:** [API](#api) · [Context](#context) · [Code Quality](#code-quality) · [DDD](#ddd) · [Engines](#engines) · [Infrastructure](#infrastructure) · [Orchestration](#orchestration) · [Patterns](#patterns) · [Testing](#testing) · [Agents](#agents)

*Note: DDD, Orchestration, and Patterns skills have moved to `igmarin/ruby-core-skills`. Install the core dependency to access them.*

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
| **load-context** | Load minimum context before coding (schema, routes, neighbors) | "load context", "before I code", "match existing style", "what does this codebase use" |
| **setup-environment** *(NEW)* | Complete dev environment setup (Docker, env vars, db) | "onboarding", "new dev", "setup project", "Docker", "environment" |

---

---

## 10 — Planning & Design

*Skills in this stage have moved to `igmarin/ruby-core-skills` (DDD skills). Install the core dependency to access:*
*- `define-domain-language` — Domain terms glossary*
*- `review-domain-boundaries` — Review bounded contexts and language leakage*
*- `model-domain` — Map DDD to Rails (models, services, VO)*

---

## 20 — Setup & Configuration

*No shipped skills in this stage yet. See [Roadmap](#proposed-new-skills-roadmap) for `setup-ci-cd`.*

---

## 30 — Development

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **plan-tests** | Choose the best first failing spec | "where to start testing", "what test first", "TDD", "first failing spec" |
| **write-tests** | TDD discipline, spec types, factory design | "write test", "RSpec", "test-driven", "spec type" |
| **test-service** | Service object specific testing | "test service", "spec/services", "service spec" |
| **implement-background-job** | Active Job, Solid Queue, Sidekiq, idempotency | "background job", "Active Job", "async", "Sidekiq", "worker" |
| **review-migration** | Safe migrations for production | "migration", "add column", "index", "backfill", "zero-downtime" |
| **implement-graphql** | Schema design, N+1 prevention, auth | "GraphQL", "resolver", "mutation", "dataloader" |
| **implement-authorization** *(NEW)* | Pundit/CanCanCan, roles, permissions | "authorization", "Pundit", "CanCanCan", "roles", "permissions", "policy" |
| **optimize-performance** *(NEW)* | N+1s, profiling, caching, query optimization | "N+1", "slow", "performance", "optimize", "caching", "profiling" |
| **version-api** *(NEW)* | REST API versioning | "API version", "v1", "v2", "versioning", "deprecation" |
| **seed-database** *(NEW)* | Fixtures vs Seeds for dev/test | "seeds", "fixtures", "test data", "development data" |
| **implement-hotwire** *(NEW)* | Turbo/Stimulus integration | "Hotwire", "Turbo", "Stimulus", "SPA", "frames", "streams" |

---

## 40 — Code Quality

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **refactor-code** | Refactor preserving behavior | "refactor", "extract", "restructure", "clean up" |
| **apply-code-conventions** | DRY/YAGNI/PORO/CoC/KISS by path | "code review", "conventions", "clean code", "DRY", "YAGNI" |
| **apply-stack-conventions** | Stack-specific conventions (PostgreSQL, Hotwire, Tailwind) | "stack", "PostgreSQL", "Hotwire", "Tailwind", "conventions" |

---

## 50 — Review & Validation

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **code-review** | Systematic Rails PR review | "review PR", "code review", "check this code", "CR" |
| **security-check** | Deep security audit | "security", "audit", "vulnerability", "XSS", "SQL injection", "CSRF" |
| **review-architecture** | Structural boundary review | "architecture", "structure", "boundaries", "fat model", "extract" |
| **generate-api-collection** | Generate Postman collections for APIs | "Postman", "API collection", "REST", "test endpoints" |

---

## 60 — Engines

| Skill | Description | Trigger Words |
|-------|-------------|---------------|
| **create-engine** | Rails engine scaffolding | "create engine", "new engine", "mountable engine" |
| **test-engine** | Engine testing setup | "test engine", "dummy app", "engine specs" |
| **document-engine** | Engine documentation | "engine README", "install guide", "engine docs" |
| **create-engine-installer** | Install generators | "install generator", "engine setup", "copy migrations" |
| **review-engine** | Complete engine review | "review engine", "engine quality", "engine audit" |
| **release-engine** | Versioned engine release | "release engine", "version bump", "publish gem", "changelog" |
| **upgrade-engine** | Cross-version compatibility | "Zeitwerk", "compatibility", "Rails upgrade", "cross-version" |
| **extract-engine** | Extract code to engine | "extract to engine", "move feature", "host coupling" |

---

## Skills by Objective (Quick Lookup)

### If you need...

| You need... | Recommended Skill(s) |
|-------------|----------------------|
| **Understand codebase** | `load-context` |
| **New project setup** | `setup-environment` |
| **Start coding** | `plan-tests` → `write-tests` |
| **Fix bug** | `triage-bug` *(from core)* |
| **Refactor** | `refactor-code` |
| **Create service** | `create-service-object` *(from core)* |
| **Integrate external API** | `integrate-api-client` *(from core)* |
| **Add auth/roles** | `implement-authorization` |
| **Optimize performance** | `optimize-performance` |
| **Create engine** | `create-engine` |
| **Review code** | `code-review` |
| **Respond to feedback** | `respond-to-review` *(from core)* |
| **Setup CI/CD** | *(roadmap — `setup-ci-cd`)* |
| **Not sure** | `skill-router` *(from core)* |

---

## Proposed New Skills (Roadmap)

| Skill | Priority | Status |
|-------|----------|--------|
| setup-ci-cd | 🔴 Critical | Not yet implemented |

---

## See also

- [Integration Matrix](integration-matrix.md) — Which skill connects to which
- [Agents Index](../../agents/) — Complete orchestrated step-by-step flows
- Orchestration skill `skill-router` (from ruby-core-skills) — Entry skill when you don't know which to use

---

## Index by Category

Skills are organized in category folders (`skills/<category>/`) with frequent entry points at root.

### API

| Skill | Path | Description |
|-------|------|-------------|
| **generate-api-collection** | `skills/api/generate-api-collection/` | Generate Postman collections for REST APIs |
| **implement-graphql** | `skills/api/implement-graphql/` | Schema design, N+1 prevention, auth |

*Note: `integrate-api-client` has moved to `igmarin/ruby-core-skills`*

### Context

| Skill | Path | Description |
|-------|------|-------------|
| **load-context** | `skills/context/load-context/` | Load minimum context before coding |
| **setup-environment** | `skills/context/setup-environment/` | Complete dev environment setup |

### Code Quality

| Skill | Path | Description |
|-------|------|-------------|
| **code-review** | `skills/code-quality/code-review/` | Systematic Rails PR review |
| **review-architecture** | `skills/code-quality/review-architecture/` | Structural boundary review |
| **security-check** | `skills/code-quality/security-check/` | Deep security audit |
| **apply-stack-conventions** | `skills/code-quality/apply-stack-conventions/` | Stack-specific conventions |
| **apply-code-conventions** | `skills/code-quality/apply-code-conventions/` | DRY/YAGNI/PORO/CoC/KISS by path |
| **implement-authorization** | `skills/code-quality/implement-authorization/` | Pundit/CanCanCan, roles, permissions |
| **refactor-code** | `skills/code-quality/refactor-code/` | Refactor preserving behavior |


### DDD

*DDD skills have moved to `igmarin/ruby-core-skills`:*
*- `define-domain-language` — Domain terms glossary*
*- `review-domain-boundaries` — Review bounded contexts*
*- `model-domain` — Map DDD to Rails*


### Engines

### Engines

| Skill | Path | Description |
|-------|------|-------------|
| **create-engine** | `skills/engines/create-engine/` | Rails engine scaffolding |
| **test-engine** | `skills/engines/test-engine/` | Engine testing setup |
| **review-engine** | `skills/engines/review-engine/` | Complete engine review |
| **release-engine** | `skills/engines/release-engine/` | Versioned engine release |
| **document-engine** | `skills/engines/document-engine/` | Engine documentation |
| **create-engine-installer** | `skills/engines/create-engine-installer/` | Install generators |
| **extract-engine** | `skills/engines/extract-engine/` | Extract code to engine |
| **upgrade-engine** | `skills/engines/upgrade-engine/` | Cross-version compatibility |

### Infrastructure

| Skill | Path | Description |
|-------|------|-------------|
| **review-migration** | `skills/infrastructure/review-migration/` | Safe migrations for production |
| **implement-background-job** | `skills/infrastructure/implement-background-job/` | Active Job, Solid Queue, Sidekiq |
| **seed-database** | `skills/infrastructure/seed-database/` | Fixtures vs Seeds |
| **optimize-performance** | `skills/infrastructure/optimize-performance/` | N+1s, profiling, caching |
| **version-api** | `skills/infrastructure/version-api/` | REST API versioning |
| **implement-hotwire** | `skills/infrastructure/implement-hotwire/` | Turbo/Stimulus integration |


### Orchestration

*Orchestration skills have moved to `igmarin/ruby-core-skills`:*
*- `skill-router` — Routes to correct specialized skill*

### Patterns

*Pattern skills have moved to `igmarin/ruby-core-skills`:*
*- `create-service-object` — `.call` pattern, response contract*
*- `implement-calculator-pattern` — Variant-based calculators*
*- `write-yard-docs` — Inline documentation with YARD*




### Testing

|| Skill | Path | Description |
||-------|------|-------------|
|| **write-tests** | `skills/testing/write-tests/` | TDD discipline, spec types |
|| **test-service** | `skills/testing/test-service/` | Service object specific testing |
|| **plan-tests** | `skills/testing/plan-tests/` | Choose the best first failing spec |

*Note: `triage-bug` has moved to `igmarin/ruby-core-skills`*

### Agents

| Agent | Path | Description |
|-------|------|-------------|
| **tdd** | `agents/tdd/` | TDD feature loop: test → implement → review → PR |
| **review** | `agents/review/` | Systematic PR review: review → deep dive → response |
| **setup** | `agents/setup/` | Project setup: context → onboarding → CI/CD |
| **quality** | `agents/quality/` | Quality check: conventions → refactor → docs |
| **engine** | `agents/engine/` | Engine development: author → test → review → release |
| **bug-fix** | `agents/bug-fix/` | Bug resolution: triage → reproduce → fix → verify |
| **graphql** | `agents/graphql/` | GraphQL API: domain → schema → TDD → security |
| **migration** | `agents/migration/` | Database migration: plan → test → deploy |
| **background-job** | `agents/background-job/` | Background job: design → TDD → retry → monitor |
