---
name: rails-stack-conventions
description: >
  Use when writing or generating code for a Rails project with PostgreSQL, Hotwire
  (Turbo + Stimulus), and Tailwind CSS. Covers Ruby style, naming, MVC structure,
  ActiveRecord patterns, error handling, performance, security defaults, and testing
  conventions.
---

# Rails Stack Conventions

When **writing or generating** code for this project, follow these conventions. Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

**Core principle:** Follow Rails conventions. When in doubt, check the official Rails guides.

## HARD-GATE: Tests Gate Implementation

```
ALL new code MUST have its test written and validated BEFORE implementation.
  1. Write the spec for the behavior
  2. Run the spec — verify it fails because the feature does not exist yet
  3. ONLY THEN write the implementation code
See rspec-best-practices for the full gate cycle.
```

## Quick Reference

| Aspect | Convention |
|--------|-----------|
| Style | Ruby Style Guide, single quotes, `unless`/`||=`/`&.` |
| Naming | `snake_case` files/methods, `CamelCase` classes |
| Models | MVC, concerns, service objects for complex logic |
| Queries | Eager loading (`includes`), avoid N+1 |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Testing | RSpec or Minitest, TDD/BDD, FactoryBot |
| Security | Devise/Pundit, strong params, guard XSS/CSRF/SQLi |

## Code Style and Structure

- Concise, idiomatic Ruby; follow Rails conventions
- OOP and functional patterns as appropriate; prefer modularization over duplication
- Descriptive names: `user_signed_in?`, `calculate_total`
- Structure: MVC, concerns, helpers per Rails conventions

## Naming

- **snake_case:** files, methods, variables
- **CamelCase:** classes, modules
- Rails naming for models, controllers, views

## Ruby and Rails

- Use Ruby 3.x features when helpful (pattern matching, endless methods)
- Prefer Rails built-in helpers and APIs
- Use ActiveRecord effectively; avoid N+1 (eager loading)

## Syntax and Formatting

- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Use expressive Ruby: `unless`, `||=`, `&.`
- **Single quotes** for strings unless interpolation is needed

## Error Handling and Validation

- Exceptions for exceptional cases, not control flow
- Proper error logging and user-friendly messages
- ActiveModel validations in models
- Controllers: handle errors and set appropriate flash messages

## UI and Styling

- **Hotwire:** Turbo and Stimulus for dynamic, SPA-like behavior
- **Tailwind CSS** for responsive layout and styling
- View helpers and partials to keep views DRY

## Performance

- Effective DB indexing; caching (fragment, Russian Doll) where useful
- Eager loading; optimize with `includes`, `joins`, `select` as needed

## Architecture

- RESTful routes; concerns for shared behavior
- **Service objects** for non-trivial business logic
- **Background jobs** for long-running work

## Testing

- RSpec or Minitest; TDD/BDD style
- FactoryBot (or equivalent) for test data

## Security

- Auth/authz (e.g. Devise, Pundit); strong parameters
- Guard against XSS, CSRF, SQL injection

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Logic in views | Use helpers, presenters, or Stimulus controllers |
| N+1 queries ignored in development | They compound in production. Always eager load. |
| Raw SQL without parameterization | SQL injection risk. Use ActiveRecord query methods. |
| Skipping FactoryBot for "quick" test | Fixtures are brittle. Factories are faster to maintain. |
| Ignoring Ruby Style Guide | Consistent style reduces review friction. Follow the guide. |

## Red Flags

- Controller action with more than 15 lines of logic
- Model with no validations
- View with embedded Ruby conditionals spanning 10+ lines
- No `includes` on associations used in loops
- Hardcoded strings that should be in I18n

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-code-review** | When reviewing existing code against these conventions |
| **ruby-service-objects** | When extracting business logic into services |
| **rspec-best-practices** | For testing conventions |
| **rails-architecture-review** | For structural review beyond conventions |

## Reference

Follow the [official Rails guides](https://guides.rubyonrails.org/) for routing, controllers, models, views, and related topics.
