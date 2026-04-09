# frozen_string_literal: true

module WeatherService
  # Manages OAuth client credentials flow and caches the bearer token
  # for the lifetime of the instance.
  #
  # @example
  #   auth = WeatherService::Auth.default
  #   token = auth.token  # fetches and caches the access token
  class Auth
    include HTTParty

    base_uri Rails.configuration.weather_service[:auth_base_uri] if defined?(Rails)

    DEFAULT_TIMEOUT = 30

    class Error < StandardError; end

    # Builds an Auth instance from application credentials.
    #
    # @return [Auth]
    def self.default
      new(
        client_id:     Rails.configuration.weather_service[:client_id],
        client_secret: Rails.configuration.weather_service[:client_secret]
      )
    end

    # @param client_id [String] OAuth client ID
    # @param client_secret [String] OAuth client secret
    # @param timeout [Integer] HTTP timeout in seconds
    def initialize(client_id:, client_secret:, timeout: DEFAULT_TIMEOUT)
      raise ArgumentError, "Missing required credentials" if [client_id, client_secret].any?(&:blank?)

      @client_id     = client_id
      @client_secret = client_secret
      @timeout       = timeout
      @token         = nil
    end

    # Returns a cached access token, fetching one if not yet obtained.
    #
    # @return [String] bearer access token
    # @raise [Auth::Error] if the OAuth request fails
    def token
      return @token if @token

      response = self.class.post(
        "/oauth/token",
        body:    { grant_type: "client_credentials", client_id: @client_id, client_secret: @client_secret },
        timeout: @timeout
      )

      raise Error, "Auth failed (#{response.code}): #{response.body}" unless response.success?

      @token = response.parsed_response["access_token"]
    end
  end
end
