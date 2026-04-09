# frozen_string_literal: true

module WeatherService
  # Domain entity representing a weather reading for a geographic region.
  # Wires the Auth → Client → Fetcher → Builder pipeline.
  #
  # @example Fetch all readings for a region
  #   readings = WeatherService::Reading.find(region_id: "us-west-1")
  #
  # @example Fetch all current readings (default query)
  #   readings = WeatherService::Reading.fetcher.query
  class Reading
    ATTRIBUTES = %w[temperature humidity wind_speed region_id recorded_at].freeze

    DEFAULT_QUERY = { limit: 100 }.freeze
    SEARCH_QUERY  = { region_id: nil, limit: 100 }.freeze

    # Builds a fully wired Fetcher for Reading.
    #
    # @param client [Client] optional client override (defaults to Client.default)
    # @return [Fetcher]
    def self.fetcher(client: Client.default)
      data_builder = Builder.new(attributes: ATTRIBUTES)
      Fetcher.new(client, data_builder: data_builder, default_query: DEFAULT_QUERY)
    end

    # Fetches all weather readings for the given region.
    #
    # @param region_id [String] the geographic region identifier
    # @return [Array<Hash>] array of reading attribute hashes
    # @raise [Client::Error] on request failure
    def self.find(region_id:)
      query = SEARCH_QUERY.merge(region_id: region_id)
      fetcher.execute_query(query)
    end
  end
end
