---
name: seed-database
type: atomic
license: MIT
description: >
  Use when managing development and test data in Rails — must write idempotent seeds using find_or_create_by!, run seeds with rails db:seed or rails db:setup, verify data by opening rails console and spot-checking records, use ENV variables or SecureRandom for non-production data without committing secrets in code, and use rails credentials:edit for production secrets. Trigger words: seeds, fixtures, seeding, db:seed, test data.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Seed Database

Manage development and test data effectively.

## Quick Reference

| Use | Solution |
|-----|----------|
| Static reference data | `db/seeds.rb` with `find_or_create_by!` |
| Test scenarios | FactoryBot in `spec/factories/` |
| Complex relationships | Both combined |

## HARD-GATE

```text
NEVER commit production data to seeds
ALWAYS use factories for test-specific scenarios
ALWAYS make seeds idempotent (can run multiple times safely)
NEVER hardcode credentials (passwords, API keys, secrets) in seeds, factories, or examples
  - Use ENV variables (e.g., ENV.fetch('DEFAULT_SEED_PASSWORD')) or SecureRandom.hex(16) for non-production data
  - Use `rails credentials:edit` to manage production secrets, never commit them in code
```

## Core Process

1. **Write idempotent seeds** — use `find_or_create_by!` so re-runs are safe.
2. **Scope by environment** — guard non-production data with `Rails.env` checks.
3. **Run seeds** — execute `rails db:seed` (or `rails db:setup` for a fresh database).
4. **Validate idempotency** — run `rails db:seed` a second time and confirm no duplicates or errors.
5. **Verify data** — open `rails console` and spot-check expected records exist with correct attributes.

## Minimal Inline Example

A copy-paste ready `db/seeds.rb` covering idempotency, environment scoping, and safe credentials:

```ruby
# db/seeds.rb

# Static reference data — safe to run repeatedly
Role.find_or_create_by!(name: 'admin') do |r|
  r.description = 'Full system access'
end

Role.find_or_create_by!(name: 'member') do |r|
  r.description = 'Standard user access'
end

# Development-only seed data — never runs in production
if Rails.env.development?
  User.find_or_create_by!(email: 'admin@example.com') do |u|
    u.role       = Role.find_by!(name: 'admin')
    u.password   = ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16))
  end
end
```

For FactoryBot factory definitions and more complex relationship patterns, see **[EXAMPLES.md](EXAMPLES.md)**.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](EXAMPLES.md)** — Use when you need complete seeding examples with environment-specific patterns and FactoryBot factory definitions
- **[references/workflow.md](references/workflow.md)** — Use when implementing complex seeding workflows or migration-dependent seed data

## Output Style

1. Use idiomatic Rails seeding patterns.
2. Structure factories clearly.
3. Follow the credential and idempotency rules in HARD-GATE without exception.
4. Include verification commands: `rails db:seed`, a second idempotency run, and a `rails console` spot-check.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | When setting up test scenarios |
| **review-migration** | When ensuring DB schema is aligned |
