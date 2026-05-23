---
name: create-service-object
license: MIT
description: >
  Use when creating or refactoring Ruby service classes in Rails. Covers the
  .call pattern, module namespacing, YARD documentation on self.call and every
  public method, module README requirement, standardized {success:, response:}
  response contract, orchestrator delegation, transaction wrapping, and error
  handling conventions. Trigger words: service object, .call pattern,
  app/services, service module, service README, response hash, success/response
  shape, YARD on self.call.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Create Service Object

## Quick Reference

| Aspect | Rule |
|--------|------|
| Entry point | `def self.call(...)` → `new(...).call` |
| Validation | Validate inputs at top of `call`; return error hash if invalid |
| Error handling | `rescue` → log + error hash; never re-raise to caller |
| Transactions | Only wrap multi-step DB operations that must be atomic |
| `call` length | ≤20 lines; extract sub-services if longer |
| Scope | Return data only (no HTTP); single responsibility per service |
| SQL | `sanitize_sql` for any dynamic queries |
| Shared logic | Extract validators to class-only services (Pattern 3) |
| Response data | Serialize domain data; do not return raw ActiveRecord objects in `response` |
| Response shape | `{ success: true/false, response: { ... } }` always |

## HARD-GATE

```text
TESTS GATE IMPLEMENTATION:
EVERY service object MUST have its test written and validated BEFORE implementation.
  1. Write the spec for .call (with contexts for success, error, edge cases)
  2. Run the spec — verify it fails because the service does not exist yet
  3. ONLY THEN write the service implementation
The final artifact must include the spec command and the RED failure message
before implementation. Use the observed failure when available; otherwise show
the exact expected failure class/message for the missing service.
See write-tests for the full gate cycle.
```

## Core Process

1. **Write Spec (Test-First):** Create `spec/services/<module_name>/<service_name>_spec.rb`. Cover success and error paths for `.call`. Run it to confirm it fails (see HARD-GATE).
2. **Define Service Skeleton:** Create `app/services/<module_name>/<service_name>.rb` with the correct module namespace.
3. **Select Pattern:** Choose Standard, Batch, Class-only (Pattern 3), or Orchestrator based on requirements.
4. **Implement Contract:** Implement `self.call` and `#call`. The response must always be `{ success: true, response: { ... } }` or `{ success: false, response: { error: { message: '...' } } }`.
5. **Handle Errors and Logging:** Catch `StandardError` (and domain exceptions). Log with `Rails.logger.error` (message + backtrace). Use `UPPER_SNAKE_CASE` constants for all user-facing error strings.
6. **Add YARD Documentation:** Add `@param`, `@return [Hash]`, and `@raise` tags to `self.call` and every other public method. Document `self.call` separately from `#call`.
7. **Write Module README:** Generate `app/services/<module_name>/README.md` explaining domain context. Required even for single-service modules.

## Core Patterns

### 1. The `.call` Pattern
```ruby
def self.call(params)
  new(params).call
end

def call
  # ... processing ...
  { success: true, response: { data: result } }
rescue StandardError => e
  Rails.logger.error("Processing Error: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
  { success: false, response: { error: { message: ERROR_MESSAGE } } }
end
```

### 2. Batch Processing + Per-Item Rescue (Partial Success)
```ruby
def call
  results = @items.each_with_object({ successful: [], failed: [] }) do |item, acc|
    # process...
  rescue StandardError => e
    Rails.logger.error("Unexpected item error: #{e.message}")
    acc[:failed] << { sku: item[:sku], error: e.message }
  end
  { success: true, response: results }
end
```

### 3. Class-only Services (Static Methods)
When no instance state is needed, use ONLY class methods — no `initialize`, no instance variables. Suitable for validators, formatters, and argument-only helpers.

```ruby
class Orders::QuantityValidator
  def self.call(quantity:)
    return { success: false, response: { error: { message: INVALID_QUANTITY } } } unless quantity.positive?

    { success: true, response: { valid: true } }
  end
end
```

### 4. Orchestrator Delegation (≤20-line `call`)
```ruby
def call
  user_result = UserCreationService.call(@params)
  return user_result unless user_result[:success]
  # ... continue ...
end
```

## Output Style

Every service-object task produces these artifacts:

1. **Service file** — `app/services/<module_name>/<service_name>.rb` (pragma on line 1, class wrapped in a module matching the directory name).
2. **YARD docs** — `@param`, `@return [Hash]`, and `@raise` on `self.call` and every other public method (`self.call` documented separately from `#call`).
3. **Error message constants** — user-facing strings in `UPPER_SNAKE_CASE` at the top of the class, never inline in a `rescue`.
4. **Module README** — `app/services/<module_name>/README.md`, required even for single-service modules.
5. **Spec file** — `spec/services/<module_name>/<service_name>_spec.rb`, written and failing BEFORE implementation (see HARD-GATE). Specs must assert `success:` and `response:` top-level keys and the meaningful payload shape.
6. **Stateless pattern decision** — State whether instance state is required. If not, use Pattern 3 (no `initialize`, no instance variables).
7. **Language** — YARD, README, and error messages in English unless the user requests otherwise.

For class-only services (Pattern 3), document public class methods in YARD; if the class returns a non-standard shape (e.g. `nil` / error string), document that explicitly in YARD and the README.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/examples.md](assets/examples.md)** — Detailed examples of the 4 core patterns (Standard, Batch, Static, Orchestrator).
- **[assets/service_skeleton.md](assets/service_skeleton.md)** — Basic starting skeleton.
- **[assets/module_readme_template.md](./assets/module_readme_template.md)** — Template for the mandatory module README.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-yard-docs** | Writing/reviewing inline docs |
| **integrate-api-client** | External API integrations |
| **implement-calculator-pattern** | Variant-based calculators |
| **test-service** | Testing service objects |
| **write-tests** | General RSpec structure |
| **review-architecture** | Architecture review involving service extraction |
