# frozen_string_literal: true

module WeatherService
  # Sends HTTP requests to the Weather Service API.
  # Wraps all HTTP and parsing errors in {Client::Error}.
  #
  # @example
  #   client = WeatherService::Client.default
  #   data   = client.execute_query({ region_id: "us-west-1" })
  class Client
    include HTTParty

    MISSING_CONFIGURATION_ERROR = "Missing required configuration"
    DEFAULT_TIMEOUT  = 30
    DEFAULT_RETRIES  = 3
    RETRY_DELAY_SECS = 2

    # Raised when any API request fails (HTTP errors, network errors, parse errors).
    class Error < StandardError; end

    # Builds a Client from application configuration.
    #
    # @return [Client]
    def self.default
      new(
        token: Auth.default.token,
        host:  Rails.configuration.weather_service[:host]
      )
    end

    # @param token [String] bearer access token
    # @param host [String] base URL of the weather API (e.g. "https://api.weather.example.com")
    # @param timeout [Integer] HTTP timeout in seconds
    # @param max_retries [Integer] number of retry attempts on transient failure
    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)

      @token       = token
      @host        = host
      @timeout     = timeout
      @max_retries = max_retries
    end

    # Executes a query against the weather API with retry on transient failures.
    #
    # @param payload [Hash] request payload sent as JSON
    # @return [Hash] parsed JSON response body
    # @raise [Client::Error] on HTTP error, network failure, or invalid JSON
    def execute_query(payload)
      attempts = 0
      begin
        attempts += 1
        response = self.class.post(
          "#{@host}/api/weather/readings",
          headers: { "Authorization" => "Bearer #{@token}", "Content-Type" => "application/json" },
          body:    payload.to_json,
          timeout: @timeout
        )

        raise Error, "API error #{response.code}: #{response.body}" unless response.success?

        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise Error, "Invalid JSON response: #{e.message}"
      rescue HTTParty::Error, Errno::ECONNRESET, Net::OpenTimeout, Net::ReadTimeout => e
        raise Error, "Request failed: #{e.message}" if attempts >= @max_retries

        sleep(RETRY_DELAY_SECS * attempts)
        retry
      end
    end
  end
end
