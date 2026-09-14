# Rails Code Conventions Checklist

Purpose: concise, actionable coding rules for Rails projects in this repo.

Core rules
- Prefer POROs/service objects over fat models/controllers
- Prefer composition over inheritance
- Follow Single Responsibility: one reason to change per class
- Avoid long callbacks; prefer explicit service calls
- Use `# frozen_string_literal: true` at file top

Per-path rules
- app/models: keep validations and minimal scopes; move business logic to services
- app/controllers: thin controllers; permit strong params; render small view models
- app/services: provide `.call` class methods returning `{ success: bool, response: { ... } }`
- app/jobs: idempotent perform methods with retry/discard strategies
- lib/: keep adapters and integration clients; avoid Rails.env checks here

Testing
- Tests are the gate: write spec → run → fail → implement → pass
- Use FactoryBot and traits for test data; avoid global DB state
- Prefer request specs for integration and unit specs for services

Style
- Follow project's RuboCop config where present
- Name boolean predicates with `?`
- Prefer keyword arguments for service objects

Documentation
- Public classes/methods must have YARD @example and @raise when applicable

Small checklist for PRs
- [ ] Tests added for new behavior
- [ ] Linter passes locally
- [ ] CHANGELOG entry if user-visible
- [ ] Relevant README/YARD updated
