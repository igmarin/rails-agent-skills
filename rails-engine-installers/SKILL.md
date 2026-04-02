---
name: rails-engine-installers
description: >
  Use when creating install generators, copied migrations, or initializer
  installers for Rails engines. Covers idempotent setup tasks, host-app
  onboarding, and route mount setup.
---
# Rails Engine Installers

Use this skill when the task is to design or review how a host app installs and configures a Rails engine.

Good installation flows are explicit, repeatable, and safe to rerun.

## Quick Reference

| Installer Component | Purpose |
|--------------------|---------|
| Generator | Creates initializer, route mount, or optional setup files; must be idempotent |
| Migrations | Copies engine migrations into host `db/migrate`; host owns and runs them |
| Initializer | Provides configuration defaults; generated once, editable by host |
| Routes | Adds `mount Engine, at: '/path'`; document or generate, avoid duplicates |

## Primary Goals

- Make host setup obvious.
- Keep setup idempotent.
- Prefer generated files over hidden runtime mutation.
- Keep operational steps documented and testable.

## Typical Responsibilities

- copy migrations into the host app
- create an initializer with configuration defaults
- add or document route mounting
- seed optional setup files or permissions
- expose a single install command when it improves usability

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Non-idempotent generators | Generators must be safe to run multiple times; check before injecting routes or files |
| Mutating host in boot | Never modify host files or state from initializers or engine.rb at load time |
| No rollback for install | Document manual rollback steps; generators cannot reliably undo all changes |

## Red Flags

- Generator that overwrites host files without checking for existing content
- Install flow modifies boot sequence or runs code at require time
- No idempotency check before injecting routes, initializer, or migrations
- Setup steps hidden inside initializers instead of explicit generator output

## Rules

- Never make boot-time code silently modify the host app.
- Prefer generators over manual copy-paste instructions when the setup is non-trivial.
- Generators must be safe to run more than once.
- If a route mount is required, either generate it carefully or document it explicitly.
- If migrations are required, treat them as host-owned changes and copy them rather than applying them automatically.

## Generator Checklist

- Files generated into the correct host paths
- No duplicate inserts on rerun
- Sensible defaults that are easy to edit
- Clear output telling the user what remains manual
- Tests that cover generated content and rerun behavior

## Common Patterns

- `install` generator for initializer plus route guidance
- `install:migrations` or copied migrations for persistence changes
- optional feature-specific generators for admin, jobs, or assets

## Review Triggers

Flag these problems:

- setup steps hidden inside initializers
- migrations implied but not installed
- route modifications that are brittle or duplicated
- generators that assume a specific host app layout without checks
- install docs that do not match the generator behavior

## Examples

**Idempotent install generator (only inject once):**

```ruby
# lib/generators/my_engine/install/install_generator.rb
module MyEngine
  class InstallGenerator < Rails::Generators::Base
    def inject_initializer
      return if initializer_already_present?
      create_file 'config/initializers/my_engine.rb', <<~RUBY
        MyEngine.configure do |config|
          config.user_class = "User"
        end
      RUBY
    end

    def inject_routes
      route "mount MyEngine::Engine, at: '/admin'"
    end

    private

    def initializer_already_present?
      File.exist?(File.join(destination_root, 'config/initializers/my_engine.rb'))
    end
  end
end
```

**Generator test (idempotency):**

```ruby
it 'does not duplicate route on second run' do
  run_generator
  run_generator
  expect(File.read('config/routes.rb')).to have_content('mount MyEngine::Engine', 1)
end
```

## Output Style

When asked to implement setup flow:

1. State what must be generated versus manually configured.
2. Implement the install path with idempotency in mind.
3. Add generator tests and concise user-facing instructions.

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When designing the engine structure that installers will configure |
| rails-engine-docs | When documenting install steps or upgrade instructions |
| rails-engine-testing | When adding generator specs or dummy-app install coverage |
