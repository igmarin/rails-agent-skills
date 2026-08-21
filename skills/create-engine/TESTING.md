# Create Engine — Testing Guide

Testing strategies for Rails engines.

## Testing Philosophy

Engine testing requires two layers:
1. **Isolated unit tests** — Test individual classes in isolation
2. **Integration tests through dummy app** — Test the engine mounted in a real Rails app context

The dummy app is essential—it verifies routing, initialization, configuration, and host integration work correctly.

## Dummy App Setup

The dummy app is created automatically with `rails plugin new`. Ensure it has:

```text
spec/dummy/
  app/
    controllers/
    models/
    views/
  config/
    routes.rb      # Mount the engine
    application.rb # Minimal Rails config
  db/
    schema.rb
  config.ru
```

### Required Dummy App Configuration

```ruby
# spec/dummy/config/routes.rb
Rails.application.routes.draw do
  mount YourEngine::Engine => "/your_engine"
end

# spec/dummy/config/application.rb
require_relative 'boot'

require 'rails/all'

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load = false
  end
end
```

## Test Types

### 1. Configuration Tests

Verify the engine configuration system works:

```ruby
# spec/lib/your_engine/configuration_spec.rb
require 'rails_helper'

RSpec.describe YourEngine::Configuration do
  describe 'defaults' do
    it 'has sensible defaults' do
      config = described_class.new
      expect(config.user_class).to eq('User')
      expect(config.enabled).to be true
    end
  end

  describe 'configuration block' do
    it 'allows configuration via block' do
      YourEngine.configure do |config|
        config.user_class = 'Admin'
      end

      expect(YourEngine.configuration.user_class).to eq('Admin')
    end
  end
end
```

### 2. Request/Integration Tests

Test endpoints through the mounted engine:

```ruby
# spec/requests/your_engine/widgets_spec.rb
require 'rails_helper'

RSpec.describe "Widgets", type: :request do
  describe "GET /your_engine/widgets" do
    it 'returns widgets' do
      create_list(:widget, 3)

      get your_engine.widgets_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Widgets')
    end
  end
end
```

### 3. Routing Tests

```ruby
# spec/routing/your_engine/routes_spec.rb
require 'rails_helper'

RSpec.describe "Engine routing", type: :routing do
  it 'routes to engine' do
    expect(get: '/your_engine/widgets').to route_to(
      controller: 'your_engine/widgets',
      action: 'index'
    )
  end
end
```

### 4. Generator Tests

If your engine provides generators:

```ruby
# spec/lib/generators/your_engine/install_generator_spec.rb
require 'spec_helper'
require 'generator_spec'

describe YourEngine::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)

  before do
    prepare_destination
    run_generator
  end

  it 'creates initializer' do
    expect(destination_root).to have_structure {
      directory 'config/initializers' do
        file 'your_engine.rb' do
          contains 'YourEngine.configure'
        end
      end
    }
  end
end
```

### 5. Integration with Host Models

Test that configurable class references work:

```ruby
# spec/lib/your_engine/host_integration_spec.rb
require 'rails_helper'

RSpec.describe "Host Integration" do
  before do
    YourEngine.configure do |config|
      config.user_class = 'CustomUser'
    end

    # Create test model in dummy app
    stub_const('CustomUser', Class.new(ActiveRecord::Base))
  end

  it 'uses configured user class' do
    user = CustomUser.create!(email: 'test@example.com')

    # Engine code that references the configurable class
    result = YourEngine::UserFinder.find(user.id)

    expect(result).to eq(user)
  end
end
```

## Testing Checklist

Before releasing an engine, verify:

- [ ] `bundle exec rspec` passes in engine directory
- [ ] `cd spec/dummy && bundle exec rails routes` shows engine routes
- [ ] Configuration can be changed via initializer
- [ ] No hard-coded host app constants (run: `grep -r "::User\|::Account" lib/`)
- [ ] No migration auto-apply in initializers
- [ ] Generators (if any) are tested
- [ ] Integration tests exercise mounted routes

## Common Testing Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Routes not found | Engine not mounted in dummy app | Add `mount` to `spec/dummy/config/routes.rb` |
| Models not loading | Namespacing issue | Use `isolate_namespace` or fully qualified names |
| Config not applied | Loading order | Set config in initializer, not in class definition |
| Tests pass in isolation but fail together | Database state | Use `DatabaseCleaner` or transactional fixtures |

## CI Configuration

```yaml
# .github/workflows/engine-ci.yml
name: Engine CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
      - uses: ruby/setup-ruby@c4e5b1316158f92e3d49443a9d58b31d25ac0f8f
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Run tests
        run: bundle exec rspec

      - name: Verify dummy app
        run: |
          cd spec/dummy
          bundle exec rails routes
```
