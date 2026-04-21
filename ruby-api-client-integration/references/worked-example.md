# Worked Example — `ShelterApi` Integration

This is the canonical, copy-ready integration. Every layer is shown end-to-end. When building a similar integration, rename `ShelterApi`, `Animal`, attributes, queries, and auth endpoint — keep the **shape** identical.

## Directory layout

```
app/services/shelter_api/
├── auth.rb
├── client.rb
├── fetcher.rb
├── builder.rb
├── animal.rb            # Domain entity
└── README.md

spec/services/shelter_api/
├── auth_spec.rb
├── client_spec.rb
├── fetcher_spec.rb
├── builder_spec.rb
└── animal_spec.rb

spec/factories/shelter_api/
└── animal_response.rb   # Hash factory (skip_create + initialize_with)
```

## 1. Auth (`app/services/shelter_api/auth.rb`)

```ruby
# frozen_string_literal: true

module ShelterApi
  class Auth
    include HTTParty

    DEFAULT_TIMEOUT = 30
    class Error < StandardError; end

    def self.default
      new(
        client_id:     Rails.configuration.secrets[:shelter_api_client_id],
        client_secret: Rails.configuration.secrets[:shelter_api_client_secret],
        account_id:    Rails.configuration.secrets[:shelter_api_account_id]
      )
    end

    def initialize(client_id:, client_secret:, account_id:, timeout: DEFAULT_TIMEOUT)
      raise ArgumentError, 'Missing required credentials' if [client_id, client_secret, account_id].any?(&:blank?)
      @client_id, @client_secret, @account_id, @timeout = client_id, client_secret, account_id, timeout
      @token = nil
    end

    def token
      return @token if @token
      response = self.class.post('/oauth/token',
        body: { grant_type: 'client_credentials', client_id: @client_id, client_secret: @client_secret },
        timeout: @timeout)
      raise Error, "Auth failed: #{response.code}" unless response.success?
      @token = response.parsed_response['access_token']
    end
  end
end
```

## 2. Client (`app/services/shelter_api/client.rb`)

```ruby
# frozen_string_literal: true

module ShelterApi
  class Client
    include HTTParty

    MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
    DEFAULT_TIMEOUT = 30
    DEFAULT_RETRIES = 3

    class Error < StandardError; end

    def self.default
      new(token: Auth.default.token, host: Rails.configuration.secrets[:shelter_api_host])
    end

    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)
      @token, @host, @timeout, @max_retries = token, host, timeout, max_retries
    end

    def execute_query(payload)
      response = self.class.post("#{@host}/api/query",
        headers: { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' },
        body:    payload.to_json,
        timeout: @timeout)
      raise Error, "API error: HTTP #{response.code}" unless response.success?
      JSON.parse(response.body)
    rescue JSON::ParserError, HTTParty::Error => e
      raise Error, "Request failed: #{e.class}"
    end
  end
end
```

## 3. Fetcher (`app/services/shelter_api/fetcher.rb`)

```ruby
# frozen_string_literal: true

module ShelterApi
  class Fetcher
    MAX_RETRIES = 3
    RETRY_DELAY_IN_SECONDS = 2

    def initialize(client, data_builder:, default_query:)
      @client        = client
      @data_builder  = data_builder
      @default_query = default_query
    end

    def execute_query(query = @default_query)
      raw_response = @client.execute_query(query)
      @data_builder.build(raw_response)
    end
    alias query execute_query
  end
end
```

## 4. Builder (`app/services/shelter_api/builder.rb`)

Always whitelist via `.slice(*@attributes)`. Coerce hash keys through `String(...)` — never trust API-supplied key types.

```ruby
# frozen_string_literal: true

module ShelterApi
  class Builder
    def initialize(attributes:)
      @attributes = attributes
    end

    def build(response)
      schema     = Array(response.dig('manifest', 'schema', 'columns'))
      data_array = Array(response.dig('result', 'data_array'))
      data_array.map { |row| build_hash(schema, row).slice(*@attributes) }
    end

    private

    def build_hash(schema, row)
      schema.each_with_index.with_object({}) do |(col, idx), hash|
        hash[String(col['name'])] = row[idx]
      end
    end
  end
end
```

## 5. Domain Entity (`app/services/shelter_api/animal.rb`)

Three constants + `self.fetcher` + `sanitize_sql` in every `find`/`search`. Never string-interpolate a bind value into SQL.

```ruby
# frozen_string_literal: true

module ShelterApi
  class Animal
    ATTRIBUTES    = %w[tag_number name species_id shelter_id].freeze
    DEFAULT_QUERY = 'SELECT * FROM schema.animals;'
    SEARCH_QUERY  = 'SELECT * FROM schema.animals WHERE tag_number = ?;'

    def self.fetcher(client: Client.default)
      data_builder = Builder.new(attributes: ATTRIBUTES)
      Fetcher.new(client, data_builder:, default_query: DEFAULT_QUERY)
    end

    def self.all
      fetcher.execute_query
    end

    def self.find(tag_number:)
      query = ActiveRecord::Base.sanitize_sql([SEARCH_QUERY, tag_number])
      fetcher.execute_query(query)
    end
  end
end
```

## 6. FactoryBot hash factory (`spec/factories/shelter_api/animal_response.rb`)

Hash factory (not a model factory). `skip_create` + `initialize_with` produce a plain hash shaped like the API response.

```ruby
# frozen_string_literal: true

FactoryBot.define do
  factory :shelter_api_animal_response, class: Hash do
    skip_create

    sequence(:tag_number) { |n| "TAG-#{n}" }
    name        { 'Buddy' }
    species_id  { 1 }
    shelter_id  { 42 }
    intake_date { '2024-01-15' }
    extra_field { 'should be filtered by Builder via ATTRIBUTES' }

    initialize_with do
      {
        'manifest' => {
          'schema' => {
            'columns' => attributes.keys.map { |k| { 'name' => k.to_s } }
          }
        },
        'result' => {
          'data_array' => [attributes.values]
        }
      }
    end
  end
end
```

Usage: `build(:shelter_api_animal_response)` returns an API-shaped hash; `build(:shelter_api_animal_response, name: 'Rex')` overrides a single field.

## Forbidden shapes

| Shape | Why it fails |
|---|---|
| `Animal.find(tag_number: t)` that interpolates `t` into SQL | Injection — always `sanitize_sql([SEARCH_QUERY, t])` |
| Builder without `initialize(attributes:)` | Downstream code can't whitelist; fails the attribute-filter contract |
| Entity missing `DEFAULT_QUERY` / `SEARCH_QUERY` constants | Queries drift inline and leak into multiple callers |
| Entity `.fetcher` without keyword args `data_builder:` / `default_query:` | Breaks the DI contract — specs can't swap the builder |
| Fetcher constructor with positional builder/query args | Same DI contract break |
| Reading `response.body` or `e.message` into an error message | Leaks untrusted API text — use only `response.code` / `e.class` |

## Contract checklist (self-review before PR)

- [ ] Builder: `def initialize(attributes:)` — keyword arg, required
- [ ] Fetcher: `def initialize(client, data_builder:, default_query:)` — positional + 2 keyword
- [ ] Entity: `ATTRIBUTES` (frozen array), `DEFAULT_QUERY` (string), `SEARCH_QUERY` (string with `?` bind)
- [ ] Entity: `def self.fetcher(client: Client.default)` wires `Builder.new(attributes: ATTRIBUTES)` + `DEFAULT_QUERY`
- [ ] Every `.find` / `.search` uses `ActiveRecord::Base.sanitize_sql([QUERY, bind])`
- [ ] No string interpolation in any SQL anywhere
- [ ] FactoryBot hash factory under `spec/factories/<module>/` with `skip_create` + `initialize_with`
