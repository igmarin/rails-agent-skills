# WeatherService

Integration module for fetching weather readings from an external weather API.
Uses the **Auth → Client → Fetcher → Builder → Domain Entity** layered pattern.

## Configuration

Add the following to `config/secrets.yml` (or Rails encrypted credentials):

```yaml
weather_service:
  client_id: "<your-oauth-client-id>"
  client_secret: "<your-oauth-client-secret>"
  auth_base_uri: "https://auth.weather.example.com"
  host: "https://api.weather.example.com"
```

## Usage

### Fetch all readings for a region

```ruby
readings = WeatherService::Reading.find(region_id: "us-west-1")
# => [
#      { "temperature" => 22.5, "humidity" => 58.0, "wind_speed" => 14.2,
#        "region_id" => "us-west-1", "recorded_at" => "2024-01-15T12:00:00Z" },
#      ...
#    ]
```

### Fetch all current readings (default query, all regions)

```ruby
readings = WeatherService::Reading.fetcher.query
```

### Use a custom client (e.g. in tests or multi-tenant contexts)

```ruby
client   = WeatherService::Client.new(token: token, host: host)
readings = WeatherService::Reading.fetcher(client: client).query
```

## Response fields

Each reading hash contains the following whitelisted fields:

| Field | Type | Description |
|-------|------|-------------|
| `temperature` | Float | Temperature reading (°C) |
| `humidity` | Float | Relative humidity (%) |
| `wind_speed` | Float | Wind speed (km/h) |
| `region_id` | String | Geographic region identifier |
| `recorded_at` | String | ISO 8601 timestamp of the reading |

## Architecture

```
WeatherService::Auth
  └─ obtains and caches an OAuth bearer token (client credentials flow)

WeatherService::Client
  └─ sends authenticated HTTPS requests; retries on transient network failures;
     wraps all errors in Client::Error

WeatherService::Fetcher
  └─ executes queries via Client; follows pagination cursors automatically

WeatherService::Builder
  └─ transforms raw API payloads into attribute-filtered hashes (whitelist: ATTRIBUTES)

WeatherService::Reading  (domain entity)
  └─ wires the pipeline; exposes .find(region_id:) and .fetcher
```

## Error handling

All errors surface as `WeatherService::Client::Error` (a subclass of `StandardError`).

| Scenario | Error message pattern |
|----------|----------------------|
| OAuth token request fails | `Auth failed (401): ...` (wrapped by `Auth::Error`, re-raised) |
| HTTP 4xx / 5xx from the API | `API error 503: Service Unavailable` |
| Invalid JSON in response | `Invalid JSON response: ...` |
| Network / timeout (exhausted retries) | `Request failed: execution expired` |

### Rescue example

```ruby
begin
  readings = WeatherService::Reading.find(region_id: params[:region_id])
rescue WeatherService::Client::Error => e
  Rails.logger.error("[WeatherService] #{e.message}")
  render json: { error: "Weather data unavailable" }, status: :bad_gateway
end
```

## Testing

Specs live in `spec/services/weather_service/`. Use `instance_double` for unit
tests and hash factories for API response shapes — never make real HTTP calls in tests.

```ruby
let(:client) { instance_double(WeatherService::Client) }
let(:fetcher) { instance_double(WeatherService::Fetcher) }

before do
  allow(WeatherService::Fetcher).to receive(:new).and_return(fetcher)
  allow(fetcher).to receive(:execute_query).and_return([{ "region_id" => "us-west-1", ... }])
end
```
