---
name: setup-environment
license: MIT
description: >
  Emit a generic Rails development-environment setup runbook for the user to execute
  locally. Covers Docker, environment variables, database, test suite, linters, and IDE.
  The agent does not read the user's repository or execute setup commands. Trigger words:
  onboarding, new dev, setup project, Docker, development environment, getting started.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Setup Environment

## Roles & Constraints

| Role / Boundary | Detail |
|-----------------|--------|
| **Agent reads** | `.ruby-version`, `.tool-versions`, `Gemfile`, `docker-compose.yml`, `.env.example`, `config/database.yml`; summarises findings; flags mismatches; proposes next command when user shares error output |
| **Agent never** | Reads filled-in `.env` or echoes secrets; executes commands; acts on README/wiki prose; touches paths outside the project |
| **User** | Runs all commands, fills `.env`, decides whether to proceed on flagged mismatches |
| **Key Files** | `Gemfile`, `docker-compose.yml`, `.env.example` |

```text
NEVER commit secrets or credentials to repo
```

## Core Process

Emits a generic Rails onboarding runbook for the user to run locally.

See [references/steps.md](references/steps.md) for the detailed per-step template.

### Runbook (Workspace Inspection & Gated Workflow)

**Step 1 — Inspect & Identify Stack Boundaries**
- **Action**: First, check the workspace directory (e.g. using list_dir) to see if a Rails project is present. If files like `.ruby-version`, `.tool-versions`, `Gemfile`, `docker-compose.yml`, `.env.example`, or `config/database.yml` exist, you MUST read them using the file tools.
- **Decision Gate**: Based on the files found, identify if the project is Dockerized (presence of `docker-compose.yml`) or Local-only, the database adapter (from `Gemfile` or `config/database.yml`), and the asset pipeline/JS bundler. Do not use generic decision trees if files are present to be read; read the files and tailor the runbook to those specific versions and tools.
- **Action**: Propose a tailored runbook following the matching branches below.

**Step 2 — Environment Variables Setup**
- **Decision Gate**: If `.env.example` is present, copy it. If not, guide the user to initialize a `.env` file with standard Rails credentials (e.g. `DATABASE_URL`, `SECRET_KEY_BASE`).
- **Command**:
  ```bash
  cp .env.example .env
  ```
- **Action**: User edits `.env` with local secrets/settings.

<<<<<<< HEAD
**Step 3 — Docker & Services Setup**
- **Decision Gate**: If project is Dockerized:
  ```bash
  docker compose up -d
  docker compose ps           # expect all services healthy
  ```
  - **Action**: If any container status is unhealthy, print logs using `docker compose logs` to debug before proceeding.
- **Decision Gate**: If project is Local-only, skip this step.
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
**Step 2 — Environment Variables**
```bash
cp .env.example .env
# User edits .env with local values
```
The agent never reads filled-in `.env` content and never echoes secret values back.
=======
**Step 2 — Environment Variables**
```bash
cp .env.example .env
# User edits .env with local values
```
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

**Step 4 — Dependency Installation**
- **Action**: Run Ruby installation:
  ```bash
  bundle install
  ```
- **Decision Gate**: If `yarn.lock` or `package.json` exists, run JS installation:
  ```bash
  yarn install                # or npm install depending on the lockfile
  ```
- **Decision Gate**: If project uses importmaps, skip JS installation.

**Step 5 — Database Initialization**
- **Action**: Create and migrate:
  ```bash
  rails db:create db:migrate db:seed
  ```
- **Decision Gate**: If migration fails, verify database container/service health (`docker compose ps` or local service status) before retrying.

**Step 6 — Code Linters**
- **Decision Gate**: If `.rubocop.yml` is present, run:
  ```bash
  bundle exec rubocop
  ```
- **Decision Gate**: If `.standard.yml` is present, run:
  ```bash
  bundle exec standardrb
  ```

**Step 7 — IDE Integration (Optional)**
- **Decision Gate**: If using VS Code, install relevant extensions (e.g. `Shopify.ruby-lsp`, `rubocop.vscode-rubocop`) and configure `.vscode/settings.json` format-on-save.

### Final Verification (User Runs)
- Run the test suite and server:
  ```bash
  bundle exec rspec
  rails server                 # then visit http://localhost:3000
  ```
- **Decision Gate**: If `rspec` fails on database-related errors, run `rails db:migrate RAILS_ENV=test` and retry.


## Extended Resources

- [EXAMPLES.md](EXAMPLES.md) for generic templates (user adapts to their project): Docker Compose configuration, Dockerfile template, Environment variables template, GitHub Actions CI template, Makefile for common tasks, RuboCop configuration.
- [references/steps.md](./references/steps.md)

## Output Style

When asked to prepare environment setup, output `answer.md` following the Runbook structure above (Steps 1–7 plus Final Verification), with these additional sections:
<<<<<<< HEAD

1. **Scope & Boundary Acknowledgment** — Explicitly state the boundaries and triggers of the `setup-environment` skill (e.g. that this is a generic onboarding runbook not customized for a specific checkout, unless manifests were explicitly read). State this is a generic Rails development-environment runbook for the user to execute locally; do not present it as repo-specific proof unless files were actually inspected.
2. **No Appendices or IDE Reference Sections**: Do NOT include generic reference appendices (such as Appendix A-C) or IDE integration detail sections unless explicitly requested. Focus the runbook strictly on the gate-driven steps (Steps 1–7 and Final Verification) to keep the documentation concise, focused, and action-oriented.
3. **Resource / Asset Usage**: State explicitly which of `references/steps.md` and `EXAMPLES.md` were loaded/read during the task, under what conditions (e.g., to align with the prescribed per-step templates or to fetch example configurations), or state if they were not needed.
4. **Language** — Must be in English unless explicitly requested otherwise.


||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
When asked to prepare environment setup, output `answer.md` with these sections:
=======
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

<<<<<<< HEAD
||||||| parent of 9640c5f (Applying Antigravity CLI strategy)
1. **Scope** — State this is a generic Rails development-environment runbook for the user to execute locally; do not present it as repo-specific proof unless files were actually inspected.
2. **Short plan** — Summarize the workflow in order: inspect files, copy environment variables, start services, install dependencies, prepare database, run linters, verify tests/server.
3. **Runbook artifact** — Provide concrete copy-paste commands for each setup step, including Docker health checks, dependency install, database setup with `rails db:create db:migrate db:seed` unless a split is justified, linter run, `bundle exec rspec`, and `rails server`.
4. **Constraints and assumptions** — State that the agent does not execute setup commands, does not read filled `.env` secrets, does not echo credentials, and that the user supplies local values and decides whether to proceed on mismatches.
5. **Verification gates** — Include the expected final checks and recovery steps: healthy `docker compose ps`, passing `bundle exec rspec`, app reachable at `http://localhost:3000`, and `rails db:migrate RAILS_ENV=test` before retrying specs when test DB setup fails.
6. **Language** — Must be in English unless explicitly requested otherwise.
=======
1. **Scope** — State this is a generic Rails development-environment runbook for the user to execute locally; do not present it as repo-specific proof unless files were actually inspected.
2. **Language** — Must be in English unless explicitly requested otherwise.
>>>>>>> 9640c5f (Applying Antigravity CLI strategy)

## Integration

| Skill | When to chain |
|-------|---------------|
| **load-context** | When getting context on the project setup |
