---
name: rails-engine-docs
license: MIT
description: >
  Use when writing or maintaining documentation for Rails engines. Generates README
  templates, writes installation and configuration guides, documents mount points,
  extension APIs, and migration notes for host-app adoption. Trigger words: engine
  README, installation guide, configuration docs, mount instructions, migration notes,
  extension points, host integration examples, setup documentation.
license: MIT
---
# Rails Engine Docs

Use this skill when the task is to write or improve documentation for a Rails engine.

Engine docs should optimize for host-app adoption. Readers need to know what the engine does, how to install it, how to configure it, and where the boundaries are. All generated documentation (README, guides, examples) must be in **English** unless the user explicitly requests another language.

## Recommended README Shape

1. Purpose — what the engine does and when to use it
2. Installation — gem add, bundle, run install generator
3. Mounting — explicit `mount MyEngine::Engine, at: '/path'` in routes
4. Configuration — all options with defaults, required vs optional
5. Usage examples — copyable code for typical workflows
6. Migrations / operational steps — install generator, one-time setup
7. Extension points — adapters, callbacks, config blocks
8. Development and testing — how to run tests or contribute

## Documentation Rules

- Document required host-app steps before optional customization.
- Keep examples copyable and close to real code.
- Show the minimum working install path first.
- If the engine assumes any host model, job backend, or auth integration, say so explicitly.
- Document upgrade-impacting changes when setup evolves.

## Documentation Gaps to Check

See [CHECKLIST.md](./CHECKLIST.md) for the full gap checklist. Critical gaps: installation steps, all config options with defaults, explicit mount path, migration timing, host model/auth assumptions.

## Examples

**README snippet (install + mount):**

```markdown
## Installation

Add to your Gemfile:

    gem 'my_engine'

Run:

    bundle install
    rails generate my_engine:install

This creates `config/initializers/my_engine.rb`. Mount the engine in `config/routes.rb`:

    mount MyEngine::Engine, at: '/admin'
```

**Configuration section:**

```markdown
## Configuration

In `config/initializers/my_engine.rb`:

    MyEngine.configure do |config|
      config.user_class = "User"       # required: host model for current user
      config.widget_count = 10         # optional, default 10
    end
```

## Output Style

When asked to write docs:

1. Start with the minimum install path.
2. Show one realistic configuration example.
3. Document operational steps explicitly.
4. Keep sections short and task-oriented.
5. Check each row in the Documentation Gaps checklist — if any is missing, fill it and re-check before finalizing.

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-author | Host-app contract, structure, extension points to document |
| rails-engine-installers | Install generators, setup steps to document |
| rails-engine-release | Changelog, upgrade notes, version documentation |
| api-rest-collection | When documenting or adding API endpoints (keep Postman collection in sync) |

## Assets

- [assets/configuration.md](assets/configuration.md)
- [assets/examples.md](assets/examples.md)
- [assets/installation.md](assets/installation.md)
