---
name: rails-engine-author
description: >
  Use when creating, scaffolding, or refactoring a Rails engine. Covers engine
  types (Plain, Railtie, Engine, Mountable), namespace isolation, host-app
  contract definition, and recommended file structure.
---
# Rails Engine Author

Use this skill when the task is to create, scaffold, or refactor a Rails engine.

Favor maintainability over cleverness. A good engine has a narrow purpose, a clear host-app integration story, and a small public API.

Keep this skill focused on structure and design. Use adjacent skills for installer details, deep test coverage, release workflow, or documentation work.

## Quick Reference

| Engine Type | When to Use |
|-------------|-------------|
| Plain gem | No Rails hooks or app directories needed; pure Ruby library |
| Railtie | Needs Rails initialization hooks but not models/controllers/routes/views |
| Engine | Needs Rails autoload paths, initializers, migrations, assets, jobs, or host integration |
| Mountable engine | Needs its own routes, controllers, views, assets, and namespace boundary |

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Starting with mountable when plain gem suffices | Use the lightest option — mountable adds routes, controllers, views only when needed |
| Missing `isolate_namespace` | Mountable and public-facing engines must isolate to avoid constant collisions with host |
| No host contract defined | Without a documented contract, integration becomes guesswork across host apps |
| Engine depends on host internals | Reference host models through configurable class names or adapters |
| No dummy app | Integration must be verified through a real mounted engine, not isolated classes |

## Workflow

1. Identify the engine type before writing code. Scaffold with the correct generator:
   ```bash
   rails plugin new my_engine --mountable   # mountable engine
   rails plugin new my_engine --full        # full engine (non-isolated)
   rails plugin new my_engine               # plain Railtie/gem
   ```
2. Define the host-app contract (what host must provide; what engine exposes).
3. Create the minimal engine structure. **Checkpoint:** `bundle exec rake` inside the engine must pass.
4. Implement features behind the namespace. **Checkpoint:** mount engine in dummy app routes and verify with `bundle exec rails routes`.
5. Plan and write minimum integration coverage through the dummy app.
6. Document the host-app contract clearly enough for follow-on work.

If the user does not specify the engine type, infer it from the requested behavior and say which type you chose.

## Recommended Structure

Use a structure close to this:

```text
my_engine/
  lib/
    my_engine.rb
    my_engine/version.rb
    my_engine/engine.rb
    generators/
  app/
    controllers/
    models/
    jobs/
    views/
  config/
    routes.rb
    locales/
  db/
    migrate/
  spec/ or test/
    dummy/
```

Keep the root module small:

- `lib/my_engine.rb`: requires version, engine, and public configuration entrypoints.
- `lib/my_engine/engine.rb`: engine class, initializers, autoload/eager-load behavior, asset/config hooks.
- `lib/my_engine/version.rb`: version only.

## Host App Contract

Before implementation, define:

- What the host app must add: mount route, initializer, migrations, credentials, background jobs, or assets.
- What the engine exposes: models, controllers, helpers, configuration, rake tasks, generators, middleware, or events.
- Which extension points are supported: config block, adapter interface, callbacks, or service objects.

Prefer one explicit configuration surface, for example:

```ruby
MyEngine.configure do |config|
  config.user_class = "User"
  config.audit_events = true
end
```

Do not scatter configuration across unrelated constants and initializers.

## Implementation Rules

- Use `isolate_namespace` for mountable and public-facing engines.
- Keep initializers idempotent and safe in development reloads; use `config.to_prepare` only for reload-sensitive code (e.g. decorators).
- Treat migrations as host-owned — provide install/copy generators, never apply silently. Do NOT use `config.paths['db/migrate']` or `ActiveRecord::Migrator` in initializers:

```ruby
# WRONG — auto-applies migrations at boot, host loses control
initializer 'my_engine.migrations' do
  config.paths['db/migrate'] << root.join('db/migrate')
end

# RIGHT — host copies via install generator, runs manually
# See rails-engine-installers for generator patterns
```
- Reference host app models through configurable class names or adapters; do not hard-code host constants.
- Expose integration seams through services, adapters, or hooks — not direct host constants.
- Keep assets and generators namespaced and idempotent.
- Put reusable domain logic in POROs/services, not hooks.

Use `rails-engine-installers` for generator-heavy setup, `rails-engine-testing` for dummy-app coverage, and `rails-engine-reviewer` for audits.

## Testing Expectations

Minimum coverage through the dummy app (not just isolated classes):

- Engine integration tests through the mounted dummy app.
- Routing/request tests for all mountable engine endpoints.
- Configuration tests for each supported host customization option.
- Generator tests when install/setup generators exist.

## Examples

**Minimal mountable engine class:**

```ruby
# lib/my_engine/engine.rb
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end
  end
end
```

**Routes namespaced under engine:**

```ruby
# config/routes.rb
MyEngine::Engine.routes.draw do
  root to: 'dashboard#index'
  resources :widgets, only: %i[index show]
end
```

## Output Style

When asked to create or refactor an engine:

1. State the engine type you are using and why.
2. Show the target file structure.
3. Implement the smallest viable set of files first.
4. Add tests before broadening features.
5. Call out assumptions about the host app explicitly.

## Optional Reference Pattern

If a real-world engine corpus is available, inspect comparable engines before making structural decisions. Prefer matching successful patterns from mature engines over inventing new conventions.

For a reusable starter layout and file stubs, read [reference.md](reference.md).

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-testing | Dummy app setup, integration tests, regression coverage |
| rails-engine-reviewer | Findings-first audits, structural review |
| rails-engine-docs | README, installation guide, host-app contract documentation |
| rails-engine-installers | Generator-heavy setup, install scripts, copy migrations |
| api-rest-collection | When the engine exposes HTTP endpoints (generate/update Postman collection) |
