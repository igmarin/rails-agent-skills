---
name: rails-engine-testing
description: Use when setting up a dummy app, adding engine request specs, routing specs, generator specs, reload-safety tests, host integration coverage, or improving confidence in a Rails engine. Trigger words: dummy app, request spec, routing spec, generator spec, config spec, reload-safety, integration test.
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

## Testing Order

1. Identify the engine type and public behaviors.
2. Decide which behaviors need unit tests versus dummy-app integration tests.
3. Add the smallest integration test that proves mounting and boot work.
4. Add request, routing, configuration, and generator coverage as needed.
5. Add regression tests for coupling or reload bugs before refactoring.

## Minimum Baseline

For a non-trivial engine, aim for:

- one dummy-app boot or integration spec
- one request or routing spec for mounted endpoints
- one configuration spec for host customization
- unit tests for public services or POROs

If generators exist, add generator specs. If decorators or reload hooks exist, add reload-focused coverage.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| No dummy app | Engines must be tested inside a host; unit tests alone cannot prove mount and integration work |
| Testing against real host instead of dummy | Use spec/dummy; real host apps are environment-specific and slow |
| Skipping reload-safety tests | Decorators and patches can break in development; add regression coverage for reload behavior |

## Red Flags

- Tests pass only with a specific Rails version; no version matrix or compatibility checks
- No dummy app in spec/; engine boot and mount are untested
- Generator specs missing when install generators exist
- No config spec; configuration overrides are untested

## What To Test In The Dummy App

Use the dummy app for:

- mounting the engine
- route resolution
- controller and view rendering
- interactions with configured host models or adapters
- initializer-driven setup
- copied migrations or install flow where practical

Do not rely only on isolated unit tests when the behavior depends on Rails integration.

## Good Test Boundaries

- Unit tests: services, value objects, adapters, policy objects.
- Request specs: public engine endpoints.
- Routing specs: engine route expectations and mount behavior.
- System specs: only when the engine ships meaningful UI flows.
- Generator specs: install commands, copied files, idempotency.

## Review Checklist

- Does the dummy app exercise real host integration?
- Are engine routes tested through the engine namespace?
- Are configurable seams covered with at least one non-default case?
- Are generators safe to run twice?
- Are reload-sensitive hooks protected by regression tests?

## Common Gaps To Fix

- Engine boots but no test proves the host app can mount it.
- Request specs exist but use stubs instead of real engine wiring.
- Configuration object exists but default and override behavior are untested.
- Install generators exist without file or route assertions.
- Dummy app exists only as scaffolding and is not used in meaningful specs.

## Examples

**Minimal dummy-app request spec (engine mounted):**

```ruby
# spec/requests/my_engine/root_spec.rb or spec/integration/engine_mount_spec.rb
require 'rails_helper'

RSpec.describe 'MyEngine mount', type: :request do
  it 'mounts the engine and returns success for the engine root' do
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

## Output Style

When asked to help with tests:

1. List the highest-value missing integration tests.
2. Add a minimal passing baseline first.
3. Expand with focused regression coverage for risky seams.

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When structuring the engine for testability or adding configuration seams |
| rails-engine-reviewer | When validating test coverage adequacy or identifying gaps |
| rspec-best-practices | When improving spec structure, matchers, or shared examples |
