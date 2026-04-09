# Subscription Cancellation Service

## Problem/Feature Description

A SaaS platform allows users to cancel their subscriptions from their account settings. The current cancellation logic is sprawled across a controller action: it updates the subscription record, schedules a grace-period email, and records a cancellation audit entry — all inline in the controller. The team has decided to extract this into a proper service layer so the logic can be tested in isolation and reused from an admin dashboard and an API endpoint.

Your job is to write a Ruby service that handles subscription cancellation for a given user. The service receives a user ID and a cancellation reason, looks up the active subscription, marks it as cancelled, and returns a structured result indicating whether the operation succeeded. If the user has no active subscription, or if the record cannot be saved, the service must return an appropriate failure result — it should never raise an exception back to its caller.

## Output Specification

Produce the following files:

- `app/services/<choose_appropriate_module>/<choose_appropriate_name>.rb` — the service implementation
- `spec/services/<mirrored_path>_spec.rb` — RSpec spec covering the success path, the "no active subscription" path, and a save-failure path

The spec file should follow standard RSpec conventions (`describe`, `context`, `let`, `.call`).

Do not create a Rails app scaffold — just write the two Ruby files with realistic content. Use `# TODO: integrate with actual ActiveRecord models` comments where you would normally call ActiveRecord, so the structure is clear without requiring a running Rails app.
