# Layer Reference: Auth → Client → Fetcher → Builder → Entity

Full implementation templates for each layer. Adapt to the specific API's auth scheme, endpoint shape, and response format.

## 1. Auth (`auth.rb`)

Manages credentials and caches the bearer token for the session lifetime.

```ruby
module ServiceName
  class Auth
    include HTTParty

    DEFAULT_TIMEOUT = 30

    def self.default
      new(
        client_id: Rails.configuration.secrets[:service_client_id],
        client_secret: Rails.configuration.secrets[:service_client_secret],
        account_id: Rails.configuration.secrets[:service_account_id]
      )
    end

    def initialize(client_id:, client_secret:, account_id:, timeout: DEFAULT_TIMEOUT)
      raise ArgumentError, 'Missing required credentials' if [client_id, client_secret, account_id].any?(&:blank?)
      @client_id     = client_id
      @client_secret = client_secret
      @account_id    = account_id
      @timeout       = timeout
      @token         = nil
    end

    def token
      return @token if @token

      response = self.class.post('/oauth/token',
        body: { grant_type: 'client_credentials', client_id: @client_id, client_secret: @client_secret },
        timeout: @timeout
      )
      raise Error, "Auth failed: #{response.code}" unless response.success?

      @token = response.parsed_response['access_token']
    end
  end
end
```

## 2. Client (`client.rb`)

Wraps HTTP calls. Validates inputs. Parses responses. Raises `Client::Error` on failure.

```ruby
module ServiceName
  class Client
    include HTTParty

    MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
    DEFAULT_TIMEOUT = 30
    DEFAULT_RETRIES = 3

    class Error < StandardError; end

    def self.default
      token = Auth.default.token
      host  = Rails.configuration.secrets[:service_host]
      new(token:, host:)
    end

    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)
      @token       = token
      @host        = host
      @timeout     = timeout
      @max_retries = max_retries
    end

    def execute_query(payload)
      response = self.class.post("#{@host}/api/query",
        headers: { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' },
        body:    payload.to_json,
        timeout: @timeout
      )
      raise Error, "API error: HTTP #{response.code}" unless response.success?

      JSON.parse(response.body)
    rescue JSON::ParserError, HTTParty::Error => e
      raise Error, "Request failed: #{e.class}"
    end
  end
end
```

## 3. Fetcher (`fetcher.rb`)

Orchestrates query execution. Handles polling and pagination. Uses constructor DI for testability.

```ruby
module ServiceName
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

## 4. Builder (`builder.rb`)

Transforms raw API response into attribute-filtered hashes. Always whitelist with `ATTRIBUTES`.

```ruby
module ServiceName
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

## 5a. Spec: Client error paths (`spec/services/service_name/client_spec.rb`)

Write at minimum one test per error scenario before implementing the Client layer.

```ruby
RSpec.describe ServiceName::Client do
  let(:token) { 'tok' }
  let(:host)  { 'https://api.example.com' }

  subject(:client) { described_class.new(token:, host:) }

  describe '#execute_query' do
    context 'when the response body is not valid JSON' do
      before { stub_request(:post, "#{host}/api/query").to_return(body: 'not-json', status: 200) }

      it 'raises Client::Error' do
        expect { client.execute_query('SELECT 1') }.to raise_error(ServiceName::Client::Error)
      end
    end

    context 'when a network failure occurs' do
      before { stub_request(:post, "#{host}/api/query").to_raise(HTTParty::Error) }

      it 'raises Client::Error' do
        expect { client.execute_query('SELECT 1') }.to raise_error(ServiceName::Client::Error)
      end
    end
  end

  describe '.new' do
    context 'when token is blank' do
      it 'raises Client::Error with the missing configuration message' do
        expect { described_class.new(token: '', host:) }
          .to raise_error(ServiceName::Client::Error, ServiceName::Client::MISSING_CONFIGURATION_ERROR)
      end
    end
  end
end
```

## 5b. Domain Entity (e.g., `animal.rb`)

Defines domain constants and wires up the layers. SQL queries use `sanitize_sql` to prevent injection.

```ruby
module ServiceName
  class Animal
    ATTRIBUTES    = %w[tag_number name species_id shelter_id].freeze
    DEFAULT_QUERY = 'SELECT * FROM schema.animals;'
    SEARCH_QUERY  = 'SELECT * FROM schema.animals WHERE tag_number = ?;'

    def self.fetcher(client: Client.default)
      data_builder = Builder.new(attributes: ATTRIBUTES)
      Fetcher.new(client, data_builder:, default_query: DEFAULT_QUERY)
    end

    def self.find(tag_number:)
      query = ActiveRecord::Base.sanitize_sql([SEARCH_QUERY, tag_number])
      fetcher.execute_query(query)
    end
  end
end
```

## 6. FactoryBot hash factory (`spec/factories/service_name/entity_response.rb`)

Hash factories are **not** model factories. Place them under `spec/factories/<module_name>/` and use `skip_create` + `initialize_with` to return a plain hash instead of an ActiveRecord object.

```ruby
# spec/factories/shelter_api/animal_response.rb
FactoryBot.define do
  factory :shelter_api_animal_response, class: Hash do
    skip_create

    sequence(:tag_number) { |n| "TAG-#{n}" }
    name       { 'Buddy' }
    species_id { 1 }
    shelter_id { 42 }
    intake_date { '2024-01-15' }
    extra_field { 'should be filtered by Builder' }

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

Use in specs: `build(:shelter_api_animal_response)` returns the API-shaped hash; `build(:shelter_api_animal_response, name: 'Rex')` overrides fields.
