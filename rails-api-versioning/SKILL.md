---
name: rails-api-versioning
description: >
  Implement REST API versioning strategies in Rails. Covers URL path versioning,
  header-based versioning, deprecation policies, and maintaining backward
  compatibility. Trigger words: API versioning, version, deprecation,
  backward compatibility, v1, v2, API evolution.
license: MIT
---

# Rails API Versioning

Implement versioning strategies for Rails APIs.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md) · [references/strategies.md](./references/strategies.md)

## HARD-GATE

```text
ALWAYS maintain backward compatibility for at least one major version
NEVER remove endpoints without deprecation period
ALWAYS version in URL path (/api/v1/) or Accept header, never in body
```

## Quick Reference

| Concern | File |
|---|---|
| Route namespaces | `config/routes.rb` |
| Header versioning | `app/controllers/concerns/api_versioning.rb` |
| Deprecation headers | `app/controllers/concerns/deprecatable.rb` |
| Compatibility specs | `spec/requests/api/backward_compatibility_spec.rb` |

## Versioning Workflow

1. **Choose strategy** — URL path (`/api/v1/`) for public APIs; Accept header for internal/private APIs.
2. **Add route namespace** — Wrap new version resources in a `namespace :v2` block in `config/routes.rb`.
3. **Create controllers** — Inherit from the previous version's controller and override only changed actions.
4. **Apply deprecation** — Include `Deprecatable` in old-version controllers to emit sunset headers.
5. **Run compatibility specs** — Execute `rspec spec/requests/api/backward_compatibility_spec.rb` to confirm no regressions.
6. **Update documentation** — Record the sunset date and migration guide for deprecated endpoints.

See [references/workflow.md](references/workflow.md) for the complete annotated workflow.

## Strategies

### URL Path Versioning (Recommended)

```ruby
namespace :v1 do
  resources :users
end

namespace :v2 do
  resources :users
end
```

### Controller Inheritance

Override only actions that change between versions:

```ruby
module V2
  class UsersController < V1::UsersController
    def index
      render json: User.all, only: [:id, :name, :email, :phone]
    end
  end
end
```

## Deprecation

Define the `Deprecatable` concern to emit `Sunset` and `Deprecation` response headers:

```ruby
# app/controllers/concerns/deprecatable.rb
module Deprecatable
  extend ActiveSupport::Concern

  included do
    before_action :set_deprecation_headers
  end

  private

  def set_deprecation_headers
    sunset_date = self.class.sunset_date
    response.set_header("Deprecation", "true")
    response.set_header("Sunset", sunset_date.httpdate) if sunset_date
    Rails.logger.warn "[DEPRECATED] #{controller_path}##{action_name} called — sunset: #{sunset_date}"
  end

  class_methods do
    def sunset_date
      nil # Override per controller, e.g.: -> { Date.new(2025, 6, 1) }
    end
  end
end
```

Include it in any controller version due for retirement:

```ruby
module V1
  class UsersController < ApplicationController
    include Deprecatable
    # ...
  end
end
```

## Verification

After adding a new version, always run the backward compatibility suite before merging:

```bash
bundle exec rspec spec/requests/api/backward_compatibility_spec.rb
```

All existing v1 contract tests must remain green; a new version should never silently break prior consumers.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete code including:
- Controller inheritance patterns
- Deprecatable concern with logging
- Backward compatibility specs
- Client request examples

See [references/strategies.md](references/strategies.md) for URL path vs header versioning comparison.
