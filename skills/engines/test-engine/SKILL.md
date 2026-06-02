---
name: test-engine
type: atomic
license: MIT
description: >
  Use when writing and configuring RSpec tests for Rails engines — must ensure that a dummy app exists for testing, add the smallest integration test that proves mounting and boot and verify it passes before continuing, and run the full test suite via bundle exec rspec to verify all specs pass. Key capabilities: request and routing specs with namespace scoping, generator idempotency, configuration testing.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Test Engine

Use this skill when the task is to create or improve test coverage for a Rails engine.

## Quick Reference

| Spec Type | Engine-Specific Nuance |
|-----------|------------------------|
| Request | Test via engine's named route helper (e.g., `my_engine.root_path`) to verify correct mounting in the host |
| Routing | Assert routes are scoped to the engine namespace; test with and without a custom mount point |
| Generator | Assert idempotency (safe to run twice); verify files are copied to expected host app paths |
| Config | Override default in `around` block; assert the engine uses the host-provided value, not its own default |
| Reload-safety | Cover `to_prepare` hooks and decorator re-application across code reloads in development mode |

## HARD-GATE

```text
EVERY engine MUST have a dummy app for testing.
If it doesn't exist, generate it:
cd my_engine && bundle exec rails plugin new . --dummy-path=spec/dummy --skip-git

Validate the dummy app boots before proceeding:
cd spec/dummy && bundle exec rails runner "puts 'Boot OK'"

If this fails, check the engine's `engine.rb` initializer order and ensure the engine is correctly mounted in `spec/dummy/config/routes.rb` before writing any specs.
```

## Core Process

1. Identify the engine type and public behaviors.
2. Decide which behaviors need unit tests versus dummy-app integration tests.
3. Add the smallest integration test that proves mounting and boot work. **Verify it passes before continuing** — if it fails, check `engine.rb` initializer order and mount configuration rather than adding more specs on top of a broken foundation.
4. Add request, routing, configuration, and generator coverage as needed.
5. Add regression tests for coupling or reload bugs before refactoring.
6. Run the full test suite (`bundle exec rspec`) to verify all specs pass.

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

## Extended Resources (Progressive Disclosure)

**Pitfalls**
| Pitfall | What to do |
|---------|------------|
| Skipping reload-safety tests | Add regression coverage for decorators and patches in development |
| Tests pass only with specific Rails version | Run a version matrix; pin nothing unless required |
| Request specs use stubs instead of real wiring | Mount the engine in dummy and call through it |
| Install generators without file assertions | Assert copied files and idempotency in generator specs |

Load these files only when their specific content is needed:

- **[assets/dummy_app_instructions.md](assets/dummy_app_instructions.md)** — Use when setting up the dummy app from scratch or troubleshooting boot failures
- **[assets/examples.md](assets/examples.md)** — Use when writing generator, reload-safety, or integration specs
- **[assets/spec_template.md](assets/spec_template.md)** — Use as starting point when creating the first engine spec file

## Output Style

When completing engine test setup, output MUST include:

```markdown
# Engine Test Report — [Engine Name]

## Dummy App
- Location: test/dummy/ or spec/dummy/
- Boot: ✓ (rails server starts without errors)
- Migrations: ✓ (engine migrations installed and run)

## Specs
- Engine mounting: ✓ tested
- Generators: ✓ tested (if applicable)
- Core functionality: ✓ (<n> examples, 0 failures)
- Reload safety: ✓ tested in development mode

## Suite
- Full run: bundle exec rspec — <n> examples, 0 failures
```

## Integration

| Skill | When to chain |
|-------|---------------|
| create-engine | When structuring the engine for testability or adding configuration seams |
| review-engine | When validating test coverage adequacy or identifying gaps |
| write-tests | When improving spec structure, matchers, or shared examples |
