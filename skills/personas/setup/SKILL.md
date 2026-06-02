---
name: setup
type: persona
tags: [personas]
license: MIT
description: >
  Complete Rails project setup loop. Installs dependencies via Bundler, configures database
  connections, generates Rails app scaffold, validates the dev environment, and generates GitHub
  Actions or GitLab CI pipelines with linting, testing, and security scanning. Use when starting
  a new Rails project, running `rails new`, configuring a Gemfile or .ruby-version, setting up a
  development environment, or wiring up CI/CD for a Ruby on Rails app. Trigger: setup project,
  new Rails app, configure CI/CD, dev environment setup, rails new, Gemfile setup, .ruby-version,
  Ruby on Rails project bootstrap.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when starting new Rails project, setting up dev environment, or configuring CI/CD"
  phases: "Phase 1: Context & Onboarding, Phase 2: CI/CD Configuration, Phase 3: Environment Validation"
  hard_gates: "Environment Check, CI/CD Configuration, Environment Validation"
  dependencies:
    - source: self
      skills: [load-context, setup-environment]
  keywords: rails, setup, onboarding, ci/cd, agent, devops, configuration
---
# Setup Persona

## Agent Phases

### Phase 1: Context & Onboarding

**Load project context first (if sub-skills are available in the bundle):**
1. **skills/context/load-context** — Understand existing codebase structure
2. **skills/context/setup-environment** — Complete dev environment setup

**Inline fallback (always applicable; use this if sub-skills are unavailable):**
```bash
# Verify Ruby version matches .ruby-version
ruby -v
# Install dependencies
bundle install
# Check database connectivity
rails db:create db:migrate
# Confirm test runner is operational
bundle exec rspec --dry-run
# Load env vars (copy example if missing)
cp .env.example .env 2>/dev/null || true
```

**HARD GATE — Environment Check** (all items must pass before Phase 2):
- [ ] Ruby version correct (check `.ruby-version`)
- [ ] Bundler installed and working
- [ ] Database connection successful
- [ ] All env vars loaded (check `config/credentials.yml.enc` or `.env`)
- [ ] All external CI actions pinned to immutable commit SHAs (never mutable tags like @v4, @v1)

**If environment check FAILS:** Fix the failing item above before proceeding to Phase 2.

---

### Phase 2: CI/CD Configuration

**Proceed only after environment check passes.**

1. **CI/CD Proposal Checkpoint** — Decide on pipeline approach:
   - GitHub Actions, GitLab CI, or other platform?
   - Staging vs production environments?
   - Deployment strategy (basic, blue-green, canary)?

**Shared job preamble** (pin SHAs, never mutable tags):
```yaml
steps:
  - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
  - uses: ruby/setup-ruby@ff740bc00a01b3a50fffc55a1071b1060eeae9dc
    with:
      ruby-version: .ruby-version
      bundler-cache: true
```

2. **Configure CI pipeline** — write to `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # <shared preamble above>
      - run: bundle exec rails db:create db:migrate
      - run: bundle exec rspec
      - run: bundle exec rubocop
      - run: bundle exec brakeman --no-pager
      - run: bundle exec bundle-audit check --update
```

3. **Configure CD pipeline** — write to `.github/workflows/cd.yml`:

```yaml
name: CD
on:
  push:
    branches: [main]
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      # <shared preamble above>
      - run: bundle exec rails db:migrate
        env:
          RAILS_ENV: staging
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
      # Add deployment step (e.g. Heroku, Fly.io, or Kamal CLI)
  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment: production   # Requires manual approval gate in GitHub
    steps:
      # <shared preamble above>
      - run: bundle exec rails db:migrate
        env:
          RAILS_ENV: production
          DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}
      # Add deployment step matching staging; rollback via platform CLI
```

---

### Phase 3: Environment Validation

**Verify everything works end-to-end:**

```bash
# Local development
bundle install
rails db:create db:migrate
rails server
bundle exec rspec

# CI simulation (if possible locally)
act push  # GitHub Actions local runner (optional)
```

**Write `SETUP_CHECKLIST.md`** with the final state of all HARD GATE items (see Phase 1) plus:
- [ ] CI configured
- [ ] Secrets configured

---

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| None (entry point) | setup | tdd (start developing) |

**From AGENTS.md:** This is the setup agent loop. For development, chain to tdd.
