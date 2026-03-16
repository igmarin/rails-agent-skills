---
name: ruby-api-client-integration
description: >
  Use when integrating with external APIs, creating HTTP clients, building data pipelines
  from external services, or adding new API consumers. Covers the layered Auth, Client,
  Fetcher, Builder, and Domain Entity pattern with token caching, retry logic, pagination,
  and FactoryBot hash factories for test data.
---

# Ruby API Client Integration

Follow **ruby-service-objects** for shared conventions (YARD, constants, response format, `app/services/` layout). This skill adds the layered Auth -> Client -> Fetcher -> Builder -> Domain Entity pattern for external APIs.

## HARD-GATE: Tests Gate Implementation

```
EVERY layer (Auth, Client, Fetcher, Builder, Entity) MUST have its test
written and validated BEFORE implementation.
  1. Write the spec for the layer (instance_double for unit, hash factories for API responses)
  2. Run the spec — verify it fails because the layer does not exist yet
  3. ONLY THEN write the layer implementation
  4. Repeat for each layer in order: Auth → Client → Fetcher → Builder → Entity
See rspec-best-practices for the full gate cycle.
```

## Quick Reference

| Layer | Responsibility | File |
|-------|---------------|------|
| **Auth** | OAuth/token management, caching | `auth.rb` |
| **Client** | HTTP requests, response parsing, error wrapping | `client.rb` |
| **Fetcher** | Query orchestration, polling, pagination | `fetcher.rb` |
| **Builder** | Response -> structured data transformation | `builder.rb` |
| **Domain Entity** | Domain-specific config, query definitions | `entity.rb` |

## Architecture

```
Auth → Client → Fetcher → Builder → Domain Entity
```

## Layer Details

### 1. Auth (`auth.rb`)

Handles authentication. Caches tokens. Provides `self.default` from env vars.

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
      raise 'Missing required credentials' if [client_id, client_secret, account_id].any?(&:blank?)
      @token = nil
    end

    def token
      return @token if @token
      # fetch and cache token
    end
  end
end
```

### 2. Client (`client.rb`)

Wraps HTTP calls. Validates inputs. Parses responses. Raises `Client::Error`.

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
      host = Rails.configuration.secrets[:service_host]
      new(token:, host:)
    end

    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)
    end

    def execute_query(payload)
      # POST, parse JSON, raise on failure
    rescue JSON::ParserError, HTTParty::Error => e
      raise Error, "Request failed: #{e.message}"
    end
  end
end
```

### 3. Fetcher (`fetcher.rb`)

Orchestrates query execution. Handles polling and pagination.

```ruby
module ServiceName
  class Fetcher
    MAX_RETRIES = 3
    RETRY_DELAY_IN_SECONDS = 2

    def initialize(client, data_builder:, default_query:)
      @client = client
      @data_builder = data_builder
      @default_query = default_query
    end

    def execute_query(query = @default_query)
      raw_response = @client.execute_query(query)
      @data_builder.build(complete_response)
    end
    alias query execute_query
  end
end
```

Key patterns: constructor DI, delegates HTTP to Client, delegates transformation to Builder, retries with exponential backoff.

### 4. Builder (`builder.rb`)

Transforms raw API response into attribute-filtered hashes.

```ruby
module ServiceName
  class Builder
    def initialize(attributes:)
      @attributes = attributes
    end

    def build(response)
      schema = response['manifest']['schema']['columns']
      data_array = response['result']['data_array'] || []
      data_array.map { |row| build_hash(schema, row).slice(*@attributes) }
    end
  end
end
```

### 5. Domain Entity (e.g., `animal.rb`)

Defines domain-specific constants and wires up the layers.

```ruby
module ServiceName
  class Animal
    ATTRIBUTES = %w[tag_number name species_id shelter_id].freeze
    DEFAULT_QUERY = 'SELECT * FROM schema.animals;'
    SEARCH_QUERY = 'SELECT * FROM schema.animals WHERE tag_number = ?;'

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

## Adding a New Domain Entity

1. Define `ATTRIBUTES`, `DEFAULT_QUERY`, and optionally `SEARCH_QUERY` constants
2. Implement `.fetcher` class method wiring `Builder` and `Fetcher`
3. Add `.find` or `.search` class methods with `sanitize_sql`
4. Create a FactoryBot hash factory in `spec/factories/module_name/`
5. Write spec in `spec/services/module_name/` covering `.fetcher`, `.find`/`.search`

## Checklist for New API Integration

- [ ] Create module directory under `app/services/`
- [ ] Implement `Auth` with `self.default` and token caching
- [ ] Implement `Client` with `self.default`, `Error` class, and error wrapping
- [ ] Implement `Fetcher` with polling/pagination if needed
- [ ] Implement `Builder` with attribute filtering
- [ ] Create domain entities with constants and `.fetcher`
- [ ] Add `README.md` with usage examples and error handling docs
- [ ] Write comprehensive specs for all layers
- [ ] Create FactoryBot hash factories for API responses

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Skipping the Auth layer | Token management scattered across services. Centralize in Auth. |
| Client without `Error` class | Callers can't distinguish API errors from other exceptions |
| No retry logic in Fetcher | Transient failures kill the pipeline. Add exponential backoff. |
| Builder that returns all fields | Whitelist with ATTRIBUTES. Don't leak internal API structure. |
| Hardcoded credentials | Use `self.default` from encrypted credentials, never hardcode |
| No FactoryBot hash factories | Tests become brittle fixtures. Use factories for API responses. |

## Red Flags

- Credentials or tokens hardcoded or committed to git
- HTTP calls without timeout configuration
- No error wrapping — raw HTTParty exceptions bubble up
- Builder that doesn't filter attributes (leaks full API response)
- Missing specs for error scenarios (network failure, invalid JSON, 4xx/5xx)
- Fetcher without pagination support when API returns paginated results

## Integration

| Skill | When to chain |
|-------|---------------|
| **ruby-service-objects** | Base conventions (.call, responses, transactions, README) |
| **rspec-service-testing** | For testing all layers with instance_double and hash factories |
| **rspec-best-practices** | For general RSpec structure |
| **rails-security-review** | When auditing credential handling and input validation |
