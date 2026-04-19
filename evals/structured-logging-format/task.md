# Payment Processing Service with Observability

## Problem/Feature Description

The infrastructure team at Meridian Commerce has rolled out a centralized log aggregation platform (Datadog) that ingests all Rails logger output. The platform enables engineers to build dashboards, set up alerts, and filter log streams by specific field values — but only when log entries carry structured metadata. The ops team has been unable to build meaningful payment dashboards because the existing PaymentProcessor service emits freeform log messages that cannot be queried by payment ID, user ID, or event type.

Your task is to build a fresh `PaymentProcessor` service that handles the payment lifecycle (authorization, capture, and failure handling) and emits log entries that the ops team can actually use for monitoring and debugging. The service does not need to integrate with a real payment gateway — use stub logic that simulates success and failure paths.

## Output Specification

Create the following file:

- `app/services/payment_processor.rb` — the service class, including all logging calls

The service should handle at minimum:
- A successful payment authorization and capture path
- A failure path (e.g., insufficient funds or gateway error)
- At least four `Rails.logger` calls covering different stages and outcomes

Do not create specs or migrations. Just the service file.
