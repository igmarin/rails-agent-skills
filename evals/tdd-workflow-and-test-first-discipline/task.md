# Membership Tier Upgrade Service

## Problem/Feature Description

A fitness app allows users to upgrade their membership from Standard to Premium tier. The upgrade process involves validating the user's account status, applying the new tier to their profile, and recording the tier change in an audit log. The backend team has no existing service object for this — the feature needs to be built from scratch. There are no existing tests covering this area of the codebase.

Your task is to implement the `Memberships::UpgradeService` service object. Your tech lead has asked you to maintain a detailed `process_log.md` file that documents your development process chronologically as you work through the implementation — capturing what you produced at each stage, what you expected to happen at each point, and how your thinking evolved before you committed to writing any business logic.

## Output Specification

Produce the following files:

- `process_log.md` — A chronological record of your development process. Include clearly labelled sections for each phase of work. For each phase: describe what artifact you worked on, explain your reasoning for the order in which things were produced, note what you anticipated would happen before the business logic existed, and document any design decisions you locked down before writing the implementation code.
- `spec/services/memberships/upgrade_service_spec.rb` — RSpec spec for the service covering the success path and at least two failure cases
- `app/services/memberships/upgrade_service.rb` — The service implementation

The service should accept `user_id:` and `tier:` keyword parameters and return a structured result hash. Use `# TODO:` comments where you would normally call real database or external integrations (e.g. `# TODO: fetch user from database`). Do not create a full Rails app — just the service and spec files with realistic structure and content.
