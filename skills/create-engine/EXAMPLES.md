# Create Engine — Examples

Extended examples and patterns for engine creation.

## Example 1: Mountable Authentication Engine

**Scenario:** Build an engine that provides authentication (login/logout) to host apps.

### Step 1: Scaffold

```bash
rails plugin new auth_engine --mountable --full
```

### Step 2: Define Host App Contract

| Aspect | Requirement |
|--------|-------------|
| **Host must provide** | User model with `email` and `password_digest` attributes; mount route in host routes |
| **Engine exposes** | SessionsController, AuthenticationHelper, require_login before_action |
| **Configuration** | `user_class` (default: "User"), `session_key` (default: :user_id) |

### Step 3: Implementation Structure

```ruby
# lib/auth_engine.rb
require "auth_engine/version"
require "auth_engine/configuration"
require "auth_engine/engine"

module AuthEngine
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

# lib/auth_engine/configuration.rb
module AuthEngine
  class Configuration
    attr_accessor :user_class, :session_key

    def initialize
      @user_class = "User"
      @session_key = :user_id
    end
  end
end

# lib/auth_engine/engine.rb
module AuthEngine
  class Engine < ::Rails::Engine
    isolate_namespace AuthEngine

    initializer "auth_engine.controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include AuthEngine::AuthenticationHelper
      end
    end
  end
end
```

### Step 4: Controller Using Configurable User Class

```ruby
# app/controllers/auth_engine/sessions_controller.rb
module AuthEngine
  class SessionsController < ApplicationController
    def create
      user = AuthEngine.configuration.user_class.constantize.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        session[AuthEngine.configuration.session_key] = user.id
        redirect_to main_app.root_path
      else
        flash.now[:alert] = "Invalid credentials"
        render :new
      end
    end

    def destroy
      session.delete(AuthEngine.configuration.session_key)
      redirect_to main_app.root_path
    end
  end
end
```

### Step 5: Dummy App Setup

```ruby
# spec/dummy/config/routes.rb
Rails.application.routes.draw do
  mount AuthEngine::Engine => "/auth"
end

# spec/dummy/app/models/user.rb
class User < ApplicationRecord
  has_secure_password
end
```

## Example 2: Non-Mountable Background Job Engine

**Scenario:** Engine that provides shared background job processing capabilities.

```bash
rails plugin new job_engine --full
```

Key difference: No routes, no isolate_namespace, but needs Rails initialization hooks.

```ruby
# lib/job_engine/engine.rb
module JobEngine
  class Engine < ::Rails::Engine
    # No isolate_namespace - jobs live in host app namespace

    initializer "job_engine.configure_queue_adapter" do |app|
      app.config.active_job.queue_adapter = :solid_queue if defined?(SolidQueue)
    end
  end
end
```

## Common Mistakes to Avoid

| Mistake | Why It Fails | Correct Approach |
|---------|--------------|------------------|
| `class User < ::User` | Hard-coded host dependency | `config.user_class = "User"` then constantize |
| Auto-running migrations in initializer | Database errors on boot | Use generators for migrations, never auto-apply |
| Polluting host app routes | Namespace collision | Use `isolate_namespace` for mountable engines |
| No dummy app | Can't test integration | Always create dummy app with `rails plugin new` |
| Config as hash | No validation, hard to document | Config class with explicit attributes |

## Testing Checklist

See [TESTING.md](TESTING.md) for detailed testing patterns.

Quick verification:

```bash
# Inside engine directory
cd spec/dummy
bundle exec rails routes | grep engine_name  # Verify routes
bundle exec rspec spec/requests               # Integration tests
bundle exec rspec spec/lib/configuration_spec # Config tests
grep -r "::User\|::Account" ../lib          # No hard-coded constants
```
