---
name: ruby-api-client-integration
description: >
  Use when integrating with external APIs in Ruby, creating HTTP clients,
  or building data pipelines. Covers the layered Auth, Client, Fetcher,
  Builder, and Domain Entity pattern with token caching, retry logic, and
  FactoryBot hash factories for test data.
---

# Ruby API Client Integration

Follow **ruby-service-objects** for shared conventions (YARD via **yard-documentation**, constants, response format, `app/services/` layout). This skill adds the layered Auth → Client → Fetcher → Builder → Domain Entity pattern for external APIs.

## HARD-GATE: Tests Gate Implementation

```
EVERY layer (Auth, Client, Fetcher, Builder, Entity) MUST have its test
written and validated BEFORE implementation.
  1. Write the spec (instance_double for unit, hash factories for API responses)
  2. Run the spec — verify it fails because the layer does not exist yet
  3. ONLY THEN write the layer implementation
  4. Repeat in order: Auth → Client → Fetcher → Builder → Entity
```

## Quick Reference

| Layer | Responsibility | File |
|-------|---------------|------|
| **Auth** | OAuth/token management, caching | `auth.rb` |
| **Client** | HTTP requests, response parsing, error wrapping | `client.rb` |
| **Fetcher** | Query orchestration, polling, pagination | `fetcher.rb` |
| **Builder** | Response → structured data transformation | `builder.rb` |
| **Domain Entity** | Domain-specific config, query definitions | `entity.rb` |

See [LAYERS.md](./LAYERS.md) for complete implementation templates for each layer.

## Key Patterns

### Token caching (Auth)

```ruby
def token
  return @token if @token
  response = self.class.post('/oauth/token', body: { grant_type: 'client_credentials',
    client_id: @client_id, client_secret: @client_secret }, timeout: @timeout)
  raise Error, "Auth failed: #{response.code}" unless response.success?
  @token = response.parsed_response['access_token']
end
```

### Error wrapping (Client)

```ruby
def execute_query(payload)
  response = self.class.post("#{@host}/api/query",
    headers: { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' },
    body: payload.to_json, timeout: @timeout)
  raise Error, "API error #{response.code}" unless response.success?
  JSON.parse(response.body)
rescue JSON::ParserError, HTTParty::Error => e
  raise Error, "Request failed: #{e.message}"
end
```

### Domain entity skeleton

```ruby
class Reading
  ATTRIBUTES    = %w[temperature humidity wind_speed region_id recorded_at].freeze
  DEFAULT_QUERY = 'SELECT * FROM schema.readings;'
  SEARCH_QUERY  = 'SELECT * FROM schema.readings WHERE region_id = ?;'

  def self.fetcher(client: Client.default)
    Fetcher.new(client,
      data_builder: Builder.new(attributes: ATTRIBUTES),
      default_query: DEFAULT_QUERY)
  end

  def self.find(region_id:)
    query = ActiveRecord::Base.sanitize_sql([SEARCH_QUERY, region_id])
    fetcher.execute_query(query)
  end
end
```

## Adding a New Domain Entity

1. Define `ATTRIBUTES`, `DEFAULT_QUERY`, and optionally `SEARCH_QUERY` constants
2. Implement `.fetcher` wiring `Builder` and `Fetcher`
3. Add `.find`/`.search` with `sanitize_sql`
4. Create a FactoryBot hash factory in `spec/factories/module_name/`
5. Write spec in `spec/services/module_name/` covering `.fetcher`, `.find`/`.search`

## Checklist for New API Integration

- [ ] `Auth` with `self.default` and token caching
- [ ] `Client` with `self.default`, `Error` class, error wrapping, and timeout
- [ ] `Fetcher` with polling/pagination if needed
- [ ] `Builder` with attribute filtering via `ATTRIBUTES`
- [ ] Domain entities with constants and `.fetcher`
- [ ] `README.md` with usage examples and error handling docs
- [ ] FactoryBot hash factories for API responses
- [ ] Specs for all layers including error scenarios

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Skipping the Auth layer | Token management scattered across services — centralize in Auth |
| Client without `Error` class | Callers cannot distinguish API errors from other exceptions |
| No retry logic in Fetcher | Transient failures kill the pipeline — add exponential backoff |
| Builder returns all fields | Whitelist with `ATTRIBUTES` — do not leak internal API structure |
| Hardcoded credentials | Use `self.default` from encrypted credentials, never hardcode |
| No FactoryBot hash factories | Tests become brittle fixtures — use factories for API responses |
| Missing specs for error scenarios | Network failure, invalid JSON, and 4xx/5xx must all be tested |
| HTTP calls without timeout | Hanging requests block threads — always set `timeout:` in Client |

## Integration

| Skill | When to chain |
|-------|---------------|
| **yard-documentation** | When writing or reviewing inline docs for API client layers |
| **ruby-service-objects** | Base conventions (.call, responses, transactions, README) |
| **rspec-service-testing** | For testing all layers with instance_double and hash factories |
| **rails-security-review** | When auditing credential handling and input validation |
