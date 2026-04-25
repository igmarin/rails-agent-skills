---
name: rails-engine-release
description: >
  Use when preparing a Rails engine gem release. Generates CHANGELOG.md entries,
  produces step-by-step upgrade notes for host apps, sets semantic version constants,
  verifies gemspec metadata, confirms test suite passes, and sequences gem build
  and publish commands. Trigger words: version bump, changelog, deprecation,
  gemspec, upgrade, migration guide, release, publish gem, ship gem, verify gemspec,
  test suite.
license: MIT
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

1. Confirm scope and compatibility impact — is this patch, minor, or major?
2. Run full test suite: `bundle exec rspec`. Fix all failures before proceeding.
3. Set the version bump — update the version constant once: `module MyEngine; VERSION = "1.2.0"; end` in `lib/my_engine/version.rb`.
4. Update changelog and upgrade notes.
5. Verify gemspec metadata and dependencies match tested Rails/Ruby versions.
6. Dry-run the gem build: `gem build *.gemspec && gem push --dry-run *.gem`. Verify contents.
7. Confirm installation docs and README match the release — update if needed.
8. Publish: `gem push *.gem`.

## Versioning Rules

- **Patch:** bug fixes and internal changes without public behavior breakage.
- **Minor:** backward-compatible features and new extension points.
- **Major:** breaking changes to API, setup, routes, migrations, configuration, or supported framework versions.

If the engine requires host changes during upgrade, document them explicitly even if the version bump is minor.

## Examples

```markdown
## [1.2.0] - 2024-03-15
### Added
- `widget_count` config option to limit dashboard widgets (default: 10).
### Changed
- Minimum Rails version is now 7.0.
```

See [EXAMPLES.md](./EXAMPLES.md) for a full changelog entry and upgrade note template.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/release_checklist.md](assets/release_checklist.md)** — Use when you need a detailed step-by-step verification checklist before finalizing the release
- **[assets/release_notes_template.md](assets/release_notes_template.md)** — Use when drafting GitHub release notes or long-form release announcements
- **[assets/examples.md](assets/examples.md)** — Reference for how to use the supporting templates

## Output Style

When asked to prepare a release, produce a release summary ready for team lead review, with code blocks for all file changes. It MUST include:

1. **Version bump recommendation** — New version (patch/minor/major) with explicit reasoning
2. **Version constant** — Updated `lib/<engine>/version.rb` with the new `VERSION = "x.y.z"`
3. **CHANGELOG entries** — User-facing changes under Added/Changed/Fixed/Deprecated headers
4. **Upgrade notes** — Steps host apps must take (config changes, migration steps, dependency updates)
5. **Gemspec verification** — Confirm metadata, files, and dependencies match tested Rails/Ruby versions
6. **Test suite status** — Confirm `bundle exec rspec` passes before proceeding to build
7. **Release blockers** — Open issues preventing release, or explicitly state "No blockers"

## Integration

| Skill | When to chain |
|-------|---------------|
| rails-engine-docs | When updating README, setup instructions, or API docs for the release |
| rails-engine-compatibility | When verifying Rails/Ruby version support or deprecation impact |
| rails-engine-testing | When ensuring tests pass before release and match documented behavior |
