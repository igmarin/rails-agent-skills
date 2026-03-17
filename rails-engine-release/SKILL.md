---
name: rails-engine-release
description: >
  Use when preparing a release, updating gemspec, writing changelog, handling
  deprecations, setting semantic version, planning upgrade notes, migration guide,
  or shipping a Rails engine as a gem. Trigger words: version bump, changelog,
  deprecation, gemspec, upgrade, migration guide, release.
---
# Rails Engine Release

Use this skill when the task is to ship a Rails engine as a gem or prepare a new version.

Release work should make upgrades predictable for host applications.

## Quick Reference

| Release Step | Action |
|--------------|--------|
| Version bump | Patch (bug fixes), Minor (new features), Major (breaking changes); update version constant once |
| Changelog | Document user-visible changes, not commits; group by Added/Changed/Fixed/Deprecated |
| Deprecations | Document removal plan and replacement; keep deprecated code for at least one minor cycle |
| Gemspec | Verify metadata, dependencies, and tested Rails/Ruby versions match constraints |

## HARD-GATE

**DO NOT release without updating CHANGELOG and version file.**

## Release Order

1. Confirm the scope of change.
2. Classify compatibility impact.
3. Set the version bump.
4. Update changelog and upgrade notes.
5. Verify gemspec metadata and dependencies.
6. Confirm tests and installation docs match the release.

## Versioning Rules

- Patch: bug fixes and internal changes without public behavior breakage.
- Minor: backward-compatible features and new extension points.
- Major: breaking changes to API, setup, routes, migrations, configuration, or supported framework versions.

If the engine requires host changes during upgrade, document them explicitly even if the version bump is minor.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| No upgrade notes for breaking changes | Host apps need step-by-step migration instructions; breaking changes without a guide cause production failures |
| Changelog lists commits not user impact | Users care what changed for them; avoid "Refactored X" or "Fixed Y" without explaining the effect |
| Version bump without changelog | Every release must document what changed; version number alone is meaningless |

## Red Flags

- Major version bump without migration guide or upgrade notes
- Deprecated code removed without a prior deprecation cycle and replacement path
- No gem push verification (e.g., dry-run or staging check before publishing)
- Changelog written from git log instead of user-facing impact

## Release Checklist

- gemspec metadata is current
- version constant updated once
- changelog reflects user-visible changes
- deprecations documented with removal plan
- migration or install changes called out
- README/setup instructions still accurate

## Upgrade Notes Should Include

- required host code changes
- migration steps
- configuration additions or removals
- compatibility changes for Rails/Ruby versions
- deprecation replacements

## Review Triggers

- silent breaking changes
- missing upgrade notes for migrations or configuration changes
- gemspec constraints inconsistent with tested versions
- changelog written from implementation details instead of user impact

## Examples

**Changelog entry (user impact, not implementation):**

```markdown
## [1.2.0] - 2024-03-15
### Added
- Configuration option `widget_count` to limit dashboard widgets (default: 10).
### Changed
- Minimum Rails version is now 7.0.
### Fixed
- Engine routes no longer conflict with host `root_path` when mounted at `/`.
```

**Upgrade note for host app:**

```markdown
### Upgrading from 1.1.x to 1.2.0
1. Run `bundle update my_engine`.
2. If you override the dashboard, add `MyEngine.config.widget_count = 10` to your initializer (optional).
3. Ensure Rails >= 7.0.
```

## Output Style

When asked to prepare a release:

1. Recommend the version bump and why.
2. Draft concise changelog entries.
3. Draft upgrade notes for host apps.
4. Call out any release blockers clearly.

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-docs | When updating README, setup instructions, or API docs for the release |
| rails-engine-compatibility | When verifying Rails/Ruby version support or deprecation impact |
| rails-engine-testing | When ensuring tests pass before release and match documented behavior |
