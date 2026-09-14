# Engine Configuration

Provide a single initializer file (config/initializers/my_engine.rb) with documented defaults:

MyEngine.configure do |config|
  config.api_key = ENV['MY_ENGINE_API_KEY'] || 'replace_me'
  config.default_limit = 25
  config.feature_flag = false
end

Recommended validation:
- Validate presence of required keys at boot (raise with clear message)
- Log configuration values at debug level (avoid secrets)

Migrations and namespace:
- Prefix table names with engine namespace (e.g., my_engine_users)
- Provide a rake task to copy migrations to host app: `rake my_engine:install:migrations`

Security and secrets:
- Do not store secrets in plain text; prefer host app credentials
- Document what keys the engine expects and their scopes

Public API surface:
- List public classes/modules and configuration entry points in README
- Provide a small section with example usage snippets for host app developers
