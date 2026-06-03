---
name: upgrade-engine
type: atomic
license: MIT
description: >
  Use when making a Rails engine stable across Rails and Ruby versions, performing a Rails upgrade, verifying gem compatibility, adding version support, or setting up cross-version testing — must ensure every claimed version is in the CI matrix and passes, run bundle exec rake zeitwerk:check verifying that file paths match constant names exactly, verify gemspec dependency bounds match what CI actually tests, check initializer reloading safety using config.to_prepare, and check and state the status of optional integrations per version even if they are absent. Zeitwerk autoloading, gemspec dependency bounds, CI matrix, Rails upgrade, gem compatibility, version support.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Upgrade Engine

**Core principle:** Every claimed Rails/Ruby version must be in the CI matrix. Prefer explicit support targets over accidental compatibility.

## HARD-GATE

```text
Before claiming support for a Rails/Ruby version:
  1. bundle exec rake zeitwerk:check        # verify autoloading on each version
  2. bundle exec rspec                       # full suite per matrix version
  3. CI matrix must pass — not just main Rails version

DO NOT ship compatibility changes without verifying both autoloading and full suite.
```

## Core Process

1. Define supported Ruby and Rails versions — state them in gemspec and README.
2. Run `bundle exec rake zeitwerk:check` — file paths must match constant names exactly (e.g. `my_engine/widget_policy.rb` → `MyEngine::WidgetPolicy`).
3. Check initializer behavior across boot and reload — use `config.to_prepare` for reload-sensitive hooks; hooks placed at load time are reload-unsafe in development.
4. Verify gemspec dependency bounds match tested versions: `spec.add_dependency "rails", ">= 7.0", "< 8.0"` — bounds must reflect what CI actually tests. Unbounded or overclaiming constraints (`>= 5.2` without testing 5.2/6.x) are silent incompatibilities.
5. Replace `Rails.version` branching with feature detection — version checks are brittle across patch releases:
```ruby
# ❌ Bad — brittle, wrong for patch versions
if Rails.version >= "7.0"
  config.active_support.cache_format_version = 7.0
end

# ✅ Good — detect the capability directly
if ActiveSupport::Cache.respond_to?(:format_version=)
  config.active_support.cache_format_version = 7.0
end
```
6. Check optional integrations (jobs, mailers, assets, routes, install generators, dummy-app mounts) per version. State the check even if an integration is absent.
7. CI matrix must run against each claimed Rails/Ruby combination:
```yaml
strategy:
  matrix:
    include:
      - { ruby: "3.2", rails: "7.1" }
      - { ruby: "3.3", rails: "7.2" }
```

## Extended Resources

- [assets/compatibility_matrix.md](assets/compatibility_matrix.md)
- [assets/zeitwerk_notes.md](assets/zeitwerk_notes.md)
- [EXAMPLES.md](EXAMPLES.md)

## Output Style

1. State the support matrix being targeted.
2. List the most likely breakpoints.
3. Make compatibility changes in isolated, testable seams.
4. Recommend matrix coverage if it does not exist.
5. Include an **Optional integration matrix** with rows for jobs, mailers, assets, routes, generators, and dummy app mount. For each row, state `present/absent`, the file path checked, and the per-version verification command.
6. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| test-engine | Test matrix setup, CI configuration, multi-version tests |
| create-engine | Engine structure, host contract, namespace design |
| release-engine | Versioning, changelog, upgrade notes for compatibility changes |
