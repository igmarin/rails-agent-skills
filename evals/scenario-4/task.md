# Webhook Receiver Endpoint Spec

## Problem/Feature Description

The integrations team has built a `POST /webhooks/github` endpoint that receives GitHub push events and triggers a `RepositorySync` background job. The controller validates the webhook signature using a secret (`GITHUB_WEBHOOK_SECRET`) from environment config and returns 200 on success, 401 when the signature is invalid, and 422 when the payload is malformed. The controller calls `GithubWebhookVerifier.verify(request)` to validate the signature.

The team is about to release this integration and needs a comprehensive RSpec spec that covers all three response scenarios. The spec must not make real HTTP calls to GitHub's API during testing.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file with its intended path shown
- TDD proof with concrete terminal output for RED and GREEN states
- Explanation of the spec type chosen and why it's appropriate
- Self-audit and resource loading sections
