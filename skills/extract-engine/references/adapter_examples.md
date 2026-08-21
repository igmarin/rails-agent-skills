# Adapter examples for host dependencies

This file contains the full adapter example referenced from SKILL.md. Use this as a drop-in reference when extracting slices that need a host-provided dependency (current user, feature flags, host services).

```ruby
# lib/my_engine/configuration.rb
module MyEngine
  class Configuration
    attr_accessor :current_user_provider
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end
end

# In engine: resolve user through config, not hardcoded constant
class OrderCreator
  def initialize(user)
    @user = user
  end

  def self.for_request(request)
    new(MyEngine.config.current_user_provider.call(request))
  end
end

# Host initializer (config/initializers/my_engine.rb)
MyEngine.configure do |config|
  config.current_user_provider = ->(request) { request.env['warden'].user }
end
```

Notes
- Keep the engine code free of host-specific constants; use a tiny, well-documented configuration seam.
- Document the expected callable signature for providers (e.g., ->(request) { ... }).
- Prefer defensive adapters that return nil or raise a clear error if the contract isn't satisfied.
