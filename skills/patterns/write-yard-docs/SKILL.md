---
name: write-yard-docs
license: MIT
description: >
  Use when writing or reviewing inline documentation for Ruby code. Every public method
  MUST include param, return, and raise tags. For self.call methods, the return tag MUST
  specify the return type and structure (e.g., return [Hash] with :success and :response
  keys). List each exception separately with its own raise tag. Trigger words: YARD, inline docs,
  method documentation, API docs, public interface, rdoc, return tag, raise tag.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Write YARD Docs

Use this skill when documenting Ruby classes and public methods with YARD.

**Core principle:** Every public class and public method has YARD documentation so the contract is clear and tooling can generate API docs.

## Quick Reference

| Scope | Rule |
|-------|------|
| Classes | One-line summary; optional `@since` if version matters |
| Public methods | All tags required unless explicitly inapplicable: `@param`, `@option` (for hash params), `@return`, `@raise` |
| Public `initialize` | Add `@param` for constructor inputs when initialization is part of the public contract |
| Private methods | Document only if behavior is non-obvious; same tag rules |

## HARD-GATE

```text
AFTER IMPLEMENTATION GATE:
After any feature or fix that adds or changes public Ruby API (classes, modules, public methods):
1. Add or update YARD on those surfaces before the work is considered done.
2. All YARD text must be in English unless user explicitly requests otherwise.
Task lists MUST include explicit YARD sub-tasks after implementation.
```

## Core Process

1. **Identify Public Surfaces:** Locate all new or modified public classes, modules, and methods.
2. **Add Class-Level Docs:** Provide a one-line summary describing the responsibility of the class or module.
3. **Add Method-Level Docs:** For every public method, add `@param` (and `@option` for hash arguments), `@return`, and `@raise` tags.
4. **Document Exceptions:** List each exception separately with its own `@raise` tag, even if the method rescues it internally.
5. **Verify Completeness:** Run `yard stats --list-undoc` and `yard doc` to ensure no public surfaces are missing documentation.
6. **Task-list handoff:** When producing or reviewing tasks, add explicit YARD sub-tasks after implementation for every new or changed public Ruby API.

## Tag Examples

### Class-level
```ruby
# Responsible for validating and executing animal transfers between shelters.
# @since 1.2.0
module AnimalTransfers
  class TransferService
```

### Method-level
```ruby
# Performs the transfer and returns a standardized response.
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @option params [Hash] :target_shelter Target shelter with :shelter_id
# @return [Hash] Result with :success and :response keys
# @raise [InvalidShelterError] when the shelter does not exist
# @example Basic usage
#   result = TransferService.call(source_shelter: { shelter_id: 1 }, target_shelter: { shelter_id: 2 })
#   result[:success] # => true
def self.call(params)
```

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](./EXAMPLES.md)** — Canonical examples for common tags, including `@param`, `@return`, and `@raise` tag usage.
- **[references/tagged-notes.md](references/tagged-notes.md)** — Guidelines on tagged notes (`TODO:`, `FIXME:`).
- **[ADVANCED_TAGS.md](./ADVANCED_TAGS.md)** — Guidance for advanced tags (`@abstract`, `@deprecated`, `@api private`, `@yield`, `@overload`).

## Output Style

When writing or reviewing YARD docs, your output MUST satisfy:

1. **Class/Module Summary** — Every new or modified public class/module has a descriptive summary.
2. **Method Tags** — Every public method must have `@param` (or `@option`), `@return`, and `@raise` tags.
3. **Discrete `@raise` Tags** — One `@raise` tag per exception class. Do not group multiple exceptions into a single tag.
4. **Explicit Return Structures** — For `.call` methods or complex returns, the `@return` tag MUST specify the exact structure (e.g., `[Hash] Result with :success and :response keys`).
5. **Tagged Notes Context** — Inline tagged notes (`TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `OPTIMIZE:`) must carry actionable context (owner, ticket, next step). No naked tags.
6. **Task-list handoff** — If the output is a task list, include YARD documentation sub-tasks after implementation tasks. If the output is only a documentation artifact, state that future task lists must include those YARD sub-tasks.
7. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| **create-service-object** | After implementing a service object |
| **integrate-api-client** | Documenting API client layers (Auth, Client, Fetcher, Builder) |
| **code-review** | Verifying public interfaces are documented |
