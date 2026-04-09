# frozen_string_literal: true

module WeatherService
  # Orchestrates paginated queries against the weather API.
  # Delegates HTTP work to {Client} and response transformation to {Builder}.
  #
  # @example
  #   fetcher = WeatherService::Reading.fetcher
  #   readings = fetcher.execute_query({ region_id: "us-west-1" })
  class Fetcher
    MAX_RETRIES = 3
    RETRY_DELAY_IN_SECONDS = 2

    # @param client [Client] the HTTP client to use
    # @param data_builder [Builder] transforms raw responses into attribute hashes
    # @param default_query [Hash] default query payload
    def initialize(client, data_builder:, default_query:)
      @client        = client
      @data_builder  = data_builder
      @default_query = default_query
    end

    # Executes the given query (or default) and returns transformed records.
    # Follows pagination cursors when present, accumulating all pages.
    #
    # @param query [Hash] request payload; defaults to the constructor's default_query
    # @return [Array<Hash>] array of attribute-filtered record hashes
    # @raise [Client::Error] on request failure
    def execute_query(query = @default_query)
      results = []
      current_query = query.dup

      loop do
        raw_response = @client.execute_query(current_query)
        results.concat(@data_builder.build(raw_response))

        next_cursor = raw_response.dig("pagination", "next_cursor")
        break if next_cursor.nil? || next_cursor.empty?

        current_query = current_query.merge("cursor" => next_cursor)
      end

      results
    end
    alias query execute_query
  end
end
