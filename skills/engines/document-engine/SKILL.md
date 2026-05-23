---
name: document-engine
license: MIT
description: >
  Use when writing or maintaining documentation for Rails engines. Generates README
  templates, writes installation and configuration guides, documents mount points,
  extension APIs, and migration notes for host-app adoption. Trigger words: engine
  README, installation guide, configuration docs, mount instructions, migration notes,
  extension points, host integration examples, setup documentation.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Document Engine

Use this skill when writing or maintaining documentation for Rails engines.

## Quick Reference

| Section | Focus |
|---------|-------|
| Installation | gem add, bundle, run install generator |
| Mounting | explicit `mount MyEngine::Engine, at: '/path'` in routes |
| Configuration | all options with defaults, required vs optional |
| Usage | copyable code for typical workflows |
| Migrations | install generator, one-time setup |

## Core Process & Constraints

1. Show the minimum working install path first — before any optional customization.
2. Keep examples copyable and close to real code.
3. If the engine assumes any host model, job backend, or auth integration, state it explicitly.
4. Document all configuration options with defaults (required vs optional).
5. Document upgrade-impacting changes when setup evolves.

> **Hard gate:** All generated documentation MUST satisfy points 1, 3, and 4 above before proceeding to optional sections.

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

## Extended Resources

See [CHECKLIST.md](./CHECKLIST.md) for the full recommended README shape and documentation gap checklist. Critical gaps tracked there: installation steps, all config options with defaults, explicit mount path, migration timing, host model/auth assumptions.

- [assets/configuration.md](assets/configuration.md) — detailed config option catalog with type info, validation rules, and all supported defaults
- [assets/examples.md](assets/examples.md) — realistic end-to-end usage examples covering common host-app integration workflows
- [assets/installation.md](assets/installation.md) — step-by-step install and generator reference including post-install setup tasks

## Output Style

1. Start with the minimum install path.
2. Show one realistic configuration example.
3. Document operational steps explicitly.
4. Keep sections short and task-oriented.
5. Validate against CHECKLIST.md: a checklist item **passes** when the docs contain a corresponding section with at least one copyable code example or explicit prose statement. A checklist item **fails** when the section is absent, incomplete, or lacks a concrete example. For each failing item: add the missing section or example, then re-run the checklist from the top. Do not finalize until all critical items pass.
6. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| create-engine | Host-app contract, structure, extension points to document |
| create-engine-installer | Install generators, setup steps to document |
| release-engine | Changelog, upgrade notes, version documentation |
| generate-api-collection | When documenting or adding API endpoints (keep Postman collection in sync) |
