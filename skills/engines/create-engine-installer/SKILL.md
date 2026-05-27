---
name: create-engine-installer
license: MIT
description: >
  Use when creating install generators or initializer installers for Rails engines — GENERATE: run the generator against a clean host app, VERIFY: check output files exist in correct host paths, RERUN: run the generator a second time confirming idempotent output (no duplicate routes/initializers, write a minimal rerun spec that must always pass), DOCUMENT: list what was generated vs what the user must do manually (mount route in host routes, run install, configure initializers), use idiomatic Rails Thor generator commands, copied migrations must be safe to run multiple times. Covers idempotent setup, host-app onboarding, route mount setup. Trigger words: install generator, mountable engine setup, gem installation, engine onboarding, copy migrations, initializer generator.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Create Engine Installer

Use this skill when the task is to design or review how a host app installs and configures a Rails engine — generating initializers, copying migrations, mounting routes, or exposing a single install command.

## Quick Reference

| Component | Purpose | Key constraint |
|-----------|---------|----------------|
| Generator | Creates initializer, route mount, or setup files | Must be idempotent — safe to rerun |
| Migrations | Copies engine migrations into host `db/migrate` | Host owns and runs them; never apply automatically |
| Initializer | Provides configuration defaults | Generated once, editable by host |
| Routes | Adds `mount Engine, at: '/path'` | Check for existing mount before injecting |

## HARD-GATE

```text
Validation Workflow WHEN building or reviewing an install generator:

1. GENERATE:  Run the generator against a clean host app
2. VERIFY:    Check output files exist in the correct host paths
3. RERUN:     Run the generator a second time
4. CONFIRM:   No duplicate files, routes, or initializer blocks inserted
5. DOCUMENT:  List what was generated vs. what the user must do manually
6. TEST:      Cover both single-run and rerun behavior in generator specs

DO NOT ship a generator without completing steps 3 and 4.
```

## Core Process

1. Ensure setup is explicit, repeatable, and safe to rerun.
2. Configure only in initializers (avoid boot-time mutation).
3. Guard operations with `File.exist?` or Thor's `inject_into_file` with a marker to ensure idempotency.
4. Copy migrations to host `db/migrate`; let the host run them.
5. Document rollback steps and required env vars.
6. Ensure install docs match generator behavior exactly.

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

## Extended Resources

**Generator Checklist**
- [ ] Files created in correct host paths
- [ ] No duplicate inserts on rerun (validated manually and in specs)
- [ ] Sensible defaults that are easy to edit
- [ ] Clear output telling the user what remains manual
- [ ] Rollback steps documented
- [ ] Install docs match what the generator actually produces

- [EXAMPLES.md](./EXAMPLES.md) (full generator class and complete spec suite)
- [assets/README.md](assets/README.md)

## Output Style

1. Use idiomatic Rails Thor generator commands.
2. Provide clear, minimal, idempotent generator code.
3. Output clear terminal instructions for the user.
4. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| create-engine | When designing the engine structure that installers will configure |
| document-engine | When documenting install steps or upgrade instructions |
| test-engine | When adding generator specs or dummy-app install coverage |
