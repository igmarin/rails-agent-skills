---
name: rails-engine-installers
description: >
  Use when creating install generators, copied migrations, or initializer
  installers for Rails engines. Covers idempotent setup tasks, host-app
  onboarding, and route mount setup. Trigger words: install generator,
  mountable engine setup, gem installation, engine onboarding,
  rails plugin installer, copy migrations, initializer generator,
  route mount setup, engine configuration generator.
---

# Rails Engine Installers

Use this skill when the task is to design or review how a host app installs and configures a Rails engine — generating initializers, copying migrations, mounting routes, or exposing a single install command.

**Core principle:** Setup must be explicit, repeatable, and safe to rerun. Never modify the host app at boot time.

## Installer Components

| Component | Purpose | Key constraint |
|-----------|---------|----------------|
| Generator | Creates initializer, route mount, or setup files | Must be idempotent — safe to rerun |
| Migrations | Copies engine migrations into host `db/migrate` | Host owns and runs them; never apply automatically |
| Initializer | Provides configuration defaults | Generated once, editable by host |
| Routes | Adds `mount Engine, at: '/path'` | Check for existing mount before injecting |

## HARD-GATE: Validation Workflow

```
WHEN building or reviewing an install generator:

1. GENERATE:  Run the generator against a clean host app
2. VERIFY:    Check output files exist in the correct host paths
3. RERUN:     Run the generator a second time
4. CONFIRM:   No duplicate files, routes, or initializer blocks inserted
5. DOCUMENT:  List what was generated vs. what the user must do manually
6. TEST:      Cover both single-run and rerun behavior in generator specs
```

**DO NOT ship a generator without completing steps 3 and 4.**

## Responsibilities

- Copy migrations into the host app (`db/migrate`)
- Generate an initializer with configuration defaults
- Add or document route mounting
- Seed optional setup files or permissions
- Expose a single install command for non-trivial setup

## Rules

- **Never** modify host files or state from initializers or `engine.rb` at load time.
- **Never** inject routes, initializer blocks, or migrations without checking for existing content first.
- Prefer generators over manual copy-paste instructions when setup is non-trivial.
- If migrations are required, copy them — do not apply them automatically.
- Document all steps that the generator cannot perform (manual rollback, required env vars).

## Common Mistakes

| Mistake | Correct approach |
|---------|-----------------|
| Overwriting host files without checking | Guard with `File.exist?` or Thor's `inject_into_file` with a marker check |
| Injecting routes unconditionally | Check routes file for existing mount before inserting |
| Hiding setup inside initializers | Use generator output; initializers should only configure, never set up |
| No rollback documentation | List manual undo steps in comments or README |

## Examples

**Idempotent install generator — only inject once:**

```ruby
# lib/generators/my_engine/install/install_generator.rb
module MyEngine
  class InstallGenerator < Rails::Generators::Base
    def create_initializer
      return if File.exist?(File.join(destination_root, 'config/initializers/my_engine.rb'))

      create_file 'config/initializers/my_engine.rb', <<~RUBY
        MyEngine.configure do |config|
          config.user_class = "User"
        end
      RUBY
    end

    def mount_route
      route "mount MyEngine::Engine, at: '/admin'"
    end
  end
end
```

**Generator test — covers single run and idempotent rerun:**

```ruby
RSpec.describe MyEngine::InstallGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)
  before { prepare_destination }

  it 'creates the initializer' do
    run_generator
    expect(file('config/initializers/my_engine.rb')).to exist
  end

  it 'does not duplicate the initializer on rerun' do
    2.times { run_generator }
    content = File.read(file('config/initializers/my_engine.rb'))
    expect(content.scan('MyEngine.configure').size).to eq(1)
  end

  it 'does not duplicate the route mount on rerun' do
    2.times { run_generator }
    expect(File.read(file('config/routes.rb')).scan('mount MyEngine::Engine').size).to eq(1)
  end
end
```

## Red Flags

- Generator overwrites host files without checking for existing content
- Install flow modifies boot sequence or runs code at require time
- Setup steps hidden inside initializers instead of explicit generator output
- Install docs do not match generator behavior

## Generator Checklist

- [ ] Files created in correct host paths
- [ ] No duplicate inserts on rerun (validated manually and in specs)
- [ ] Sensible defaults that are easy to edit
- [ ] Clear output telling the user what remains manual
- [ ] Rollback steps documented

## Output Style

When implementing an install flow:

1. Identify what must be generated vs. manually configured — state this explicitly.
2. Implement with idempotency guards for every file, route, and migration copy.
3. Add generator specs covering single-run and rerun behavior, then write concise user-facing setup instructions.

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When designing the engine structure that installers will configure |
| rails-engine-docs | When documenting install steps or upgrade instructions |
| rails-engine-testing | When adding generator specs or dummy-app install coverage |
