# Subscription Expiry and Protected Endpoint Specs

## Problem/Feature Description

A subscription-based API platform enforces two behaviors that currently have no test coverage:

**1. Subscription expiry logic**: Subscriptions become inactive exactly 30 days after activation. The `Subscription` model has an `#expired?` instance method that returns `true` when more than 30 days have passed since `activated_at` and `false` otherwise. The edge case at exactly 30 days needs to be clearly tested.

**2. Subscription-gated endpoints**: Three API endpoints — `GET /api/v1/reports`, `POST /api/v1/exports`, and `GET /api/v1/analytics` — all require an active subscription. A user without one receives a `403 Forbidden` response. A user with a valid subscription can access the endpoint normally. All three endpoints share this identical authorization behaviour.

You have been brought in to write spec coverage for both concerns. The team cares that the test suite is maintainable — repeated assertion patterns should be structured in a way that avoids duplication across the three endpoint specs.

Note: This project does NOT use test-prof.

## Output Specification

Produce spec files covering:
- The `Subscription#expired?` model behavior (correct expiry at the 30-day boundary, both sides)
- The authorization enforcement on all three endpoints

Place files at appropriate paths. The model and endpoint specs should each be in their own files. Any supporting spec infrastructure (shared behavior definitions) should be placed in a spec/support/ file. Do not create a full Rails app — just the spec files with realistic, well-structured content.
