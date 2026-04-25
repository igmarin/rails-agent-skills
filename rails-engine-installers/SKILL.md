---
name: rails-engine-installers
license: MIT
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

## Constraints

| Constraint | Do | Avoid |
|---|---|---|
| Boot-time mutation | Configure only in initializers | Modifying host files or state at load time from `engine.rb` or initializers |
| Idempotency | Guard with `File.exist?` or Thor's `inject_into_file` with a marker | Overwriting or inserting routes, initializers, or migrations without checking |
| Migrations | Copy to host `db/migrate`; host runs them | Applying migrations automatically |
| Manual steps | Document rollback steps and required env vars | Leaving install gaps undocumented |
| Docs accuracy | Match install docs to generator behavior | Docs that describe a different install path than the generator produces |

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

See [EXAMPLES.md](./EXAMPLES.md) for a full generator class and complete spec suite.

## Generator Checklist

- [ ] Files created in correct host paths
- [ ] No duplicate inserts on rerun (validated manually and in specs)
- [ ] Sensible defaults that are easy to edit
- [ ] Clear output telling the user what remains manual
- [ ] Rollback steps documented
- [ ] Install docs match what the generator actually produces

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-author | When designing the engine structure that installers will configure |
| rails-engine-docs | When documenting install steps or upgrade instructions |
| rails-engine-testing | When adding generator specs or dummy-app install coverage |

## Assets

- [assets/README.md](assets/README.md)
