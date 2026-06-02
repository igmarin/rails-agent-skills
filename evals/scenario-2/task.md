# Order Notification Background Job Spec

## Problem/Feature Description

The fulfillment team has a service `Orders::FulfillOrder` (`app/services/orders/fulfill_order.rb`) that, when called with an `order_id`, marks the order as fulfilled in the database and enqueues a `CustomerNotificationJob` to send a confirmation email. The job is defined at `app/jobs/customer_notification_job.rb`.

A previous developer tested the email-sending behavior by actually running the job inline during tests, which caused the test suite to become slow and dependent on the email delivery system. The team wants a proper spec for `Orders::FulfillOrder` that verifies the job gets enqueued without running it, using the Rails test adapter approach. The spec should cover: successful fulfillment, and the case where the order cannot be found.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file with its intended path
- TDD proof with concrete RED/GREEN terminal output
- A note on why the spec type was chosen over alternatives
- Self-audit and resource loading sections
