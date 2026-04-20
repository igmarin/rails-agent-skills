# Workflow: Setup & Configuration (20)

> **Roadmap notice:** the `rails-ci-cd-setup` skill referenced below is **not yet implemented** (see [skill-catalog Roadmap](../reference/skill-catalog.md#proposed-new-skills-roadmap)). The templates on this page are kept as reference material so a maintainer can lift them when the skill ships. Until then, treat this workflow as informational, not as an active skill chain.

**When to use:** Configure CI/CD, deploy environment, or development infrastructure.

---

## Main Flow: CI/CD Setup

```mermaid
graph TB
    subgraph Configure [⚙️ Phase 1: Configure]
        direction TB
        A[Need CI/CD] --> B[rails-ci-cd-setup]
        B --> C{GitHub or GitLab?}
        C --> D[Configure workflow]
    end

    subgraph Build [🔨 Phase 2: Build]
        direction TB
        D --> E[Parallel tests]
        E --> F[Security scanning]
        F --> G[Deploy strategy]
    end

    subgraph Verify [✅ Phase 3: Verify]
        direction TB
        G --> H{Working?}
        H -- No --> D
    end

    H -- Yes --> I((Start Development))

    %% Styling
    style Configure fill:#f5f5f5,stroke:#333,stroke-dasharray: 5 5
    style Build fill:#e1f5fe,stroke:#01579b
    style Verify fill:#fff3e0,stroke:#e65100
    style C fill:#ffd54f
    style H fill:#ffd54f
    style I fill:#e8f5e9,stroke:#1b5e20,stroke-width:3px
```

---

## rails-ci-cd-setup (ROADMAP — not yet implemented)

**Goal:** Configure continuous integration pipeline for Rails.

### CI/CD Checklist

- [ ] **Test workflow** — `bundle exec rspec` on each PR
- [ ] **Parallel tests** — configure for speed
- [ ] **Linters** — `rubocop`, `erb-lint`
- [ ] **Security scanning** — `brakeman`, `bundle-audit`
- [ ] **Database setup** — create + migrate in CI
- [ ] **Caching** — gems, assets, node_modules
- [ ] **Deploy** — staging/production with defined strategy

### GitHub Actions Template

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Setup Database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: |
          bin/rails db:create db:migrate

      - name: Run Tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: bundle exec rspec

      - name: Run Linters
        run: |
          bundle exec rubocop
          bundle exec erb-lint app/views
```

### Security Scanning

```yaml
# Security job
security:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true

    - name: Brakeman
      run: bundle exec brakeman -q -w2 --no-pager

    - name: Bundle Audit
      run: bundle exec bundle-audit check --update
```

### Deployment Strategies

| Strategy | When to use | Complexity |
|----------|-------------|------------|
| **Basic** | Simple apps, low traffic | Low |
| **Blue-Green** | Zero-downtime required | Medium |
| **Canary** | Gradual rollout, high traffic | High |

---

## Integration with Development

| If setup is done... | Next step |
|---------------------|-----------|
| CI/CD ready | `rails-tdd-slices` → [30-development](30-development.md) |
| Need new feature | `create-prd` → [10-planning](10-planning.md) |

---

## Skills in this Workflow

| Skill | Description | Trigger words |
|-------|-------------|---------------|
| **rails-ci-cd-setup** *(roadmap)* | Configure CI/CD pipeline | "CI/CD", "GitHub Actions", "GitLab CI", "deploy" |
| **rails-project-onboarding** | Dev environment setup | "onboarding", "setup project", "Docker" |
