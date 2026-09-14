# Seeding Workflow

Step-by-step process for setting up seed data.

## New Development Environment

### Step 1: Migrate Database

```bash
rails db:create db:migrate
```

### Step 2: Run Seeds

```bash
rails db:seed
```

### Step 3: Verify in Console

```ruby
rails console

User.count    # Expect > 0
Post.count    # Expect > 0
```

### Step 4: Handle Failures

If seeds fail:

1. Check logs: `tail -f log/development.log`
2. Fix validation errors
3. Re-run: `rails db:seed` (idempotent - safe to repeat)
4. For stuck state: `rails db:reset`

## Adding New Seed Data

1. Add to `db/seeds.rb` using `find_or_create_by!`
2. Test locally: `rails db:seed`
3. For large datasets, use `db/seeds/development.rb`
4. Document in README if non-standard

## Production Seeds

⚠️ **Never run development seeds in production**

```bash
# Only run base seeds in production
RAILS_ENV=production rails db:seed
```

Production seeds should only contain:
- Essential reference data
- First admin user (if needed)
- System configurations
