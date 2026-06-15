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

**Inline setup (always applicable):**
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
- [ ] Runtime env vars are available from the shell or `.env`
- [ ] Encrypted secrets are configured in `config/credentials.yml.enc`
- [ ] `config/master.key` exists (or `RAILS_MASTER_KEY` env var is set)
- [ ] All external CI actions pinned to immutable commit SHAs (never mutable tags like @v4, @v1)

**If environment check FAILS:** Fix the failing item above before proceeding to Phase 2.

---

### Phase 2: CI/CD Configuration

**Proceed only after environment check passes.**

**Canonical shared job preamble** (`SHARED_PREAMBLE` — paste verbatim at the start of every job's `steps`; both ci.yml and cd.yml use this block):
```yaml
steps:
  - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
  - uses: ruby/setup-ruby@ff740bc00a01b3a50fffc55a1071b1060eeae9dc
    with:
      ruby-version: .ruby-version
      bundler-cache: true
```

> **Tip:** If your repository uses a `templates/` directory, you may save the final `ci.yml` and `cd.yml` content there for reuse across projects. The instructions below are the canonical source of truth.

1. **Configure CI pipeline** — write to `.github/workflows/ci.yml`.

   Start each job with `SHARED_PREAMBLE`, then add:
```yaml
      - run: bundle exec rails db:create db:migrate
      - run: bundle exec rspec
      - run: bundle exec rubocop
      - run: bundle exec brakeman --no-pager
      - run: bundle exec bundle-audit check --update
```

2. **Configure CD pipeline** — write to `.github/workflows/cd.yml`.

   Fill in `DEPLOY_CLI` (e.g., `heroku`, `flyctl`, `kamal`) and the appropriate secret names before writing the file. Each job begins with `SHARED_PREAMBLE` (copy the block defined above verbatim):
```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      # --- Insert SHARED_PREAMBLE here ---
      - run: bundle exec rails db:migrate
        env:
          RAILS_ENV: staging
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
      - run: <DEPLOY_CLI> deploy --app ${{ secrets.STAGING_APP_NAME }}

  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    steps:
      # --- Insert SHARED_PREAMBLE here ---
      - run: bundle exec rails db:migrate
        env:
          RAILS_ENV: production
          DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}
      - run: <DEPLOY_CLI> deploy --app ${{ secrets.PRODUCTION_APP_NAME }}
```

---

### Phase 3: Environment Validation

**Verify everything works end-to-end:**

Confirm the Phase 1 HARD GATE checklist is still fully passing, then additionally verify:

```bash
# Bring up local server
rails server

# CI simulation (if possible locally)
act push
```

**Write `SETUP_CHECKLIST.md`** with the final state of all HARD GATE items (see Phase 1) plus:
- [ ] CI configured
- [ ] Secrets configured

---

## Output Style

When completing project setup, output MUST include:

```markdown
# Setup Report — [Project Name]

## Environment
- Ruby: <version> (matches .ruby-version: ✓/✗)
- Bundler: <version>
- Database: <PostgreSQL version, connection status>
- Env vars: <loaded from environment configuration file / credentials>

## Dependencies
- bundle install: ✓ (<n> gems installed)
- db:create: ✓ / db:migrate: ✓ (<n> migrations)
- rspec --dry-run: ✓ (<n> examples detected)

## CI/CD
- CI: .github/workflows/ci.yml ✓
- CD: .github/workflows/cd.yml ✓
- Actions pinned to SHA: ✓
- Pipeline: lint → test → security scan → deploy

## Validation
- Local server starts: ✓ (port 3000)
- Full test suite: ✓ (<n> examples, 0 failures)
- SETUP_CHECKLIST.md: ✓ written
```

---

## Error Recovery

**System Modification Approval Gate (CRITICAL):**
Before suggesting ANY action that modifies the host system:
1. Explain why it is needed
2. Ask the user for explicit confirmation
3. Only proceed if the user approves

**Non-obvious failure pointers:**
- **Ruby version mismatch** → check `.ruby-version` and ensure the correct version is active in your version manager before retrying
- **Database connection fails** → run `pg_isready` to confirm PostgreSQL is running; check `config/database.yml` credentials and create any missing role
- **CI actions use mutable tags** → resolve SHA with `git ls-remote https://github.com/<owner>/<repo> refs/tags/<tag>`, replace `@v4` with `@<full-sha>` in workflow files, verify CI passes after pinning
