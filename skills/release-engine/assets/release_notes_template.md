# Release Notes Template

Version: vX.Y.Z
Date: YYYY-MM-DD

Summary
- One-line summary of changes in this release.

Highlights
- Bullet list of user-facing improvements
- Breaking changes (if any) with migration steps

Fixes
- Bug fixes and notable internal improvements (link to issues/PRs)

Developer Notes
- Any changes that affect integrators (configs, initializers, migrations)
- Deprecations and timeline for removal

Upgrade Steps
1. Upgrade gem version in Gemfile
2. Run `bundle update <engine>` in host app
3. If migrations exist, run `bundle exec rake <engine>:install:migrations` then `rails db:migrate`

Verification Status
- `bundle exec rspec`: PASS/FAIL
- Dummy app boot / mount smoke test: PASS/FAIL
- `gem build`: PASS/FAIL
- Gem contents inspected: PASS/FAIL
- `gem push --dry-run`: PASS/FAIL

Asset Usage
- `assets/release_notes_template.md` loaded for this GitHub release draft
- `assets/release_checklist.md` loaded for release quality gates, if applicable

Contact
- Maintainers and support channels
