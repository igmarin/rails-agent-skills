# Currency Exchange Rate Fetcher Spec

## Problem/Feature Description

The finance team uses a `Currencies::FetchExchangeRate` service (`app/services/currencies/fetch_exchange_rate.rb`) that fetches live currency exchange rates from an external REST API (`ExchangeRateApi`). The service calls `ExchangeRateApi.get_rate(from:, to:)` and returns the standard `{ success:, response: }` hash. On success, `response[:rate]` contains a float. On failure (network error or API error), `response[:error][:message]` contains a description.

A previous developer wrote the spec without any HTTP stubbing, which caused the CI pipeline to fail whenever the external API was rate-limited or unreachable. The team now needs a properly isolated spec that will pass consistently in any environment, including CI, with no internet access.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file (with path)
- TDD proof with concrete RED/GREEN output
- Self-audit and resource loading sections
