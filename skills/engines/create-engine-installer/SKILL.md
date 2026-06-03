---
name: create-engine-installer
type: atomic
license: MIT
description: >
  Use when creating install generators or initializer installers for Rails engines — must use idiomatic Rails Thor generator commands, and follow the strict workflow: GENERATE (run generator against clean host app), VERIFY (check output files exist in correct host paths), RERUN (run a second time confirming idempotent output), TEST (write a minimal rerun spec that must always pass), and DOCUMENT (list what was generated versus what the user must do manually). Idempotent setup, host-app onboarding, and route mount setup. Trigger words: install generator, mountable engine setup, gem installation, engine onboarding, copy migrations, initializer generator.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Create Engine Installer

Use this skill when the task is to design or review how a host app installs and configures a Rails engine — generating initializers, copying migrations, mounting routes, or exposing a single install command.

## Quick Reference

| Component | Purpose |
|-----------|----------|
| Generator | Creates initializer, route mount, or setup files — must be idempotent |
| Migrations | Copies engine migrations into host `db/migrate` |
| Initializer | Provides configuration defaults; generated once, editable by host |
| Routes | Adds `mount Engine, at: '/path'`; checks for existing mount before injecting |

## Validation Workflow (HARD-GATE)

When building or reviewing an install generator, follow these steps in order. **DO NOT ship a generator without completing steps 3 and 4.**

1. **GENERATE**: Run the generator against a clean host app. Show command + terminal output labeled **Observed output** for the first run. Confirm files are created in correct host paths.
2. **VERIFY**: Check output files exist in the correct host paths. List shell commands confirming the initializer, routes, and migrations exist.
3. **RERUN**: Run the generator a second time; confirm no duplicate files, routes, or initializer blocks are inserted. Show command + terminal output labeled **Observed output** demonstrating idempotent behavior (skipping/conflict resolution). Use unique, scenario-specific values rather than copying verbatim from templates.
4. **TEST**: Cover both single-run and rerun behavior in generator specs (see spec template below). Confirm no duplicate inserts on rerun in specs.
5. **DOCUMENT**: List what was generated vs. what the user must do manually, including required env vars, rollback steps, and any install docs — verified against what the generator actually produces.

Key implementation rules:
- Configure only in initializers (avoid boot-time mutation).
- Document all required env vars alongside rollback steps.
- Use idiomatic Rails/Thor generator commands (inheriting from `Rails::Generators::Base`, with `source_root`, `desc`, etc.).
- Provide sensible defaults that are easy to edit.

**Idempotency guards — check before creating or injecting:**

```ruby
def create_initializer
  return if File.exist?(File.join(destination_root, 'config/initializers/my_engine.rb'))
  create_file 'config/initializers/my_engine.rb', <<~RUBY
    MyEngine.configure do |config|
      config.user_class = "User"
    end
  RUBY
end

def mount_route
  # inject_into_file with force: false skips insertion if sentinel already present
  inject_into_file 'config/routes.rb',
    "\n  mount MyEngine::Engine, at: '/admin'\n",
    after: "Rails.application.routes.draw do",
    force: false
end
```

**Minimal rerun spec (must always pass):**

```ruby
it 'does not duplicate the route mount on rerun' do
  2.times { run_generator }
  expect(File.read(file('config/routes.rb')).scan('mount MyEngine::Engine').size).to eq(1)
end
```

## Integration

| Skill | When to chain |
|-------|---------------|
| [create-engine](../create-engine/SKILL.md) | When designing the engine structure that installers will configure |
| [document-engine](../document-engine/SKILL.md) | When documenting install steps or upgrade instructions |
| [test-engine](../test-engine/SKILL.md) | When adding generator specs or dummy-app install coverage |
