---
name: rails-engine-compatibility
description: Use when maintaining compatibility for Rails engines across Rails and Ruby versions. Trigger words: Zeitwerk, autoloading, Rails upgrade, dependency bounds, gemspec, feature detection, CI matrix, reload safety, deprecated APIs, cross-version support.
---
# Rails Engine Compatibility

Use this skill when the task is to make an engine stable across framework versions and host environments.

Compatibility work should reduce surprises for host applications. Prefer explicit support targets over accidental compatibility.

## Quick Reference

| Compatibility Aspect | Check |
|----------------------|-------|
| Zeitwerk | File paths match constant names; no anonymous or root-level constants |
| Gemspec bounds | `add_dependency` and `required_ruby_version` match tested versions |
| Feature detection | Use `respond_to?`, `defined?`, or adapter seams instead of `Rails.version` |
| Test matrix | CI runs against each claimed Rails/Ruby combination |

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Hardcoding Rails version checks | Use feature detection or adapter seams; version branching is brittle and often wrong |
| Missing Zeitwerk compatibility | File paths must match constant names; mismatches break autoloading in Rails 6+ |
| No CI matrix | Claiming support for multiple versions without testing them leads to silent breakage |

## Red Flags

- No version bounds in gemspec
- Direct `Rails.version` checks instead of feature detection
- No reload safety for `to_prepare` or initializer hooks

## Core Checks

1. Define supported Ruby and Rails versions.
2. Check autoloading and Zeitwerk expectations.
3. Check initializer behavior across boot and reload.
4. Check dependency bounds in the gemspec.
5. Check optional integrations such as jobs, mailers, assets, and routes.
6. Verify the test matrix matches the claimed support policy.

## Important Areas

- Zeitwerk naming and file paths
- deprecated Rails APIs
- middleware or railtie hooks
- engine assets and precompile expectations
- migration compatibility
- configuration defaults that changed between Rails versions

## Rules

- Do not claim support for versions that are not tested.
- Keep dependency constraints honest and narrow enough to be meaningful.
- Prefer feature detection or adapter seams over version-specific branching when practical.
- If branching by version is necessary, isolate it and test both paths.

## Common Review Findings

- file naming incompatible with Zeitwerk
- broad gemspec constraints without matrix coverage
- deprecated initializer hooks
- assumptions tied to a single asset stack
- tests only on one Rails version while README claims many

## Examples

**Gemspec version bounds (honest, testable):**

```ruby
# Good: narrow and tested
spec.add_dependency "rails", ">= 7.0", "< 8.0"
spec.required_ruby_version = ">= 3.0"

# Bad: claims support without CI
# spec.add_dependency "rails", ">= 5.2"  # untested on 5.2/6.x
```

**Zeitwerk: file and constant must match:**

```ruby
# File: lib/my_engine/widget_policy.rb
# Good: constant matches path
module MyEngine
  class WidgetPolicy
  end
end

# Bad: will break with Zeitwerk
# class WidgetPolicy  # expected in widget_policy.rb at root
```

**Reload-safe hook:**

```ruby
# In engine.rb
config.to_prepare do
  MyEngine::Decorator.apply  # runs on each reload in dev
end
```

## Output Style

When asked to improve compatibility:

1. State the support matrix being targeted.
2. List the most likely breakpoints.
3. Make compatibility changes in isolated, testable seams.
4. Recommend matrix coverage if it does not exist.

## Integration

| Skill | When to chain |
|-------|----------------|
| rails-engine-testing | Test matrix setup, CI configuration, multi-version tests |
| rails-engine-author | Engine structure, host contract, namespace design |
| rails-engine-release | Versioning, changelog, upgrade notes for compatibility changes |
