---
name: engine
license: MIT
description: >
  Complete Rails engine development workflow. Orchestrates scaffolding engine structure and generating
  mountable namespaces → testing → code review and dependency auditing → release.
  Use when creating, extracting, or maintaining Rails engines. Trigger: create engine,
  extract engine, engine release, engine testing, mountable engine, gem extraction.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when creating, extracting, or maintaining Rails engines"
  phases: "Phase 1: Engine Authoring, Phase 2: Testing Setup, Phase 3: Implementation & Review, Phase 4: Documentation & Release"
  hard_gates: "Engine Structure Check, Tests Run, Isolation Before Integration"
  dependencies: "create-engine, test-engine, review-engine, upgrade-engine, document-engine, release-engine"
  keywords: rails, engine, agent, gem, release, testing, extraction
---
# Engine Agent

Orchestrates the full lifecycle of Rails engine development from scaffolding to release.

> **Note:** Sub-skills referenced below (`skills/engines/create-engine`, `test-engine`, `review-engine`, etc.) are expected to exist separately in the skill bundle.

## Agent Phases

### Phase 1: Engine Authoring

1. **skills/engines/create-engine** — Design and scaffold namespace isolation, directory structure, and gemspec configuration

**Kickoff command:**
```bash
rails plugin new my_engine --mountable --skip-test
```

**Key files to verify after scaffolding:**
- `lib/my_engine/engine.rb` — namespace isolation declared
- `lib/my_engine/version.rb` — version constant present
- `my_engine.gemspec` — metadata complete and valid
- `test/dummy/` — dummy app scaffolded

**HARD GATE — Engine Structure Check:**
```bash
# Verify namespace isolation
grep -r 'module MyEngine' lib/my_engine/engine.rb

# Verify gemspec metadata is complete
ruby -e "require 'rubygems'; spec = Gem::Specification.load('my_engine.gemspec'); puts spec.validate"

# Verify isolated migrations declared
grep 'isolate_namespace\|engine.config.isolate_namespace' lib/my_engine/engine.rb
```

- Proper namespace (`MyEngine::` not `::`)
- Isolated migrations and dummy app configured
- Gemspec metadata passes `gem specification` validation

**If structure check FAILS:** Return to create-engine and fix.

---

### Phase 2: Testing Setup

**Proceed only after structure check passes.**

1. **skills/engines/test-engine** — Set up dummy app, spec helpers, factory isolation, and test database

2. **Write initial characterization tests:**
   - Test engine mounting
   - Test generators if any
   - Test core functionality

**Run tests from engine root:**
```bash
cd my_engine && bundle exec rspec
```

**HARD GATE — Tests Run:**
```bash
bundle exec rspec --format progress 2>&1 | tail -5
# Must show: no load errors, exit 0 or partial pass
```

**If load errors appear, fix in order:**
- Verify `spec/spec_helper.rb` requires dummy app: `require File.expand_path('../dummy/config/environment', __FILE__)`
- Verify dummy app mounts engine in `test/dummy/config/application.rb`
- Run `bundle install` inside engine root
- Confirm `Gemfile` points to a valid dummy app path

---

### Phase 3: Implementation & Review

**Build engine features with quality gates:**

1. **Implement features** using:
   - tdd-workflow for complex features
   - Individual skills for simple additions

2. **skills/engines/review-engine** — Coupling assessment, API surface design, host app integration points

3. **skills/engines/upgrade-engine** — Rails/Ruby version matrix and dependency constraints

**Check gem dependencies:**
```bash
bundle exec rake dependencies
bundle exec bundler-audit check --update
```

---

### Phase 4: Documentation & Release

1. **skills/engines/document-engine** — Installation, configuration, usage examples, changelog

2. **skills/engines/release-engine** — Version bump (SemVer), changelog, upgrade notes, git tag

**Release commands:**
```bash
gem build my_engine.gemspec
gem push my_engine-1.0.0.gem
git tag v1.0.0 && git push origin v1.0.0
```

**Optional:**
3. **skills/engines/create-engine-installer** — Idempotent `rails g my_engine:install` generator for host app configuration

**Output:** Published gem or releasable GitHub repository.

---

## Quick Reference

```
New engine?        → create-engine → test-engine
Extract from app?  → extract-engine → create-engine
Release engine?    → review-engine → release-engine
Not sure?          → skill-router
```

## HARD-GATE: Isolation Before Integration

**NEVER integrate engine into host app before:**
1. Engine tests pass standalone
2. Namespace properly isolated
3. Migrations won't conflict
4. Dependencies clearly declared

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| create-prd (engine requirements) | engine | tdd (engine features) |
| None (extract existing) | engine | Host app integration |

**From AGENTS.md:** This is the engine development workflow. Chain to tdd for feature development within the engine.
