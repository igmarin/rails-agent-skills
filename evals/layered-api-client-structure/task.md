# Weather Data Pipeline Integration

## Problem/Feature Description

Your team maintains a Rails application for agricultural planning. A business stakeholder needs a new feature that pulls current and forecast weather data from an external weather service API. The API authenticates via OAuth (client credentials flow) and returns JSON payloads describing weather readings for geographic regions. It supports pagination and occasionally has transient network failures.

The engineering team has no existing pattern for integrating with external services, but needs something maintainable and testable as more third-party APIs will follow in the coming months. The feature must fetch `temperature`, `humidity`, `wind_speed`, `region_id`, and `recorded_at` fields for a given region. A search capability is needed to look up readings by region ID.

## Output Specification

Implement a complete Ruby module for the weather service integration under `app/services/weather_service/`. Include all necessary Ruby source files for the integration. Also produce a `README.md` inside the module directory documenting how to use the integration and how errors surface.

Expected output files:
- `app/services/weather_service/auth.rb`
- `app/services/weather_service/client.rb`
- `app/services/weather_service/fetcher.rb`
- `app/services/weather_service/builder.rb`
- `app/services/weather_service/reading.rb` (domain entity)
- `app/services/weather_service/README.md`
- `spec/services/weather_service/` — spec files for at least Auth, Client, and the domain entity
