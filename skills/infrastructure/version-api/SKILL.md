---
name: version-api
license: MIT
description: >
  Use when implementing REST API versioning strategies in Rails — must maintain backward compatibility by inheriting new version controllers from the previous version's controller overriding only changed actions, and run compatibility specs via bundle exec rspec spec/requests/api/backward_compatibility_spec.rb to confirm no regressions before merging. REST API versioning, URL path versioning, Deprecation headers.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Version API

Implement versioning strategies for Rails APIs.

## Quick Reference

| Concern | File |
|---|---|
| Route namespaces | `config/routes.rb` |
| Header versioning | `app/controllers/concerns/api_versioning.rb` |
| Deprecation headers | `app/controllers/concerns/deprecatable.rb` |
| Compatibility specs | `spec/requests/api/backward_compatibility_spec.rb` |

## HARD-GATE

```text
ALWAYS maintain backward compatibility for at least one major version
NEVER remove endpoints without deprecation period
ALWAYS version in URL path (/api/v1/) or Accept header, never in body
```

## Core Process

1. **Choose strategy** — URL path (`/api/v1/`) for public APIs; Accept header for internal/private APIs. See [strategies.md](./references/strategies.md) for header-based versioning details and trade-offs.
2. **Add route namespace** — Wrap new version resources in a `namespace :v2` block in `config/routes.rb`:
   ```ruby
   namespace :v1 do
     resources :users
   end

   namespace :v2 do
     resources :users
   end
   ```
3. **Create controllers** — Inherit from the previous version's controller and override only changed actions:
   ```ruby
   module V2
     class UsersController < V1::UsersController
       def index
         render json: User.all, only: [:id, :name, :email, :phone]
       end
     end
   end
   ```
   See [EXAMPLES.md](./EXAMPLES.md) for additional inheritance patterns.
4. **Apply deprecation** — Include `Deprecatable` in old-version controllers to emit `Sunset` and `Deprecation` response headers automatically via a `before_action`:
   ```ruby
   module V1
     class UsersController < ApplicationController
       include Deprecatable
       # Override sunset_date on the class to set the retirement date:
       # def self.sunset_date = Date.new(2025, 6, 1)
     end
   end
   ```
5. **Run compatibility specs** — Execute `bundle exec rspec spec/requests/api/backward_compatibility_spec.rb` to confirm no regressions before merging.
6. **Update documentation** — Record the sunset date and migration guide for deprecated endpoints. See [workflow.md](./references/workflow.md) for the full deprecation communication workflow.

## Output Style

1. Define versioning strategy explicitly.
2. Document inheritance strategy.
3. Show route definition and deprecation headers.
4. Include compatibility specs to prevent breakage.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-api-collection** | When generating the updated API endpoints |
| **test-engine** | When verifying specs for regressions |
