# Subscription Expiry Model Spec

## Problem/Feature Description

The product team has added an `#expired?` method to the `Subscription` model (`app/models/subscription.rb`). The method returns `true` when the subscription's `end_date` is in the past relative to the current time. A subscription is also considered expired if it was explicitly cancelled early (via a `cancelled_at` timestamp). There's a third case: a subscription in a `trial` state expires after 14 days from its `trial_started_at` date, not `end_date`.

The QA team reported that a previous attempt at testing this logic set `end_date` to a hardcoded past date, which caused intermittent test failures whenever the system clock approached those dates. The team needs a proper RSpec model spec that avoids this problem and correctly covers all three expiry conditions, plus the non-expired happy path.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file (with the intended file path shown at the top)
- A brief explanation of why the chosen spec type fits the behavior being tested
- Concrete TDD proof showing the failing run before implementation and the passing run after
- A self-audit section confirming the spec follows all relevant conventions
