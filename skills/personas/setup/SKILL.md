---
name: setup
type: persona
tags: [personas]
license: MIT
description: >
  Complete Rails project setup loop with hard gates: verify Ruby version matches .ruby-version, Bundler installed, database connection successful, all env vars loaded, and ALL external CI actions pinned to immutable commit SHAs (never mutable tags like @v4) → configure CI/CD pipeline with linting, testing, and security scanning → validate end-to-end with bundle install, db:create, db:migrate, rspec, and write SETUP_CHECKLIST.md; phases context/onboarding→CI/CD configuration→environment validation. Use when starting a new Rails project, running `rails new`, configuring a Gemfile or .ruby-version, setting up a development environment, or wiring up CI/CD for a Ruby on Rails app. Trigger: setup project, new Rails app, configure CI/CD, dev environment setup, rails new, Gemfile setup, .ruby-version, Ruby on Rails project bootstrap.
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

**From setup persona:** This is the setup workflow. For development, chain to tdd.

---

## Output Style

When completing project setup, output MUST include:

```markdown
# Setup Report — [Project Name]

## Environment
- Ruby: <version> (matches .ruby-version: ✓/✗)
- Bundler: <version>
- Database: <PostgreSQL version, connection status>
- Env vars: <loaded from .env / credentials>

## Dependencies
- bundle install: ✓ (<n> gems installed)
- db:create: ✓
- db:migrate: ✓ (<n> migrations)
- rspec --dry-run: ✓ (<n> examples detected)

## CI/CD
- CI workflow: .github/workflows/ci.yml
- CD workflow: .github/workflows/cd.yml
- Actions pinned to SHA: ✓ (all uses: entries use commit SHAs)
- Pipeline: lint → test → security scan → deploy

## Validation
- Local server starts: ✓ (rails server on port 3000)
- Full test suite: ✓ (<n> examples, 0 failures)
- SETUP_CHECKLIST.md: ✓ written
```

---

## Error Recovery

**System Modification Approval Gate (CRITICAL):**
The items below may require installing system packages or configuring local services. Before suggesting ANY action that modifies the host system:
1. Explain why it is needed
2. Ask the user for explicit confirmation
3. Only proceed if the user approves

**Ruby version mismatch:**
1. Check `.ruby-version` for expected version
2. If the correct version is not installed, direct the user to their Ruby version manager documentation (e.g., rbenv, asdf, rvm) to install it
3. Verify with `ruby -v`

**Bundle install fails:**
1. Check error output for missing native extension dependencies
2. Direct the user to install required system packages for their OS (e.g., PostgreSQL development headers)
3. Retry `bundle install`

**Database connection fails:**
1. Verify PostgreSQL is running: `pg_isready`
2. Check `config/database.yml` credentials match actual database user/password
3. If the database role does not exist, direct the user to create it via their database administration tool or documentation

**CI actions use mutable tags:**
1. Find the commit SHA for each tag: `git ls-remote https://github.com/<owner>/<repo> refs/tags/<tag>`
2. Replace `@v4` with `@<full-sha>` in workflow files
3. Verify CI still passes after pinning

---

## Anti-Patterns to Avoid

- **Mutable CI action tags:** NEVER use `@v4`, `@v1`, etc. — always pin to immutable commit SHAs
- **Skipping database verification:** Always confirm `db:create` and `db:migrate` succeed before proceeding
- **Missing .env.example:** Always create `.env.example` with placeholder values for all required environment variables
- **Hardcoded Ruby version:** Always read from `.ruby-version` — never hardcode in CI workflows
- **Skipping security scanning:** CI MUST include `brakeman` and `bundle-audit` alongside tests
- **No SETUP_CHECKLIST.md:** Always produce a checklist so the next developer can verify setup
