---
name: ruby-service-objects
description: >
  Use when creating new service classes, adding business logic classes, or refactoring
  code into service objects. Covers the .call pattern, module namespacing, YARD documentation,
  frozen_string_literal, standardized responses, orchestrator delegation, transaction
  wrapping, and error handling conventions for Ruby on Rails.
---

# Ruby Service Objects

## HARD-GATE: Tests Gate Implementation

```
EVERY service object MUST have its test written and validated BEFORE implementation.
  1. Write the spec for .call (with contexts for success, error, edge cases)
  2. Run the spec — verify it fails because the service does not exist yet
  3. ONLY THEN write the service implementation
See rspec-best-practices for the full gate cycle.
```

## Quick Reference

| Convention | Rule |
|-----------|------|
| Entry point | `.call` class method delegating to `new.call` |
| Response format | `{ success: true/false, response: { ... } }` |
| File location | `app/services/module_name/service_name.rb` |
| Pragma | `frozen_string_literal: true` in every file |
| Docs | YARD on every public method |
| Validation | Raise early on invalid input |
| Errors | Rescue, log, return error hash — don't leak exceptions |
| Transactions | Wrap multi-step DB operations |

## Structure

All service objects live under `app/services/` namespaced by module. Use `frozen_string_literal: true` in every file.

```
app/services/
└── module_name/
    ├── README.md
    ├── main_service.rb
    ├── validator.rb
    ├── classifier.rb
    ├── creator.rb
    ├── response_builder.rb
    ├── auth.rb
    ├── client.rb
    ├── fetcher.rb
    └── builder.rb
```

## Core Patterns

### 1. The `.call` Pattern (Orchestrator)

```ruby
module AnimalTransfers
  class TransferService
    attr_reader :source_shelter_id, :target_shelter_id

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @source_shelter_id = params.dig(:source_shelter, :shelter_id)
      @target_shelter_id = params.dig(:target_shelter, :shelter_id)
    end

    def call
      validate_shelters!
      result = process_data
      build_success_response(result)
    rescue ActiveRecord::RecordInvalid => e
      log_error('Validation Error', e)
      build_error_response(e.message, [])
    rescue StandardError => e
      log_error('Processing Error', e, include_backtrace: true)
      build_error_response(e.message, [])
    end
  end
end
```

### 2. Standardized Response Format

```ruby
# Success
{ success: true, response: { successful_items: [...] } }

# Error
{ success: false, response: { error: { message: '...', failed_items: [...] } } }

# Partial success
{
  success: true,
  response: {
    successful_transfers: ['TAG001'],
    error: { message: 'Some animals were not found...', failed_transfers: ['TAG002'] }
  }
}
```

### 3. Orchestrator Pattern

Main service coordinates sub-services, each with a single responsibility:

```ruby
def call
  validate_shelters!
  return empty_response if items.blank?

  classification = Classifier.classify(items, context)
  return all_failed_response(classification) if all_failed?(classification)

  persistence = Creator.create(classification, context)
  ResponseBuilder.success_response(classification, persistence)
rescue StandardError => e
  log_error('Processing Error', e, include_backtrace: true)
  ResponseBuilder.error_response(e.message)
end
```

### 4. Class-only Services (Static Methods)

When no instance state is needed:

```ruby
class ShelterValidator
  def self.validate_source_shelter!(shelter_id)
    shelter = Shelter.find_by(id: shelter_id)
    raise ArgumentError, 'Source shelter not found' unless shelter
    shelter
  end
end
```

### 5. Response Builder Pattern

```ruby
class ResponseBuilder
  def self.success_response(shelter_id, result)
    { success: true, response: build_base_response(shelter_id, result[:items]) }
  end

  def self.error_response(shelter_id, message, failed_items)
    { success: false, response: { shelter: { shelter_id: }, error: { message:, failed_items: } } }
  end
end
```

## Conventions

### Module namespacing

```ruby
# frozen_string_literal: true

module ModuleName
  class ServiceName
  end
end
```

### Constants for configuration

```ruby
MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
DEFAULT_TIMEOUT = 30
```

### Factory methods with `self.default`

```ruby
def self.default
  token = Auth.default.token
  host = Rails.configuration.secrets[:service_host]
  new(token:, host:)
end
```

### YARD documentation

```ruby
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @return [Hash] Result hash with :success flag and :response data
def self.call(params)
```

### Input validation

```ruby
def initialize(token:, host:, warehouse_id:)
  raise Error, MISSING_CONFIGURATION_ERROR if [token, host, warehouse_id].any?(&:blank?)
end
```

### Transaction wrapping

```ruby
def call
  animal = ActiveRecord::Base.transaction do
    animal = create_animal_from_holding_pen
    HoldingPen::AnimalActivator.call(animal:, holding_pen:)
    animal
  end
  Events::Animal.on_create(animal:)
  animal
end
```

### Error logging with context

```ruby
def log_error(context, error, include_backtrace: false)
  Rails.logger.error("#{self.class.name} #{context}: #{error.class} - #{error.message}")
  Rails.logger.error(error.backtrace.join("\n")) if include_backtrace
end
```

### SQL sanitization

```ruby
def self.find(tag_number:)
  query = ActiveRecord::Base.sanitize_sql(['SELECT * FROM table WHERE tag_number = ?;', tag_number])
  fetcher.execute_query(query)
end
```

## Checklist for New Service Objects

- [ ] `frozen_string_literal: true` pragma
- [ ] Module namespace matching directory structure
- [ ] `.call` class method as entry point
- [ ] Constants for error messages and defaults
- [ ] YARD docs on every public method
- [ ] Input validation (raise early on invalid input)
- [ ] Standardized `{ success:, response: }` return format
- [ ] Error wrapping with `rescue` and `log_error`
- [ ] Transaction wrapping for multi-step DB operations
- [ ] Graceful handling for non-critical failures
- [ ] SQL sanitization for dynamic queries
- [ ] `README.md` documenting the module

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Returning raw exceptions instead of error hash | Callers should get `{ success: false, ... }`, not unhandled exceptions |
| No `.call` entry point | Inconsistent API. Always use `.call` for the orchestrator pattern |
| Business logic in the controller | Extract to service. Controller should only handle request/response |
| Missing `frozen_string_literal` pragma | Inconsistent string behavior. Add to every file |
| No YARD docs on public methods | Other developers can't understand the contract |
| Skipping input validation | Bad input causes cryptic errors deep in the call chain |
| Transaction wrapping everything | Only wrap multi-step DB operations that must be atomic |

## Red Flags

- Service object with no tests
- `.call` method longer than 20 lines (needs sub-service extraction)
- Service that directly renders HTTP responses (that's controller's job)
- No error handling — exceptions bubble up to caller unhandled
- Service that modifies unrelated models (unclear responsibility boundary)
- Duplicated validation logic across services (extract to shared validator)

## Integration

| Skill | When to chain |
|-------|---------------|
| **ruby-api-client-integration** | For external API integrations (Auth, Client, Fetcher, Builder layers) |
| **strategy-factory-null-calculator** | For variant-based calculators (Factory + Strategy + Null Object) |
| **rspec-service-testing** | For testing service objects |
| **rspec-best-practices** | For general RSpec structure |
| **rails-architecture-review** | When service extraction is part of an architecture review |
