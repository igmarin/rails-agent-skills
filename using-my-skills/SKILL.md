---
name: using-my-skills
description: >
  Use when starting any conversation involving Rails development. Establishes how to find
  and use available skills, requiring skill invocation before responding when a skill
  might apply.
---

# Using My Skills

This skill library provides specialized knowledge for Ruby on Rails development. When a skill might apply to the current task, invoke it before responding.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

```
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.

THE WORKFLOW IS: PRD → TASKS → TESTS → IMPLEMENTATION

Tests are a GATE. Implementation code CANNOT be written until:
1. The test for that behavior EXISTS
2. The test has been RUN
3. The test FAILS for the right reason (feature missing, not a typo)

ONLY THEN can implementation code be written.
```

**The full cycle for each piece of behavior:**

1. **Write the test** for the behavior described in the PRD/task
2. **Run the test** — confirm it fails because the feature does not exist yet
3. **Only now:** write the simplest implementation code to make the test pass
4. **Run the test again** — confirm it passes and no other tests break
5. **Refactor** if needed — tests must stay green
6. **Move to the next behavior** — repeat from step 1

**This applies when using:** ruby-service-objects, ruby-api-client-integration, strategy-factory-null-calculator, rails-background-jobs, rails-stack-conventions, rails-engine-author, refactor-safely, and any other skill that results in writing Ruby/Rails code.

**Wrote implementation code before the test?** Delete it. Start over. No exceptions.

**Skipped running the test before implementing?** You don't know if the test works. Stop. Run it. Confirm the failure. Then implement.

## Available Skills

### Planning & Tasks

| Skill | Use when... |
|-------|-------------|
| **create-prd** | User asks to plan a feature, write requirements, or create a PRD |
| **generate-tasks** | User asks for implementation steps, task breakdown, or checklist |

### Rails Code Quality

| Skill | Use when... |
|-------|-------------|
| **rails-code-review** | Reviewing Rails PRs, controllers, models, migrations, queries |
| **rails-architecture-review** | Reviewing app structure, boundaries, fat models/controllers |
| **rails-security-review** | Checking auth, params, redirects, XSS, CSRF, SQLi |
| **rails-migration-safety** | Planning or reviewing database migrations |
| **rails-stack-conventions** | Writing new Rails code (style, naming, patterns) |
| **rails-background-jobs** | Adding or reviewing background jobs |

### Ruby Patterns

| Skill | Use when... |
|-------|-------------|
| **ruby-service-objects** | Creating service classes with .call pattern |
| **ruby-api-client-integration** | Integrating external APIs (Auth/Client/Fetcher/Builder) |
| **strategy-factory-null-calculator** | Building variant-based calculators |

### Testing

| Skill | Use when... |
|-------|-------------|
| **rspec-best-practices** | Writing, reviewing, or cleaning up RSpec tests — AND the TDD discipline that applies to ALL implementation |
| **rspec-service-testing** | Testing service objects (spec/services/) |

### Rails Engines

| Skill | Use when... |
|-------|-------------|
| **rails-engine-author** | Creating or scaffolding a Rails engine |
| **rails-engine-testing** | Setting up dummy app and engine specs |
| **rails-engine-reviewer** | Reviewing an existing engine |
| **rails-engine-release** | Preparing an engine release |
| **rails-engine-docs** | Writing engine documentation |
| **rails-engine-installers** | Creating install generators |
| **rails-engine-extraction** | Extracting code from host app to engine |
| **rails-engine-compatibility** | Ensuring cross-version compatibility |

### Refactoring

| Skill | Use when... |
|-------|-------------|
| **refactor-safely** | Restructuring code while preserving behavior |

## Skill Priority

When multiple skills could apply:

1. **TDD always** — rspec-best-practices TDD discipline applies whenever code is produced
2. **Planning skills first** (create-prd, generate-tasks) — determine WHAT to build
3. **Process skills second** (refactor-safely) — determine HOW to approach
4. **Domain skills third** (rails-*, ruby-*) — guide specific implementation

## How to Use

1. When a task arrives, check if any skill applies.
2. If a skill applies, read it and follow its instructions.
3. **If the task produces code, TDD applies.** Write the test first.
4. Skills override default behavior but **user instructions always take priority**.
5. If a skill has a HARD-GATE, you must not skip it.
6. When done with a task, check the skill's Integration table for follow-up skills.

## Typical Workflows

**New feature:**
create-prd -> generate-tasks -> **[GATE: write tests, run, verify failure]** -> implement to pass tests -> rails-code-review

**Code review:**
rails-code-review + rails-security-review + rails-architecture-review

**New engine:**
rails-engine-author -> **[GATE: write engine specs, run, verify failure]** -> implement engine -> rails-engine-docs

**Refactoring:**
refactor-safely -> **[GATE: write characterization tests, run, verify they pass on current code]** -> refactor -> verify tests still pass

**New service object:**
rspec-service-testing -> **[GATE: write .call spec, run, verify failure]** -> ruby-service-objects -> verify spec passes

**Bug fix:**
**[GATE: write test reproducing the bug, run, verify it fails]** -> fix the bug -> verify test passes
