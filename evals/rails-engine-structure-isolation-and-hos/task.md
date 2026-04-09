# Create an Audit Logging Rails Engine

## Problem/Feature Description

The platform team at Meridian Financial needs a reusable audit logging module that multiple internal Rails applications can mount. Every significant user action (record creation, updates, deletions) must be stored in an `audit_events` table with the actor, resource type, resource ID, action, and a JSON payload of changed attributes. The module needs to work across several host applications that each have their own `User` model (some call it `Employee`, some call it `User`), so the engine must not hard-code any host model class names.

The team intends to open-source this engine eventually, so clean boundaries between the engine and host apps are essential. Host applications should be able to configure the engine once in an initializer and have it ready to use. The audit table needs to live in each host app's database — migrations should not be applied automatically; they should be installable on-demand by the host app team.

Your task is to scaffold the minimal viable structure of a `AuditTrail` Rails engine. You do not need to implement full business logic — focus on the correct engine architecture and host integration design.

## Output Specification

Produce the following files (stubs with correct structure are acceptable, full implementations are welcome):

- `lib/audit_trail.rb` — root require file
- `lib/audit_trail/version.rb` — version constant
- `lib/audit_trail/configuration.rb` — Configuration class
- `lib/audit_trail/engine.rb` — Engine class
- `config/routes.rb` — engine routes (can be minimal/empty)
- `app/models/audit_trail/audit_event.rb` — AuditEvent model stub
- `db/migrate/TIMESTAMP_create_audit_trail_audit_events.rb` — migration file (use any timestamp)
- `spec/dummy/config/routes.rb` — dummy app routes mounting the engine
- `spec/requests/audit_trail/audit_events_spec.rb` — at least one request spec stub

Also produce:

- `host_contract.md` — a document describing: what the host app must configure, what the engine exposes, and which extension points are supported
