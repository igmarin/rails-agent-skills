---
name: upgrade-engine
license: MIT
description: >
  Use when making a Rails engine stable across Rails and Ruby versions — every claimed version MUST be in the CI matrix and pass (not just main), run `bundle exec rake zeitwerk:check` to verify file paths match constant names, configure Zeitwerk autoloading with explicit loader, update gemspec dependency bounds matching what CI actually tests (`>= 7.0, < 8.0`), replace `Rails.version` branching with feature detection (`defined?`/`respond_to?` checks), audit deprecated API usage, verify reload safety: check initializer behavior across boot and reload using `config.to_prepare` for reload-sensitive hooks, check optional integrations (jobs/mailers/assets/routes/generators/dummy-app mounts) per version even if absent. Trigger words: Zeitwerk, autoloading, Rails upgrade, gemspec, dependency bounds, CI matrix, feature detection, reload safety, deprecated APIs.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Upgrade Engine

**Core principle:** Every claimed Rails/Ruby version must be in the CI matrix. Prefer explicit support targets over accidental compatibility.

## Quick Reference

| Compatibility Aspect | Check |
|----------------------|-------|
| Zeitwerk | File paths match constant names; no anonymous or root-level constants |
| Gemspec bounds | `add_dependency` and `required_ruby_version` match tested versions |
| Feature detection | Use `respond_to?`, `defined?`, or adapter seams instead of `Rails.version` |
| Test matrix | CI runs against each claimed Rails/Ruby combination |
| Optional integrations | Jobs, mailers, assets, routes, and generators are checked on each version |

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
2. Run `bundle exec rake zeitwerk:check` — file paths must match constant names exactly.
3. Check initializer behavior across boot and reload — use `config.to_prepare` for reload-sensitive hooks.
4. Verify gemspec dependency bounds match tested versions: `spec.add_dependency "rails", ">= 7.0", "< 8.0"` — bounds must match what CI actually tests.
5. Check optional integrations (jobs, mailers, assets, routes, install generators, dummy-app mounts) per version. State the check even if an integration is absent.
6. CI matrix must run against each claimed Rails/Ruby combination:
```yaml
strategy:
  matrix:
    include:
      - { ruby: "3.2", rails: "7.1" }
      - { ruby: "3.3", rails: "7.2" }
```

## Extended Resources

**Pitfalls**
| Problem | Correct approach |
|---------|------------------|
| `Rails.version` branching | Use `respond_to?`, `defined?`, or adapter seams — version checks are brittle |
| Zeitwerk file/constant mismatch | File path must mirror constant name exactly — `my_engine/widget_policy.rb` → `MyEngine::WidgetPolicy` |
| Broad gemspec constraints without CI | Claiming `>= 5.2` without testing 5.2/6.x is silent incompatibility |
| No version bounds in gemspec | Unbounded constraints allow breaking upgrades into the engine |
| Reload-unsafe hooks at load time | Move to `config.to_prepare` — it runs on each reload in development |
| Tests only on one Rails version | CI matrix required before claiming multi-version support |

**Key Example: Feature Detection**
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
