# Skill Catalog

28 public Rails skills and 9 personas. DDD, YARD, service objects, and process skills are in `igmarin/ruby-core-skills`.

## By stage

### Discovery and context

| Skill | Use when |
|-------|----------|
| **load-context** | Existing app. Schema, routes, one neighbor. |
| **setup-environment** | First-time Docker / env / db / suite. |

### Planning

Moved to `ruby-core-skills`: `define-domain-language`, `review-domain-boundaries`, `model-domain`.

### Setup

No atomic skill yet. See [gaps.md](gaps.md) for `setup-ci-cd`. Use the `setup` persona.

### Development

| Skill | Use when |
|-------|----------|
| **plan-tests** | First failing spec. |
| **write-tests** | Writing or cleaning RSpec. |
| **test-service** | `spec/services/`. |
| **implement-background-job** | Active Job, Sidekiq, Solid Queue. |
| **review-migration** | Production-safe migrations. |
| **implement-graphql** | graphql-ruby. |
| **implement-authorization** | Pundit / CanCanCan / policies. |
| **optimize-performance** | N+1, caching, query plans. |
| **version-api** | REST v1/v2. |
| **seed-database** | Seeds vs fixtures vs factories. |
| **implement-hotwire** | Turbo / Stimulus. |

### Quality and review

| Skill | Use when |
|-------|----------|
| **refactor-code** | Same behavior, new structure. |
| **apply-code-conventions** | DRY/YAGNI/PORO by path. |
| **apply-stack-conventions** | PostgreSQL + Hotwire + Tailwind. |
| **code-review** | PR / diff review. |
| **security-check** | XSS, CSRF, SQLi, secrets. |
| **review-architecture** | Fat models, boundaries. |
| **generate-api-collection** | REST collections. Not GraphQL. |

### Engines

| Skill | Use when |
|-------|----------|
| **create-engine** | Scaffold. |
| **test-engine** | Dummy app. |
| **document-engine** | README / install. |
| **create-engine-installer** | Install generator. |
| **review-engine** | Isolation and host contract. |
| **release-engine** | SemVer release. |
| **upgrade-engine** | Cross-version. |
| **extract-engine** | Host → engine. |

## Personas

| Persona | Path | Loop |
|---------|------|------|
| **tdd** | `skills/tdd/` | test → implement → review → PR |
| **review** | `skills/review/` | review → deep dive → response |
| **setup** | `skills/setup/` | context → onboarding → CI |
| **quality** | `skills/quality/` | conventions → refactor → docs |
| **engine** | `skills/engine/` | author → test → review → release |
| **bug-fix** | `skills/bug-fix/` | triage → reproduce → fix → verify |
| **graphql** | `skills/graphql/` | domain → schema → TDD → security |
| **migration** | `skills/migration/` | plan → test → deploy |
| **background-job** | `skills/background-job/` | design → TDD → retry → monitor |

## If you need…

| You need | Use |
|----------|-----|
| Understand the app | `load-context` |
| New project setup | `setup-environment` |
| Start coding | `plan-tests` → `write-tests` |
| Fix a bug | `triage-bug` *(from core)* |
| Refactor | `refactor-code` |
| Service object | `create-service-object` *(from core)* |
| External API | `integrate-api-client` *(from core)* |
| Review a PR | `code-review` |
| Reply to review | `respond-to-review` *(from core)* |
| CI/CD | *(gap — `setup-ci-cd`)* |
| Not sure | `skill-router` *(from core)* |

See [integration-matrix.md](integration-matrix.md) and [gaps.md](gaps.md).
