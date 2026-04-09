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
| Error handling | Every `rescue` block must: (1) log with `Rails.logger.error`, (2) log backtrace via `e.backtrace.join("\n")`, (3) return error hash — never re-raise |
| Transactions | Wrap multi-step DB operations |

## When to Use Each Pattern

| Signal in the task | Pattern |
|--------------------|---------|
| Orchestrates multiple steps, needs instance state | Pattern 1: `.call → new.call` |
| Processes a collection with per-item error handling | Pattern 2: Batch processing |
| Stateless helper, validator, or utility — no instance state needed | Pattern 3: Class-only (static methods) |
| Coordinates multiple sub-services | Pattern 4: Orchestrator delegation |

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
      result = ActiveRecord::Base.transaction do
        source.decrement!(:animal_count)
        target.increment!(:animal_count)
        TransferLog.create!(source:, target:, tag_number: @tag_number)
      end
      { success: true, response: { transfer: result } }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Validation Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, response: { error: { message: e.message } } }
    rescue StandardError => e
      Rails.logger.error("Processing Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, response: { error: { message: TRANSFER_FAILED } } }
    end
  end
end
```

### 2. Batch Processing + Per-Item Rescue (Partial Success)

```ruby
# Batch — each rescue block logs; outer rescue returns { success: false }
def call
  results = @items.each_with_object({ successful: [], failed: [] }) do |item, acc|
    validate_item!(item)
    process_item(item)
    acc[:successful] << item[:sku]
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Item not found: #{e.message}")
    acc[:failed] << { sku: item[:sku], error: e.message }
  rescue StandardError => e
    Rails.logger.error("Unexpected item error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    acc[:failed] << { sku: item[:sku], error: e.message }
  end
  { success: true, response: results }
rescue StandardError => e
  Rails.logger.error("Service failed: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
  { success: false, response: { error: { message: PROCESSING_FAILED } } }
end
```

### 3. Class-only Services (Static Methods)

When no instance state is needed — use ONLY class methods, no `initialize`, no instance variables. Validators and stateless helpers should always use this pattern:

```ruby
class PackageValidator
  MAX_WEIGHT_KG = 30
  MAX_LENGTH_CM = 150

  # @param dimensions [Hash] :weight_kg, :length_cm, :width_cm, :height_cm
  # @return [nil, String] nil if valid, error message otherwise
  def self.validate(dimensions)
    return 'Weight exceeds limit' if dimensions[:weight_kg] > MAX_WEIGHT_KG
    return 'Length exceeds limit' if dimensions[:length_cm] > MAX_LENGTH_CM
    nil
  end

  def self.within_limits?(dimensions)
    validate(dimensions).nil?
  end
end
```

Validators raise; the calling service rescues and converts to an error hash.

### 4. Orchestrator Delegation (≤20-line `call`)

All sub-services return `{ success:, response: {} }`. The orchestrator checks each result and returns early on failure:

```ruby
# Orchestrator call — delegates to sub-service classes, validates each result
# RULE: ≤20 lines of code in call — if longer, extract another sub-service
def call
  user_result = UserCreationService.call(@params)
  return user_result unless user_result[:success]

  workspace_result = WorkspaceSetupService.call(user_result[:response])
  return workspace_result unless workspace_result[:success]

  BillingService.call(workspace_result[:response])
  NotificationService.call(user_result[:response])
  { success: true, response: { user: user_result[:response] } }
rescue StandardError => e
  Rails.logger.error("Orchestrator failed: #{e.message}")
  { success: false, response: { error: { message: ONBOARDING_FAILED } } }
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
