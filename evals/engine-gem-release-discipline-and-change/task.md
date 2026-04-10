# Notifications Engine Release Preparation

## Problem/Feature Description

A team maintains `notifications_engine`, a Rails engine gem used by several internal applications to handle in-app and email notifications. The engine is installed as a gem dependency across three production Rails apps. The team has accumulated a set of changes on the main branch since the last release (v1.2.1) and is ready to cut a new release.

The changes include: a new `NotificationBatch` model that allows sending grouped notifications in a single transaction, a fix for a bug where notification timestamps were stored in local time instead of UTC, and a configuration option allowing host apps to set a custom notification expiry period. There are no changes that break the existing public API.

Before publishing the gem, the team needs all the release preparation steps completed and the release artifacts ready to review. The gem should not be published until everything is in order.

## Output Specification

Prepare the engine for release by completing all pre-publish steps. Update the necessary files in the engine directory, then produce a release summary saved as `release-summary.md` that the team lead can review before running the final publish command. The summary should include the recommended version number, reasoning for the bump level, and any open items or blockers.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: lib/notifications_engine/version.rb ===============
module NotificationsEngine
  VERSION = "1.2.1"
end

=============== FILE: CHANGELOG.md ===============
# Changelog

## [1.2.1] - 2025-11-03
### Fixed
- Corrected mailer template path resolution on Ruby 3.2

## [1.2.0] - 2025-09-14
### Added
- `Notification#mark_all_read!` bulk method
- Configurable delivery adapters (mailer, webhook, noop)

### Fixed
- Race condition in concurrent notification creation

## [1.1.0] - 2025-06-01
### Added
- Initial in-app notification support
- Polymorphic `notifiable` association

=============== FILE: notifications_engine.gemspec ===============
require_relative "lib/notifications_engine/version"

Gem::Specification.new do |spec|
  spec.name          = "notifications_engine"
  spec.version       = NotificationsEngine::VERSION
  spec.authors       = ["Platform Team"]
  spec.email         = ["platform@example.com"]
  spec.summary       = "Rails engine for in-app and email notifications"
  spec.description   = "Mountable Rails engine providing notification models, mailers, and delivery adapters"
  spec.homepage      = "https://github.com/example/notifications_engine"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot_rails"
end
