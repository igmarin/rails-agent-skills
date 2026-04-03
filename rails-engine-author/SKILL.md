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

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Starting with mountable when plain gem suffices | Use the lightest option; mountable adds routes, controllers, views — only when you need them |
| Missing `isolate_namespace` | Mountable and public-facing engines must isolate to avoid constant collisions with host |
| No host contract defined | Without a documented contract, integration becomes guesswork and breaks across host apps |

## Red Flags

- No namespace isolation for mountable or public engines
- Engine depends on host internals (direct constants, private APIs)
- No dummy app for integration verification

## Workflow

1. Identify the engine type before writing code.
2. Define the host-app contract.
3. Create the minimal engine structure.
4. Implement features behind a namespace.
5. Plan the minimum integration coverage the engine will need.
6. Document the host-app contract clearly enough for follow-on work.

If the user does not specify the engine type, infer it from the requested behavior and say which type you chose.

## Choose The Right Abstraction

Use the lightest option that fits:

- Plain gem: no Rails hooks or app directories needed.
- Railtie: needs Rails initialization hooks but not models/controllers/routes/views.
- Engine: needs Rails autoload paths, initializers, migrations, assets, jobs, or host integration.
- Mountable engine: needs its own routes, controllers, views, assets, and namespace boundary.

Prefer a regular engine for shared framework behavior and a mountable engine for reusable product areas with UI.

## Default Conventions

- Namespace everything under the engine module.
- Use `isolate_namespace` for mountable engines and public-facing engines.
- Keep host-app integration explicit. Prefer generators, configuration, and documented setup over hidden magic.
- Keep initializers idempotent and safe in development reloads.
- Use `config.to_prepare` only for reload-sensitive integration code such as decorators.
- Avoid monkey patches unless the engine's purpose is extension of an existing framework and the patch is explicit, minimal, and tested.
- Put reusable domain logic in POROs/services instead of burying behavior in hooks.
- Treat database migrations as host-owned operational changes. Provide install/copy generators instead of silently applying them.

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

- Keep engine routes inside the engine unless there is a strong reason to inject host routes.
- Reference host app models through configurable class names or adapters when coupling is unavoidable.
- Avoid assuming a specific authentication library, job backend, or asset pipeline unless the engine is intentionally built for one stack.
- Prefer engine-local controllers, helpers, and views over reaching into the host app.
- Expose integration seams through services, adapters, notifications, or hooks instead of direct constants from the host app.
- If the engine ships migrations, make them copyable and re-runnable without surprising side effects.
- If the engine ships assets, keep them namespaced to avoid collisions.
- If the engine exposes generators, make them idempotent.

Use `rails-engine-installers` for generator-heavy setup work, `rails-engine-testing` for dummy-app and regression coverage, and `rails-engine-reviewer` for findings-first audits.

## Testing Expectations

Always include tests that prove the engine works when mounted or loaded by a host app.

Minimum coverage:

- Unit tests for public POROs/services.
- Engine integration tests through a dummy app.
- Routing/request tests for mountable engine endpoints.
- Configuration tests for supported host customization.
- Generator tests for install/setup steps when generators exist.

Use the dummy app to verify real integration, not just isolated classes.

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
