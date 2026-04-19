# Database Seeding Examples

Complete examples for managing development and test data.

## Idempotent Seeds

```ruby
# db/seeds.rb
# Admin user - idempotent with find_or_create_by!
admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'secure_password'
  u.admin = true
  u.confirmed_at = Time.now
end

# Reference data - using first_or_create for lookup tables
['pending', 'processing', 'completed', 'cancelled'].each do |status|
  OrderStatus.find_or_create_by!(name: status)
end

# Bulk creation with validation
if User.count < 10
  10.times do |n|
    User.create_with(
      password: 'password',
      confirmed_at: Time.now
    ).find_or_create_by!(email: "user#{n}@example.com")
  end
end
```

## Environment-Specific Seeds

### Structure

```
db/
├── seeds.rb           # Base seeds (always runs)
└── seeds/
    ├── development.rb # Dev-specific (100 fake users)
    ├── test.rb        # Test-specific (minimal data)
    └── staging.rb     # Staging-specific
```

### Auto-Loader

```ruby
# db/seeds.rb (bottom of file)
# Load environment-specific seeds
env_seed_file = Rails.root.join("db/seeds/#{Rails.env}.rb")
load env_seed_file if env_seed_file.exist?
```

### Development Seeds

```ruby
# db/seeds/development.rb
puts "Loading development seeds..."

# Load base seeds first
load Rails.root.join('db/seeds.rb')

# Create fake data
require 'faker'

50.times do
  User.create!(
    email: Faker::Internet.unique.email,
    name: Faker::Name.name,
    password: 'password',
    confirmed_at: Time.now
  )
end

# Complex relationships
users = User.limit(10)
users.each do |user|
  5.times do
    Post.create!(
      user: user,
      title: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
      published_at: [nil, Time.now - rand(30).days].sample
    )
  end
end
```

## FactoryBot Examples

### Basic Factory

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    name { 'Test User' }
    confirmed_at { Time.now }

    trait :admin do
      admin { true }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
```

### Factory with Associations

```ruby
# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    body { Faker::Lorem.paragraphs.join("\n\n") }
    user

    trait :published do
      published_at { Time.now }
    end

    trait :draft do
      published_at { nil }
    end

    # Create comments with the post
    after(:create) do |post|
      create_list(:comment, 3, post: post)
    end
  end
end
```

### Using Factories in Seeds

```ruby
# db/seeds/development.rb
# Mix of factories and manual creation
admin = FactoryBot.create(:user, :admin, email: 'admin@example.com')
regular_users = FactoryBot.create_list(:user, 10)

# Create posts for each user
regular_users.each do |user|
  FactoryBot.create_list(:post, 3, :published, user: user)
  FactoryBot.create_list(:post, 2, :draft, user: user)
end
```

## Fixtures vs Factories Decision Guide

| Scenario | Recommendation |
|----------|---------------|
| Static reference data (roles, statuses) | Seeds with `find_or_create_by!` |
| Complex relationships | FactoryBot |
| Performance-critical tests | Fixtures |
| Integration tests | Factories for realism |
| Unit tests | Factories for isolation |

## Troubleshooting

### Reset Database

```bash
# Full reset
rails db:drop db:create db:migrate db:seed

# Quick reset (keep structure)
rails db:seed:replant
```

### Debug Seed Failures

```ruby
# db/seeds.rb
begin
  User.create!(email: 'test@example.com')
rescue ActiveRecord::RecordInvalid => e
  puts "Failed to create user: #{e.message}"
  puts e.record.errors.full_messages
end
```
