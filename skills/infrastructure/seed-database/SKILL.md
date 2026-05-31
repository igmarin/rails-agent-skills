---
name: seed-database
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

## Extended Resources

### Environment-Specific Seeds

Split seed logic across environment files to keep `db/seeds.rb` clean:

```ruby
# db/seeds.rb
if Rails.env.development?
  require Rails.root.join('db/seeds/development')
elsif Rails.env.test?
  require Rails.root.join('db/seeds/test')
end
```

```ruby
# db/seeds/development.rb
10.times do |i|
  email = "dev_user_#{i + 1}@example.com"

  User.find_or_create_by!(email: email) do |u|
    u.password = ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16))
  end
end
```

### FactoryBot Factory

Place factories under `spec/factories/` and use traits for role variants:

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16)) }

    trait :admin do
      admin { true }
    end
  end
end
```

### Reference Links

- [FactoryBot documentation](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md)
- [Faker gem](https://github.com/faker-ruby/faker)
- [Rails Seeding Guide](https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data)

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

## Additional Resources

- [EXAMPLES.md](EXAMPLES.md) — Complete seeding examples and patterns
- [references/workflow.md](references/workflow.md) — Seeding workflow and best practices
