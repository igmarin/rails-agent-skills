---
name: yard-documentation
description: >
  Use when writing or reviewing inline documentation for Ruby code. Every public method
  MUST include param, return, and raise tags. For self.call methods, the return tag MUST
  specify the return type and structure (e.g., return [Hash] with :success and :response
  keys). List each exception separately with its own raise tag. Trigger words: YARD, inline docs,
  method documentation, API docs, public interface, rdoc, return tag, raise tag.
---
# YARD Documentation

Use this skill when documenting Ruby classes and public methods with YARD.

**Core principle:** Every public class and public method has YARD documentation so the contract is clear and tooling can generate API docs.

## HARD-GATE: After implementation

```
YARD is not optional polish. After any feature or fix that adds or changes
public Ruby API (classes, modules, public methods):

1. Add or update YARD on those surfaces before the work is considered done.
2. Do not skip YARD because "the PR is small" or "I'll do it later".
3. All YARD text must be in English unless user explicitly requests otherwise.

Task lists from generate-tasks MUST include explicit YARD sub-tasks after
implementation.
```

## Tag Reference

Canonical examples for common tags: [EXAMPLES.md](./EXAMPLES.md) — includes `@param`, `@return`, and `@raise` tag usage.

| Scope | Rule |
|-------|------|
| Classes | One-line summary; optional `@since` if version matters |
| Public methods | All tags required unless explicitly inapplicable: `@param`, `@option` (for hash params), `@return`, `@raise` |
| Public `initialize` | Add `@param` for constructor inputs when initialization is part of the public contract |
| Private methods | Document only if behavior is non-obvious; same tag rules |

## Standard Tags with Examples

### Class-level

```ruby
# Responsible for validating and executing animal transfers between shelters.
# @since 1.2.0
module AnimalTransfers
  class TransferService
```

### Method-level: params, options, return, and example

Use `@option` for every valid key in hash params. Include at least one `@example` on `.call` or the main public entry point.

```ruby
# Performs the transfer and returns a standardized response.
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @option params [Hash] :target_shelter Target shelter with :shelter_id
# @return [Hash] Result with :success and :response keys
# @example Basic usage
#   result = TransferService.call(source_shelter: { shelter_id: 1 }, target_shelter: { shelter_id: 2 })
#   result[:success] # => true
def self.call(params)
```

### Method-level: exceptions

Document `@raise` for every exception a method can raise — **even if the method rescues it internally**. One tag per exception class.

```ruby
# Processes the billing update for the given plan.
# @param plan_id [Integer] ID of the target plan
# @raise [InvalidPlanError] when the plan does not exist or is inactive
# @raise [PaymentGatewayError] when the payment provider rejects the charge
# @return [Hash] Result with :success and :response keys
def self.call(plan_id:)
```

### Nullable / conditional returns

```ruby
# Validates source and target shelters and returns the first validation error.
# @param source_id [Integer] Source shelter ID
# @param target_id [Integer] Target shelter ID
# @return [nil, String] nil if valid, error message otherwise
def self.validate_shelters!(source_id, target_id)
```

## Good vs Bad

**Good:**

```ruby
# Processes the billing update for the given plan.
# @param plan_id [Integer] ID of the target plan
# @raise [InvalidPlanError] when the plan does not exist or is inactive
# @raise [PaymentGatewayError] when the payment provider rejects the charge
# @return [Hash] Result with :success and :response keys
def self.call(plan_id:)
```

**Bad:**

```ruby
# Updates billing.  (Too vague; no @param/@return/@raise)
def self.call(plan_id:)
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
