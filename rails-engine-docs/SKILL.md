---
name: rails-engine-docs
description: >
  Use when writing or maintaining documentation for Rails engines. Trigger words:
  engine README, installation guide, configuration docs, mount instructions,
  migration notes, extension points, host integration examples, setup documentation.
---
# Rails Engine Docs

Use this skill when the task is to write or improve documentation for a Rails engine.

Engine docs should optimize for host-app adoption. Readers need to know what the engine does, how to install it, how to configure it, and where the boundaries are. All generated documentation (README, guides, examples) must be in **English** unless the user explicitly requests another language.

## Quick Reference

| Doc Section | Purpose |
|-------------|---------|
| Purpose | What the engine does and when to use it |
| Installation | Gemfile, bundle install, install generator |
| Mounting / initialization | Where and how to mount the engine (routes, initializer) |
| Configuration | Options, defaults, required vs optional |
| Usage examples | Copyable code showing typical workflows |
| Migrations / operational steps | Install migrations, run generators, one-time setup |
| Extension points | Adapters, callbacks, config blocks for customization |
| Development and testing | How to run tests, contribute, or develop locally |

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| No installation instructions | README must show the exact steps: add gem, bundle, run generator, mount |
| Missing mount instructions | Host apps need to know where to mount; implied mounting leads to confusion |
| No extension point docs | Configuration and adapters exist in code but readers cannot discover or use them |

## Red Flags

- README only says "add to Gemfile" with no further steps
- No configuration docs despite config options in code
- No migration notes when migrations or install generators exist

## Recommended README Shape

1. Purpose
2. Installation
3. Mounting or initialization
4. Configuration
5. Usage examples
6. Migrations or operational steps
7. Extension points
8. Development and testing

## Documentation Rules

- Document required host-app steps before optional customization.
- Keep examples copyable and close to real code.
- Show the minimum working install path first.
- If the engine assumes any host model, job backend, or auth integration, say so explicitly.
- Document upgrade-impacting changes when setup evolves.

## Must-Have Topics

- gem installation
- mount route or initializer setup
- configuration options with defaults
- migration/install generator steps
- supported Rails/Ruby versions if relevant
- testing or local development instructions when contributors are expected

## Common Documentation Gaps

- README explains the engine but not how to install it
- configuration options exist in code but not in docs
- route mounting is implied rather than shown
- migrations are required but not documented
- examples rely on host app context the reader cannot infer

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

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-author | Host-app contract, structure, extension points to document |
| rails-engine-installers | Install generators, setup steps to document |
| rails-engine-release | Changelog, upgrade notes, version documentation |
| api-postman-collection | When documenting or adding API endpoints (keep Postman collection in sync) |
