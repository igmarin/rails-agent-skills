# Payment Processor Service Spec

## Problem/Feature Description

The engineering team has built a new `Payments::ChargeCard` service object that handles credit card charging via a third-party payment gateway. The service lives at `app/services/payments/charge_card.rb` and exposes a `.call` class method that takes `user:`, `amount_cents:`, and `card_token:` as keyword arguments. It returns a hash with `:success` (boolean) and `:response` (containing `:transaction_id` on success, or `:error` hash with `:message` on failure).

Currently the service has no test coverage, which is blocking a code review approval. The team needs a thorough RSpec spec written that covers the happy path (successful charge) and two failure cases: when the payment gateway returns a decline, and when an invalid card token is provided. The service calls `StripeClient.charge` as its external dependency.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file (with its intended file path shown at the top)
- TDD proof showing the RED failure before implementation and GREEN passing output after
- A self-audit checklist confirming spec conventions are followed
- A section documenting which reference assets from the skill were consulted
