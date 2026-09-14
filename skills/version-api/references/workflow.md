# API Versioning Workflow

Step-by-step guide for introducing a new API version.

## Step 1: Create V(N+1) Controllers

Inherit from V(N) controllers and override only changed actions:

```ruby
# app/controllers/v2/users_controller.rb
module V2
  class UsersController < V1::UsersController
    def index
      # New behavior
      render json: User.all, only: [:id, :name, :email, :phone]
    end
  end
end
```

## Step 2: Add Routes

Add V(N+1) namespace to `config/routes.rb`:

```ruby
namespace :api do
  namespace :v1 do
    resources :users
  end

  namespace :v2 do
    resources :users  # New version
  end
end
```

## Step 3: Add Deprecation to V(N)

Include `Deprecatable` concern in V(N) controllers:

```ruby
module V1
  class UsersController < ApplicationController
    include Deprecatable
    # ...
  end
end
```

## Step 4: Run Backward Compatibility Specs

**Only deploy when all V(N) tests pass.**

```bash
bundle exec rspec spec/requests/api/backward_compatibility_spec.rb
```

## Step 5: Mark as Deprecated

1. Update API documentation with deprecation notice
2. Notify API consumers via email/changelog
3. Set sunset date (minimum 6 months recommended)

## Step 6: Remove After Sunset

After the sunset date has passed:

1. Remove V(N) routes from `config/routes.rb`
2. Delete V(N) controller files
3. Remove V(N) specs
4. Update documentation
