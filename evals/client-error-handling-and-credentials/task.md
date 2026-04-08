# Payments Provider API Client

## Problem/Feature Description

A fintech startup's Rails application needs to integrate with an external payments provider API. The API uses token-based authentication and exposes a JSON query endpoint. The engineering team is concerned about reliability: the payments provider has an SLA of 99.5% but has experienced brief outages in the past. The integration must handle authentication failures, malformed responses, network timeouts, and permanent errors (such as "payment not found") gracefully so that callers always receive structured errors rather than raw HTTP exceptions.

Credentials for the payments provider (API key, secret, account identifier) are already stored in the application's encrypted credentials. The host URL is also stored there. The team has strict security policies: no credentials may appear in source code and the integration must fail fast and loudly if configuration is missing at startup.

## Output Specification

Implement the authentication and HTTP client layers for the payments API integration, placed under `app/services/payments_provider/`. The implementation should handle at minimum: token acquisition and caching, HTTP request execution with proper error handling, timeout configuration, and retry behaviour for transient failures.

Expected output files:
- `app/services/payments_provider/auth.rb`
- `app/services/payments_provider/client.rb`
- `spec/services/payments_provider/client_spec.rb` — RSpec spec covering error scenarios (network failure, invalid JSON, missing config)
