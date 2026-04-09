---
name: ruby-service-objects
description: >
  Use when creating or refactoring Ruby service classes in Rails. Covers the
  .call pattern, module namespacing, YARD documentation, standardized responses,
  orchestrator delegation, transaction wrapping, and error handling conventions.
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
| Docs | YARD on every public method (see **yard-documentation**) |
| Validation | Raise early on invalid input |
| Errors | Rescue, log, return error hash — don't leak exceptions |
| Transactions | Wrap multi-step DB operations |

## Core Patterns

### 1. The `.call` Pattern (with delegation, transaction, YARD)

```ruby
module AnimalTransfers
  class TransferService
    TRANSFER_FAILED = 'Transfer could not be completed'

    # @param params [Hash] :source_shelter_id, :target_shelter_id, :tag_number
    # @return [Hash] { success: Boolean, response: Hash }
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @source_shelter_id = params[:source_shelter_id]
      @target_shelter_id = params[:target_shelter_id]
      @tag_number = params[:tag_number]
    end

    def call
      source = ShelterValidator.validate_source_shelter!(@source_shelter_id)
      target = ShelterValidator.validate_target_shelter!(@target_shelter_id)
      result = execute_transfer(source, target)
      { success: true, response: { transfer: result } }
    rescue ActiveRecord::RecordInvalid => e
      log_error('Validation Error', e)
      { success: false, response: { error: { message: e.message } } }
    rescue StandardError => e
      log_error('Processing Error', e, include_backtrace: true)
      { success: false, response: { error: { message: TRANSFER_FAILED } } }
    end

    private

    def execute_transfer(source, target)
      ActiveRecord::Base.transaction do
        source.decrement!(:animal_count)
        target.increment!(:animal_count)
        TransferLog.create!(source:, target:, tag_number: @tag_number)
      end
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

### 3. Class-only Services (Static Methods)

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

## Additional Patterns

### Constants for configuration

```ruby
MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
DEFAULT_TIMEOUT = 30
```

### SQL sanitization

```ruby
def self.find(tag_number:)
  query = ActiveRecord::Base.sanitize_sql(['SELECT * FROM table WHERE tag_number = ?;', tag_number])
  fetcher.execute_query(query)
end
```

## Checklist for New Service Objects

- [ ] Module namespace matches directory structure
- [ ] Constants defined for error messages and defaults
- [ ] Graceful handling for non-critical failures
- [ ] SQL sanitization for any dynamic queries
- [ ] `README.md` documenting the module

## Pitfalls

| Problem | Correct approach |
|---------|-----------------|
| Returning raw exceptions instead of error hash | Callers should get `{ success: false, ... }`, not unhandled exceptions |
| Skipping input validation | Bad input causes cryptic errors deep in the call chain |
| Transaction wrapping everything | Only wrap multi-step DB operations that must be atomic |
| `.call` method longer than 20 lines | Extract to sub-services — orchestrator should coordinate, not implement |
| Service renders HTTP responses | That's the controller's job — service returns data only |
| Service modifies unrelated models | Unclear boundary — extract a new service with a single responsibility |
| Duplicated validation across services | Extract to a shared validator object |

## Integration

| Skill | When to chain |
|-------|---------------|
| **yard-documentation** | When writing or reviewing inline docs for classes and public methods |
| **ruby-api-client-integration** | For external API integrations (Auth, Client, Fetcher, Builder layers) |
| **strategy-factory-null-calculator** | For variant-based calculators (Factory + Strategy + Null Object) |
| **rspec-service-testing** | For testing service objects |
| **rspec-best-practices** | For general RSpec structure |
| **rails-architecture-review** | When service extraction is part of an architecture review |
