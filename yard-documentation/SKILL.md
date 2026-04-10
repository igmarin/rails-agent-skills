---
name: yard-documentation
description: >
  Use when writing or reviewing inline documentation for Ruby code. Covers YARD tags
  for classes and public methods (param, option, return, raise, example tags). Trigger
  words: YARD, inline docs, method documentation, API docs, public interface, rdoc.
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
3. All YARD text (descriptions, examples, tags) must be in English unless
   the user explicitly requests another language.

Task lists from generate-tasks MUST include explicit YARD sub-tasks after
implementation. If you only wrote specs + code, stop and document before PR.
```

## Quick Reference

| Scope | Rule |
|-------|------|
| Classes | One-line summary; optional `@since` if version matters |
| Public methods | `@param`, `@option` for hash params, `@return`, `@raise` when applicable; `@example` **required** on `.call` — show realistic usage AND the expected return value (e.g., `result[:success] # => true`) |
| Public `initialize` | Add `@param` for constructor inputs when initialization is part of the public contract |
| Exceptions | One `@raise` tag per exception class — list each separately |
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

**Bad (wrong language):**

```ruby
# Valida los refugios origen y destino.  (Must be in English)
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
