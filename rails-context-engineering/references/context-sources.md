# Rails Context Sources — Exact Commands

Progressive-disclosure reference. Read this only when the Context Summary calls for a specific layer that the main SKILL.md has not already clarified.

## Principle

Read the minimum that answers the question. Never load a whole app. Every read below targets a single layer.

## Baseline reads — always, once per task

```text
Read   Gemfile.lock                    → identify Rails version + domain gems
Read   config/application.rb           → app config, autoload paths, engines mounted
Read   config/routes.rb                → narrow with offset/grep to the resource in scope
Read   db/schema.rb                    → narrow with Grep by table name
```

For large `schema.rb` files, prefer:
```text
Grep   "create_table \"<table_name>\"" --glob "db/schema.rb" --context 40
```

For routes, prefer:
```text
Grep   "resources :<resource>|resource :<resource>|namespace :<ns>" --glob "config/routes.rb" --context 5
```

## Per-layer reads

### Controller changes

```text
Glob   app/controllers/**/<area>*_controller.rb
Read   <nearest controller>            → read the whole file if ≤300 lines; else offset to the action in scope
Glob   spec/requests/**/<area>*_spec.rb OR spec/controllers/**/<area>*_spec.rb
Read   <nearest request spec>
```

Look for: `before_action` chains, authorization pattern (Pundit, CanCan, custom), param filtering, JSON response shape, strong_params structure.

### Model changes

```text
Read   db/schema.rb                    → grep table
Glob   app/models/<model>.rb
Read   app/models/<model>.rb
Glob   spec/models/<model>_spec.rb
Read   spec/models/<model>_spec.rb
Glob   spec/factories/<model>_factory.rb OR spec/factories/<plural>.rb
Read   the factory
```

Look for: `has_many`/`belongs_to` options (`dependent:`, `inverse_of:`, `counter_cache:`), validations, scopes, enums, `acts_as_*`, soft-delete, STI (`type` column).

### Service changes

```text
Glob   app/services/**/*.rb
Grep   "class .*Service|def self\.call|def call" in app/services → pick nearest match
Read   <nearest service>
Glob   spec/services/**/*_spec.rb → pick the matching one
Read   <nearest service spec>
```

Look for: return-shape convention (`{ success:, response: }` vs `Result.success/failure` vs raising), constructor shape, whether service calls another service (graph depth), feature flags, Sidekiq involvement.

### Job changes

```text
Glob   app/jobs/**/*.rb
Read   <nearest job>
Glob   spec/jobs/**/*_spec.rb
Read   <nearest job spec>
Grep   "retry_on|discard_on|queue_as" in app/jobs → confirm project convention
```

Look for: `retry_on` exceptions list, `discard_on ActiveRecord::RecordNotFound`, queue names, `perform_later` call sites, idempotency guards.

### Engine changes

```text
Glob   engines/*/lib/*/engine.rb        → find the engine
Read   <engine>/lib/<name>/engine.rb
Read   <engine>/config/routes.rb
Glob   <engine>/spec/dummy/config/routes.rb
Read   <engine>/spec/rails_helper.rb
Grep   "mount .*::Engine" in config/routes.rb → find host integration
```

Look for: isolate_namespace, host app integration, initializers, generators, mount point.

### Migration changes

```text
Read   db/schema.rb                    → current state
Glob   db/migrate/*.rb                  → list to confirm latest timestamp
Grep   "add_column.*<table>|change_column.*<table>" in db/migrate → find prior migrations on the table
```

Look for: concurrent index patterns (strong_migrations), backfill patterns, reversible blocks.

### View / Turbo / Stimulus changes

```text
Glob   app/views/<area>/**/*.erb OR app/views/<area>/**/*.html.erb
Read   <nearest view>
Glob   app/javascript/controllers/**/<area>*_controller.js
Read   <nearest Stimulus controller>
Grep   "turbo_stream|turbo_frame" in app/views/<area>
```

Look for: partial naming, local vs instance variables, Turbo stream naming, Stimulus data-controller names, Tailwind class patterns.

### GraphQL changes

```text
Glob   app/graphql/types/**/*.rb
Read   <nearest type>
Glob   app/graphql/mutations/**/*.rb
Read   <nearest mutation>
Read   app/graphql/<app>_schema.rb
Grep   "def resolve|argument :|field :" in app/graphql
```

Look for: dataloader usage, authorization in resolvers, field-level permissions, input object conventions.

## Size budget

Aim for **≤1500 tokens** of loaded context per task. If you are over budget, you are reading too broadly — pick the single nearest neighbor per layer, not three.

## When nothing exists yet

If the layer has no existing example (brand new service, first job, first engine), say so explicitly in the Context Summary:

```text
- Nearest pattern: NONE (first <layer> in this repo) — fall back to skill: <rails-stack-conventions | ruby-service-objects | rails-background-jobs | rails-engine-author>
```

Never fabricate a "standard pattern" — defer to the relevant skill.
