---
name: yard-documentation
description: >
  Use when writing or reviewing inline documentation for Ruby code. Every public method
  MUST include @param, @return, and @raise tags. For self.call methods, @return MUST
  specify the return type and structure (e.g., @return [Hash] with :success and :response
  keys). List each exception separately with @raise. Trigger words: YARD, inline docs,
  method documentation, API docs, public interface, rdoc, @return, @raise.
---
# YARD Documentation

Use this skill when documenting Ruby classes and public methods with YARD.

**Core principle:** Every public class and public method has YARD documentation so the contract is clear and tooling can generate API docs.

## HARD-GATE: After implementation

```
YARD is not optional polish. After any feature or fix that adds or changes
public Ruby API (classes, modules, public methods):

1. Add or update YARD on those surfaces before the work is considered done.
2. Do not skip YARD because "the PR is small" or "I'll do it later."
3. All YARD text must be in English unless user explicitly requests otherwise.

Task lists from generate-tasks MUST include explicit YARD sub-tasks after
implementation. If you only wrote specs + code, stop and document before PR.
```

## Output Style (MUST Follow)

When adding YARD to public methods, your output MUST include:

1. **@param tag** — Every parameter: `@param [Type] name`
2. **@option tag** — For hash params, list each valid key with type
3. **@return tag** — REQUIRED for every public method. Specify type and structure:
   - `@return [Hash] Result with :success and :response keys`
   - `@return [nil, String] nil if valid, error message otherwise`
4. **@raise tag** — REQUIRED for every exception. One tag per class:
   - `@raise [InvalidPlanError] when the plan does not exist or is inactive`
   - `@raise [PaymentGatewayError] when the payment provider rejects the charge`
5. **@example tag** — REQUIRED on `.call` methods showing usage AND return value
6. **Class summary** — One-line summary describing class responsibility

## Tag Reference

| Scope | Rule |
|-------|------|
| Classes | One-line summary; optional `@since` if version matters |
| Public methods | See Output Style above; all tags required unless explicitly inapplicable |
| Public `initialize` | Add `@param` for constructor inputs when initialization is part of the public contract |
| Private methods | Document only if behavior is non-obvious; same tag rules |

## Standard Tags

### Class-level

```ruby
# Responsible for validating and executing animal transfers between shelters.
# @since 1.2.0
module AnimalTransfers
  class TransferService
```

### Method-level: params and return

```ruby
# Performs the transfer and returns a standardized response.
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @option params [Hash] :target_shelter Target shelter with :shelter_id
# @return [Hash] Result with :success and :response keys
def self.call(params)
```

### Method-level: exceptions (list each raise)

Document `@raise` for every exception a method can raise — **even if the method rescues it internally**:

```ruby
# Processes the billing update for the given plan.
# @param plan_id [Integer] ID of the target plan
# @raise [InvalidPlanError] when the plan does not exist or is inactive
# @raise [PaymentGatewayError] when the payment provider rejects the charge
# @return [Hash] Result with :success and :response keys
def self.call(plan_id:)
```

### Examples on public entry points

Prefer at least one `@example` on `.call` or the main public entry point of the object.

```ruby
# @example Basic usage
#   result = TransferService.call(source_shelter: { shelter_id: 1 }, target_shelter: { shelter_id: 2 })
#   result[:success] # => true
```

## Good vs Bad

**Good:**

```ruby
# Validates source and target shelters and returns the first validation error.
# @param source_id [Integer] Source shelter ID
# @param target_id [Integer] Target shelter ID
# @return [nil, String] nil if valid, error message otherwise
def self.validate_shelters!(source_id, target_id)
```

**Bad:**

```ruby
# Validates stuff.  (Too vague; no @param/@return)
def self.validate_shelters!(source_id, target_id)
```

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Documenting only the class, not public methods | Callers need param types and return shape for every public method |
| Skipping `@option` for hash params | Without it, consumers don't know valid keys or types |
| Only one `@raise` for multiple exceptions | List EVERY exception type — one `@raise` per class, even if rescued internally |
| YARD text in a language other than English | Write in English unless the user explicitly requests otherwise |

## Verification

Run validation before considering documentation complete:

1. `yard stats --list-undoc`
2. `yard doc`
3. If output shows undocumented public surfaces you changed, update YARD and re-run.

For advanced tags (`@abstract`, `@deprecated`, `@api private`, `@yield`, `@overload`) see [ADVANCED_TAGS.md](./ADVANCED_TAGS.md).

## Integration

| Skill | When to chain |
|-------|----------------|
| **ruby-service-objects** | When implementing or documenting service objects |
| **ruby-api-client-integration** | When documenting API client layers (Auth, Client, Fetcher, Builder) |
| **rails-engine-docs** | When documenting engine public API or extension points |
| **rails-code-review** | When reviewing that public interfaces are documented |
| **generate-tasks** | Generated task lists include YARD parents after implementation |
