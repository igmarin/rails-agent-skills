---
name: ruby-service-objects
description: >
  Use when creating or refactoring Ruby service classes in Rails. Covers the
  .call pattern, module namespacing, YARD on self.call AND every public method,
  module README requirement, standardized {success:, response:} response contract,
  orchestrator delegation, transaction wrapping, and error handling conventions.
  Trigger words: service object, .call pattern, app/services, service module,
  service README, response hash, success/response shape, YARD on self.call.
---

# Ruby Service Objects

## Quick Reference

| Aspect | Rule |
|--------|------|
| Entry point | `def self.call(...)` → `new(...).call` |
| File path | `app/services/<module_name>/<service_name>.rb` |
| Module README | `app/services/<module_name>/README.md` — REQUIRED for every service module |
| Pragma | `# frozen_string_literal: true` (first line of every `.rb`) |
| YARD | `@param` + `@return` on `self.call` AND on every other public method (no exceptions) |
| Success return | `{ success: true, response: { <domain_key>: <value> } }` |
| Failure return | `{ success: false, response: { error: { message: '...' } } }` |
| Error log | `Rails.logger.error(e.message)` AND `Rails.logger.error(e.backtrace.first(5).join("\n"))` |

## HARD-GATE: Tests Gate Implementation

```
EVERY service object MUST have its test written and validated BEFORE implementation.
  1. Write the spec for .call (with contexts for success, error, edge cases)
  2. Run the spec — verify it fails because the service does not exist yet
  3. ONLY THEN write the service implementation
See rspec-best-practices for the full gate cycle.
```

## MANDATORY Response Contract

Every service's `.call` / `call` MUST return a hash matching EXACTLY one of these two shapes. No other keys at the top level. No returning booleans, ActiveRecord objects, or raw models.

```ruby
# Success
{ success: true, response: { <domain_key>: <value>, ... } }

# Failure
{ success: false, response: { error: { message: 'human-readable reason' } } }
```

1. Top-level keys are exactly `:success` (Boolean) and `:response` (Hash). Reject `{ data: ... }`, `{ subscription: ... }`, or any key other than `:success` / `:response` at the top level.
2. Errors nest under `response: { error: { message: ... } }`. Reject `{ message: '...' }` at top level or `{ response: { message: '...' } }` missing the `:error` wrapper.

## Conventions

| Convention | Rule |
|-----------|------|
| Entry point | `.call` class method → `new.call` |
| File location | `app/services/module_name/service_name.rb` |
| Pragma | `frozen_string_literal: true` |
| Docs | YARD on every public method (→ **yard-documentation**) |
| Validation | Validate inputs at top of `call`; return error hash if invalid |
| Error handling | `rescue` → log + error hash; never re-raise to caller |
| Transactions | Only wrap multi-step DB operations that must be atomic |
| `call` length | ≤20 lines; extract sub-services if longer |
| Scope | Return data only (no HTTP); single responsibility per service |
| SQL | `sanitize_sql` for any dynamic queries |
| Shared logic | Extract validators to class-only services (Pattern 3) |

## When to Use Each Pattern

| Signal in the task | Pattern |
|--------------------|----------|
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
  return { success: false, response: { error: { message: 'Items list cannot be empty' } } } if @items.blank?

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

Sub-services handle their OWN rescue and return `{ success: false, response: { error: { message: ... } } }` on failure. The orchestrator propagates early returns only — no rescue block needed:

```ruby
# RULE: ≤20 lines in call — if longer, extract another sub-service
def call
  user_result = UserCreationService.call(@params)
  return user_result unless user_result[:success]

  workspace_result = WorkspaceSetupService.call(user_result[:response])
  return workspace_result unless workspace_result[:success]

  BillingService.call(workspace_result[:response])
  NotificationService.call(user_result[:response])
  { success: true, response: { user: user_result[:response] } }
end
```

## Output Style

When asked to create or refactor a service object, your output MUST include EVERY item below. Each is independently graded — omitting any one drops the score even if the implementation is correct.

1. **Service file** at `app/services/<module_name>/<service_name>.rb` with `# frozen_string_literal: true` as the first line and the class wrapped in a module matching the directory name.
2. **YARD on `self.call`** — `@param` for every argument, `@return [Hash]` describing the success/failure shape, plus `@raise` for any exception class that can escape (even those rescued internally elsewhere). YARD on `self.call` is graded separately from YARD on other methods — do not skip it because the body delegates to `new(...).call`.
3. **YARD on every other public method** — `initialize`, helpers, predicates. Same `@param` / `@return` / `@raise` discipline.
4. **Response contract** — every return path uses EXACTLY `{ success: Boolean, response: Hash }`. Errors nest under `response: { error: { message: '...' } }`. Never return `{ data: ... }`, `{ message: ... }` at top level, raw ActiveRecord objects, booleans, or `nil`.
5. **Error message constants** — user-facing failure strings live in `UPPER_SNAKE_CASE` constants at the top of the class (e.g. `TRANSFER_FAILED = 'Transfer could not be completed'`), not inline strings inside `rescue`.
6. **Module README** at `app/services/<module_name>/README.md` — REQUIRED. One section per service in the module, listing: purpose (1 line), inputs, success response shape, failure response shape, exceptions raised. Even a single-service module gets a README. **Do not skip this** — it is a graded artifact, not optional documentation.
7. **Spec file** at `spec/services/<module_name>/<service_name>_spec.rb` written and failing BEFORE the implementation (see HARD-GATE).
8. **English** — all YARD, README content, and error messages in English unless the user explicitly asks otherwise.

If the task is class-only (Pattern 3): same rules, but `self.call` becomes the public class method(s) being documented; the response contract still applies if the class returns service-style results (validators may return `nil` / error string per Pattern 3 above — document that explicitly).

### Module README template

```markdown
# <ModuleName> Services

Brief paragraph: what business capability this module covers.

## <ServiceName>

**Purpose:** one-line summary.

**Inputs:** `params [Hash]` with `:key1`, `:key2`, ...

**Success:** `{ success: true, response: { <domain_key>: <value> } }`

**Failure:** `{ success: false, response: { error: { message: String } } }`

**Raises:** `SomeError` when ..., `OtherError` when ... (internally rescued unless noted).
```

## Integration

| Skill | When to chain |
|-------|---------------|
| **yard-documentation** | Writing/reviewing inline docs |
| **ruby-api-client-integration** | External API integrations |
| **strategy-factory-null-calculator** | Variant-based calculators |
| **rspec-service-testing** | Testing service objects |
| **rspec-best-practices** | General RSpec structure |
| **rails-architecture-review** | Architecture review involving service extraction |
