---
name: rails-database-seeding
description: >
  Manage development and test data in Rails. Covers fixtures vs seeds,
  seeding strategies for different environments, test data factories,
  and production-like data generation. Trigger words: seeds, fixtures,
  seeding, database seed, test data, development data, db:seed.
license: MIT
---

# Rails Database Seeding

Manage development and test data effectively.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md)

## HARD-GATE

```text
NEVER commit production data to seeds
ALWAYS use factories for test-specific scenarios
ALWAYS make seeds idempotent (can run multiple times safely)
```

## Quick Reference

| Use | Solution |
|-----|----------|
| Static reference data | `db/seeds.rb` with `find_or_create_by!` |
| Test scenarios | FactoryBot in `spec/factories/` |
| Complex relationships | Both combined |

## Seeding Workflow

1. **Write idempotent seeds** — use `find_or_create_by!` so re-runs are safe.
2. **Scope by environment** — guard non-production data with `Rails.env` checks.
3. **Run seeds** — execute `rails db:seed` (or `rails db:setup` for a fresh database).
4. **Validate idempotency** — run `rails db:seed` a second time and confirm no duplicates or errors.
5. **Verify data** — open `rails console` and spot-check expected records exist with correct attributes.

See [references/workflow.md](references/workflow.md) for the complete seeding workflow.

## Idempotent Seeds

```ruby
# db/seeds.rb
admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password'
  u.admin = true
end
```

## Environment-Specific Seeds

```ruby
# db/seeds.rb
if Rails.env.development?
  require Rails.root.join('db/seeds/development')
elsif Rails.env.test?
  require Rails.root.join('db/seeds/test')
end

# db/seeds/development.rb
10.times do
  User.find_or_create_by!(email: Faker::Internet.unique.email) do |u|
    u.password = 'password'
  end
end
```

## FactoryBot Factory Example

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password' }

    trait :admin do
      admin { true }
    end
  end
end

# Usage in specs
create(:user, :admin)
```

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete examples including:
- Environment-specific seed structure
- FactoryBot factories with traits
- Idempotent seed patterns
- Troubleshooting common issues

## External References

- [FactoryBot documentation](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md)
- [Faker gem](https://github.com/faker-ruby/faker)
- [Rails Seeding Guide](https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data)
