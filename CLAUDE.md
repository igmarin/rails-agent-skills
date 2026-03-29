# Rails Agent Skills — Claude Code Context

This plugin provides a library of specialized Rails development skills. When a task arrives, check if any skill applies and read it before responding.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

```text
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.

WORKFLOW: PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR

Tests are a GATE. Implementation code CANNOT be written until:
1. The test EXISTS
2. The test has been RUN
3. The test FAILS for the right reason (feature missing, not a typo)
```

Wrote implementation code before the test? Delete it. Start over. No exceptions.

## Available Skills

Skills are located in subdirectories of this plugin. Read the relevant `SKILL.md` before responding to any task that matches.

### Planning & Tasks
| Skill | Use when... |
|-------|-------------|
| `create-prd` | User asks to plan a feature or write requirements |
| `generate-tasks` | User asks for implementation steps or task breakdown |
| `jira-ticket-planning` | User wants Jira-ready tickets from a plan |

### Rails Code Quality
| Skill | Use when... |
|-------|-------------|
| `rails-code-review` | Reviewing Rails PRs, controllers, models, migrations |
| `rails-architecture-review` | Reviewing app structure, boundaries, fat models/controllers |
| `rails-security-review` | Checking auth, params, XSS, CSRF, SQLi |
| `rails-migration-safety` | Planning or reviewing database migrations |
| `rails-stack-conventions` | Writing new Rails code for PostgreSQL + Hotwire + Tailwind stack |
| `rails-code-conventions` | DRY/YAGNI/PORO/CoC/KISS, linter as style SoT |
| `rails-background-jobs` | Adding or reviewing background jobs |

### DDD & Domain Modeling
| Skill | Use when... |
|-------|-------------|
| `ddd-ubiquitous-language` | Clarifying domain terms before modeling or refactoring |
| `ddd-boundaries-review` | Reviewing bounded contexts and language leakage |
| `ddd-rails-modeling` | Mapping DDD concepts to Rails models, services, value objects |

### Ruby Patterns
| Skill | Use when... |
|-------|-------------|
| `ruby-service-objects` | Creating service classes with `.call` pattern |
| `ruby-api-client-integration` | Integrating external APIs (Auth/Client/Fetcher/Builder) |
| `strategy-factory-null-calculator` | Building variant-based calculators |
| `yard-documentation` | Writing or reviewing YARD docs |

### Testing
| Skill | Use when... |
|-------|-------------|
| `rspec-best-practices` | Writing, reviewing, or cleaning up RSpec tests |
| `rails-tdd-slices` | Choosing the best first failing spec for a Rails change |
| `rails-bug-triage` | Turning a bug report into a failing spec and fix plan |
| `rspec-service-testing` | Testing service objects |

### Rails Engines
| Skill | Use when... |
|-------|-------------|
| `rails-engine-author` | Creating or scaffolding a Rails engine |
| `rails-engine-testing` | Setting up dummy app and engine specs |
| `rails-engine-reviewer` | Reviewing an existing engine |
| `rails-engine-release` | Preparing an engine release |
| `rails-engine-docs` | Writing engine documentation |
| `rails-engine-installers` | Creating install generators |
| `rails-engine-extraction` | Extracting code from host app to engine |
| `rails-engine-compatibility` | Ensuring cross-version compatibility |
| `api-postman-collection` | Creating or updating Postman collections for API endpoints |

### Refactoring
| Skill | Use when... |
|-------|-------------|
| `refactor-safely` | Restructuring code while preserving behavior |

## Skill Priority

1. **TDD always** — `rspec-best-practices` applies whenever code is produced
2. **Planning first** — `create-prd`, `generate-tasks` (optionally `jira-ticket-planning`)
3. **Domain discovery next** — `ddd-*` skills when domain is the hard part
4. **Process skills** — `refactor-safely`
5. **Domain skills** — `rails-*`, `ruby-*` for specific implementation

## Typical Workflows

**New feature:**
`create-prd` → `generate-tasks` → `rails-tdd-slices` → **[GATE: tests]** → implement → `yard-documentation` → `rails-code-review` → PR

**DDD-first:**
`create-prd` → `ddd-ubiquitous-language` → `ddd-boundaries-review` → `ddd-rails-modeling` → `generate-tasks` → `rails-tdd-slices` → implement

**Code review:**
`rails-code-review` + `rails-security-review` + `rails-architecture-review`

**Bug fix:**
`rails-bug-triage` → `rails-tdd-slices` → **[GATE: failing test]** → fix → verify test passes

**New engine:**
`rails-engine-author` → **[GATE: engine specs]** → implement → `rails-engine-docs`

**Refactoring:**
`refactor-safely` → **[GATE: characterization tests pass]** → refactor → verify tests still pass

## Output Language

Generated artifacts (YARD docs, Postman collections, READMEs, task descriptions) must be in **English** unless the user explicitly requests another language.
