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

Contact
- Maintainers and support channels
