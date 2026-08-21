# Rails Engine Skeleton

Use this as a baseline when the user asks to create a new engine from scratch.

## File Layout

```text
my_engine/
  app/
    controllers/my_engine/application_controller.rb
    models/my_engine/
    services/my_engine/
  config/
    routes.rb
  lib/
    my_engine.rb
    my_engine/version.rb
    my_engine/configuration.rb
    my_engine/engine.rb
  spec/
    dummy/
    lib/
    requests/
    services/
  my_engine.gemspec
```

## Baseline Files

`lib/my_engine.rb`

```ruby
require "my_engine/version"
require "my_engine/configuration"
require "my_engine/engine"

module MyEngine
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
```

`lib/my_engine/configuration.rb`

```ruby
module MyEngine
  class Configuration
    attr_accessor :user_class, :audit_events

    def initialize
      @user_class = "User"
      @audit_events = false
    end
  end
end
```

`lib/my_engine/engine.rb`

```ruby
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    initializer "my_engine.configuration" do
      config.my_engine = MyEngine.configuration
    end

    config.to_prepare do
      # Reload-safe host integration only.
    end
  end
end
```

`config/routes.rb`

```ruby
MyEngine::Engine.routes.draw do
  root to: "home#index"
end
```

`app/controllers/my_engine/application_controller.rb`

```ruby
module MyEngine
  class ApplicationController < ActionController::Base
  end
end
```

## Generator Guidance

If the engine needs host installation steps, prefer generators for:

- copying migrations
- adding initializer config
- seeding permissions or setup data
- creating mount routes when appropriate

Generators should be safe to run more than once.

## Testing Baseline

Start with:

- one configuration spec
- one request or routing spec through the engine
- one dummy-app integration check
- one service spec for a public engine object

## Escalation Rules

Do not introduce these unless the user asks or the problem clearly needs them:

- host app model assumptions hardcoded as constants
- monkey patches
- engine-wide global state beyond a single configuration object
- database writes inside initializers
