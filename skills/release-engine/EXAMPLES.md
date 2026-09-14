# Release Examples

## Changelog Entry (user impact, not implementation)

```markdown
## [1.2.0] - 2024-03-15
### Added
- Configuration option `widget_count` to limit dashboard widgets (default: 10).
### Changed
- Minimum Rails version is now 7.0.
### Fixed
- Engine routes no longer conflict with host `root_path` when mounted at `/`.
```

## Upgrade Note for Host App

```markdown
### Upgrading from 1.1.x to 1.2.0
1. Run `bundle update my_engine`.
2. If you override the dashboard, add `MyEngine.config.widget_count = 10` to your initializer (optional).
3. Ensure Rails >= 7.0.
```

## GitHub Release Notes Draft

```markdown
## v1.2.0 - 2024-03-15

Summary
- Adds dashboard widget limits and updates the supported Rails range.

Highlights
- New `widget_count` configuration option.
- Host apps should verify Rails >= 7.0 before upgrading.

Upgrade Steps
1. Run `bundle update my_engine`.
2. Review initializer overrides.
3. Run the engine test suite and host smoke checks.

Verification Status
- `bundle exec rspec`: PASS
- `gem build`: PASS
- Gem contents inspected: PASS
- `gem push --dry-run`: PASS

Asset Usage
- Loaded `assets/release_notes_template.md` for this draft.
- Loaded `assets/release_checklist.md` for quality gates.
```
