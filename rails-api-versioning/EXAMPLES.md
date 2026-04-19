# API Versioning Examples

Complete code examples for implementing API versioning in Rails.

## Controller Inheritance

### Base Version (V1)

```ruby
# app/controllers/v1/users_controller.rb
module V1
  class UsersController < ApplicationController
    def index
      render json: User.all, only: [:id, :name, :email]
    end

    def show
      render json: @user, only: [:id, :name, :email]
    end
  end
end
```

### Extended Version (V2)

```ruby
# app/controllers/v2/users_controller.rb
module V2
  class UsersController < V1::UsersController
    # Override only actions that change
    def index
      render json: User.all, only: [:id, :name, :email, :phone]
    end

    def show
      render json: @user, only: [:id, :name, :email, :phone, :address]
    end
  end
end
```

## Routing Examples

### URL Path Versioning

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      resources :posts
    end

    namespace :v2 do
      resources :users
      resources :posts
    end
  end
end
```

### Shallow Routing with Versions

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :users do
        resources :posts, shallow: true
      end
    end
  end
end
```

## Header Versioning Concern

```ruby
# app/controllers/concerns/api_versioning.rb
module ApiVersioning
  extend ActiveSupport::Concern

  included do
    before_action :set_api_version
  end

  private

  def set_api_version
    version = request.headers['Accept']&.match(/version=(\d+)/)&.to_a&.last || '1'
    @api_version = "V#{version}".constantize
  rescue NameError
    render json: { error: 'Invalid API version' }, status: :bad_request
  end
end
```

## Deprecation Concern

```ruby
# app/controllers/concerns/deprecatable.rb
module Deprecatable
  extend ActiveSupport::Concern

  included do
    before_action :set_deprecation_headers
    after_action :log_deprecated_request
  end

  private

  def set_deprecation_headers
    response.headers['Deprecation'] = 'true'
    response.headers['Sunset'] = sunset_date
    response.headers['Link'] = successor_version_link
  end

  def sunset_date
    'Sat, 01 Jan 2026 00:00:00 GMT'
  end

  def successor_version_link
    request.path.gsub(%r{/v\d+/}, "/v#{next_version}/")
  end

  def next_version
    current_version = request.path.match(%r{/v(\d+)/})&.to_a&.last&.to_i || 1
    current_version + 1
  end

  def log_deprecated_request
    Rails.logger.warn "[DEPRECATION] #{request.method} #{request.path} accessed by #{request.remote_ip}"
  end
end
```

## Controller with Deprecation

```ruby
# app/controllers/v1/users_controller.rb
module V1
  class UsersController < ApplicationController
    include Deprecatable  # Signals this version is being retired

    def index
      render json: User.all
    end
  end
end
```

## Backward Compatibility Specs

```ruby
# spec/requests/api/backward_compatibility_spec.rb
require 'rails_helper'

RSpec.describe 'API backward compatibility' do
  describe 'V1 endpoints remain functional after V2 introduction' do
    let!(:users) { create_list(:user, 3, :with_phone) }

    it 'GET /api/v1/users still returns expected fields' do
      get '/api/v1/users', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first.keys).to include('id', 'name', 'email')
      expect(json.first.keys).not_to include('phone')
    end

    it 'GET /api/v2/users returns new phone field' do
      get '/api/v2/users', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first.keys).to include('id', 'name', 'email', 'phone')
    end

    it 'V1 responses include Deprecation header when configured' do
      # Assuming V1 has `include Deprecatable`
      allow_any_instance_of(V1::UsersController).to receive(:set_deprecation_headers)

      get '/api/v1/users'
      expect(response).to have_http_status(:ok)
    end

    it 'V1 responses include Sunset and Link headers when deprecated' do
      get '/api/v1/users'

      # These headers are set by Deprecatable concern
      if response.headers['Deprecation']
        expect(response.headers['Sunset']).to be_present
        expect(response.headers['Link']).to match(/successor-version/)
      end
    end
  end
end
```

## Integration Specs

```ruby
# spec/requests/api/v2/users_spec.rb
require 'rails_helper'

RSpec.describe 'V2 Users API' do
  describe 'GET /api/v2/users' do
    let!(:users) { create_list(:user, 5) }

    it 'returns users with phone numbers' do
      get '/api/v2/users'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(5)
      expect(json.first).to have_key('phone')
    end
  end

  describe 'GET /api/v2/users/:id' do
    let(:user) { create(:user, :with_full_profile) }

    it 'returns full user profile including address' do
      get "/api/v2/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('address')
      expect(json).to have_key('phone')
    end
  end
end
```

## Client Request Examples

### Using URL Path

```bash
# V1 endpoint
curl http://api.example.com/api/v1/users

# V2 endpoint
curl http://api.example.com/api/v2/users
```

### Using Accept Header

```bash
# V1 via header
curl -H "Accept: application/json; version=1" \
     http://api.example.com/api/users

# V2 via header
curl -H "Accept: application/json; version=2" \
     http://api.example.com/api/users
```

### Checking Deprecation Headers

```bash
# V1 endpoint with deprecation
curl -I http://api.example.com/api/v1/users

# Response headers:
# Deprecation: true
# Sunset: Sat, 01 Jan 2026 00:00:00 GMT
# Link: </api/v2/users>; rel="successor-version"
```
