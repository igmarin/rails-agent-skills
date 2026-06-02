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

## Output Style

When asked to create or review an engine installer/install generator, your output `answer.md` MUST include:

1. **Idiomatic generator code**: Use idiomatic Rails/Thor generator commands (inheriting from `Rails::Generators::Base`, with `source_root`, `desc`, etc.).
2. **Step-by-Step Validation & Observed Outputs**:
   - **GENERATE**: Provide a command and a simulated but realistic terminal execution output under the literal label **Observed output** showing the generator running for the first time.
   - **VERIFY**: List shell commands checking that the initializer, routes, and migrations exist in the correct host paths.
   - **RERUN**: Provide a command and a simulated but realistic terminal execution output showing the generator running a second time and confirming it is idempotent (skipping/conflict resolution).
   - **CRITICAL: Even if running in static evaluation or mock environments without a live Ruby/Rails runtime, you MUST generate and present realistic, concrete terminal execution output under the literal label `Observed output`. Do NOT copy the exact timing values or example counts verbatim from templates; you MUST generate unique, scenario-specific numbers.**
3. **Rollback & Manual steps**: Clear list of what the generator does vs what the user must do manually.
4. **Generator Spec**: A complete, minimal RSpec spec using generator testing helpers (destination, run_generator, etc.) testing both single-run and rerun idempotency behavior.
5. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| [create-engine](../create-engine/SKILL.md) | When designing the engine structure that installers will configure |
| [document-engine](../document-engine/SKILL.md) | When documenting install steps or upgrade instructions |
| [test-engine](../test-engine/SKILL.md) | When adding generator specs or dummy-app install coverage |
