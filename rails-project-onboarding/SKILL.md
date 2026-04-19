---
name: rails-project-onboarding
description: >
  Set up development environment for new developers on Rails projects.
  Covers Docker configuration, environment variables, database setup,
  test suite configuration, and IDE setup. Trigger words: onboarding,
  new dev, setup project, Docker, development environment, getting started.
---

# Rails Project Onboarding

Complete development environment setup for Rails projects.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/steps.md](./references/steps.md)

## HARD-GATE

```text
ALWAYS test the full setup process from clean state
NEVER commit secrets or credentials to repo
ALWAYS document any non-standard setup steps
```

## Quick Checklist

- [ ] Repository cloned
- [ ] Docker configured (if used)
- [ ] Environment variables set
- [ ] Database migrated and seeded
- [ ] Test suite running
- [ ] Linters configured
- [ ] IDE setup complete

## 7-Step Setup Workflow

See [references/steps.md](references/steps.md) for detailed walkthrough of each step.

### Overview

1. **Clone and Inspect** — Verify Ruby version and project structure
2. **Environment Variables** — Set up `.env` and credentials
3. **Docker** — Start containers or configure local services
4. **Dependencies** — Run `bundle install` and `yarn install`
5. **Database** — Create, migrate, and seed
6. **Linters** — Install and configure RuboCop
7. **IDE** — Set up Ruby LSP and extensions

### Inline Critical Commands

**Step 2 — Environment Variables**
```bash
cp .env.example .env
# Edit .env with your local values
```

**Step 3 — Docker**
```bash
docker compose up -d
# Verify: all services should show as healthy
docker compose ps
```
> ⚠️ If any service is not healthy, check logs with `docker compose logs <service>` before proceeding.

**Step 4 — Dependencies**
```bash
bundle install
yarn install
```

**Step 5 — Database**
```bash
rails db:create db:migrate db:seed
```
> ⚠️ If `db:migrate` fails, verify the database container is running: `docker compose ps` should show the DB service as healthy.

## Templates

See [EXAMPLES.md](EXAMPLES.md) for:
- Docker Compose configuration
- Dockerfile template
- Environment variables template
- GitHub Actions CI template
- Makefile for common tasks
- RuboCop configuration

## Final Verification

```bash
# Run tests
bundle exec rspec

# Start server
rails server
# Visit http://localhost:3000
```

> ⚠️ If `rspec` fails after a clean setup, re-run `rails db:migrate RAILS_ENV=test` and retry.
