# Performance Tools Guide

Detailed configuration and usage of profiling tools.

## Bullet

Detects N+1 queries and unused eager loading.

### Installation

```ruby
# Gemfile
group :development do
  gem 'bullet'
end
```

### Configuration

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true

    # Advanced options
    Bullet.skip_html_injection = false
    Bullet.slack = { webhook_url: 'https://hooks.slack.com/...' }
  end
end
```

### What to Look For

| Alert Type | Meaning | Action |
|------------|---------|--------|
| N+1 Query | Missing `includes` | Add eager loading |
| Unused Eager Loading | Loaded but not used | Remove `includes` |
| Missing `counter_cache` | Counting associations | Add counter cache |

## Rack Mini Profiler

Endpoint timing breakdown.

### Installation

```ruby
# Gemfile
group :development do
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'stackprof'
end
```

### Usage

Visit any page with `?pp=help` to see options:

- `?pp=flamegraph` - Flame graph visualization
- `?pp=profile` - SQL profile
- `?pp=memory` - Memory profile
- `?pp=help` - All options

## EXPLAIN ANALYZE

Query plan analysis.

### Red Flags

| Pattern | Meaning | Fix |
|---------|---------|-----|
| `Seq Scan` on large tables | No index | Add index |
| High `rows` estimate vs actual | Stale stats | Run `ANALYZE` |
| Nested loops on unindexed FK | Missing index | Add index |

### Running EXPLAIN

```ruby
# In Rails console
ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com'")
```
