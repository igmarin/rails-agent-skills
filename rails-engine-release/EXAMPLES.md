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
