---
name: rails-engine-testing
description: >
  Use when creating or improving RSpec test coverage for Rails engines.
  Covers dummy app setup, request, routing, generator, and configuration
  specs for proving engine behavior within a host application.
---
# Rails Engine Testing

Use this skill when the task is to create or improve test coverage for a Rails engine.

Prefer integration confidence over isolated test quantity. The main goal is to prove the engine behaves correctly inside a host app.

## Quick Reference

| Spec Type | Purpose |
|-----------|---------|
| Request | Proves mounted endpoints work; exercises real routing and controller |
| Routing | Verifies engine route expectations and mount behavior |
| Generator | Covers install commands, copied files, idempotency |
| Config | Verifies engine respects host configuration overrides |
| Reload-safety | Regression tests for decorators, patches, and `to_prepare` hooks |

## HARD-GATE

**EVERY engine MUST have a dummy app for testing.**

Generate one if it doesn't exist:

```bash
cd my_engine && bundle exec rails plugin new . --dummy-path=spec/dummy --skip-git
```

**Validate the dummy app boots before proceeding:**

```bash
cd spec/dummy && bundle exec rails runner "puts 'Boot OK'"
```

If this fails, check the engine's `engine.rb` initializer order and ensure the engine is correctly mounted in `spec/dummy/config/routes.rb` before writing any specs.

## Testing Order

1. Identify the engine type and public behaviors.
2. Decide which behaviors need unit tests versus dummy-app integration tests.
3. Add the smallest integration test that proves mounting and boot work. **Verify it passes before continuing** — if it fails, check `engine.rb` initializer order and mount configuration rather than adding more specs on top of a broken foundation.
4. Add request, routing, configuration, and generator coverage as needed.
5. Add regression tests for coupling or reload bugs before refactoring.
6. Verify: dummy app exercises real host integration; routes tested through engine namespace; configurable seams covered with at least one non-default case; generators safe to run twice.

## Minimum Baseline

For a non-trivial engine, aim for:

- one dummy-app boot or integration spec
- one request or routing spec for mounted endpoints
- one configuration spec for host customization
- unit tests for public services or POROs

If generators exist, add generator specs. If decorators or reload hooks exist, add reload-focused coverage.

**Minimal request spec to prove the engine mounts:**

```ruby
# spec/requests/my_engine/root_spec.rb
require 'rails_helper'

RSpec.describe 'MyEngine mount', type: :request do
  it 'returns ok for the engine root' do
    get my_engine.root_path
    expect(response).to have_http_status(:ok)
  end
end
```

**Configuration spec (engine respects host config):**

```ruby
# spec/my_engine/configuration_spec.rb
RSpec.describe MyEngine::Configuration do
  around do |example|
    original = MyEngine.config.widget_count
    MyEngine.config.widget_count = 3
    example.run
    MyEngine.config.widget_count = original
  end

  it 'uses configured value' do
    expect(MyEngine.config.widget_count).to eq(3)
  end
end
```

For generator and reload-safety spec examples, see [EXAMPLES.md](./EXAMPLES.md).

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| No dummy app | Use spec/dummy; unit tests alone cannot prove mount and integration |
| Testing against real host | Use spec/dummy; real host apps are environment-specific and slow |
| Skipping reload-safety tests | Add regression coverage for decorators and patches in development |
| Tests pass only with specific Rails version | Run a version matrix; pin nothing unless required |
| Request specs use stubs instead of real wiring | Mount the engine in dummy and call through it |
| Install generators without file assertions | Assert copied files and idempotency in generator specs |

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When structuring the engine for testability or adding configuration seams |
| rails-engine-reviewer | When validating test coverage adequacy or identifying gaps |
| rspec-best-practices | When improving spec structure, matchers, or shared examples |

## Assets

- [assets/dummy_app_instructions.md](assets/dummy_app_instructions.md)
- [assets/examples.md](assets/examples.md)
