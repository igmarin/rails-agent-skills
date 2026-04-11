# Rails Engine Compatibility — Examples

## Gemspec Version Bounds

```ruby
# Good: narrow and tested
spec.add_dependency "rails", ">= 7.0", "< 8.0"
spec.required_ruby_version = ">= 3.0"

# Bad: claims support without CI evidence
# spec.add_dependency "rails", ">= 5.2"  # untested on 5.2/6.x
```

## Zeitwerk: File and Constant Must Match

```ruby
# File: lib/my_engine/widget_policy.rb

# ✅ Good: constant matches path
module MyEngine
  class WidgetPolicy
  end
end

# ❌ Bad: will break with Zeitwerk
# class WidgetPolicy  # expected in widget_policy.rb at root — wrong namespace
```

Run `bundle exec rake zeitwerk:check` to detect mismatches before shipping.

## Reload-Safe Hook

```ruby
# In engine.rb
initializer "my_engine.setup" do
  config.to_prepare do
    MyEngine::Decorator.apply  # runs on each reload in development
  end
end
```

Hooks registered outside `config.to_prepare` run only once at boot and will not pick up reloaded code.

## CI Matrix (GitHub Actions)

```yaml
# .github/workflows/ci.yml
strategy:
  matrix:
    ruby: ["3.1", "3.2", "3.3"]
    rails: ["7.0", "7.1", "7.2"]
steps:
  - name: Set Rails version
    run: bundle config set --local gemfile gemfiles/rails_${{ matrix.rails }}.gemfile
  - run: bundle exec rake zeitwerk:check
  - run: bundle exec rspec
```

Each claimed version in `add_dependency` must have a matching row in the matrix.
