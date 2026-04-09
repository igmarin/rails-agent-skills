# frozen_string_literal: true

module WeatherService
  # Transforms raw API response payloads into attribute-filtered hashes.
  # Only fields listed in the +attributes+ whitelist are kept.
  #
  # @example
  #   builder  = WeatherService::Builder.new(attributes: WeatherService::Reading::ATTRIBUTES)
  #   readings = builder.build(raw_api_response)
  class Builder
    # @param attributes [Array<String>] whitelist of field names to retain
    def initialize(attributes:)
      @attributes = attributes
    end

    # Builds an array of attribute-filtered hashes from a raw API response.
    #
    # Supports two response shapes:
    #   1. Columnar: { "schema" => { "columns" => [...] }, "rows" => [[...], ...] }
    #   2. Object array: { "data" => [{ field: value }, ...] }
    #
    # @param response [Hash] parsed JSON response from the weather API
    # @return [Array<Hash>] array of whitelisted attribute hashes
    def build(response)
      if response.key?("schema") && response.key?("rows")
        build_from_columnar(response)
      else
        build_from_objects(response)
      end
    end

    private

    def build_from_columnar(response)
      columns    = response.dig("schema", "columns") || []
      col_names  = columns.map { |c| c["name"] }
      rows       = response["rows"] || []

      rows.map do |row|
        record = col_names.each_with_index.with_object({}) { |(name, idx), h| h[name] = row[idx] }
        record.slice(*@attributes)
      end
    end

    def build_from_objects(response)
      records = response["data"] || []
      records.map { |record| record.slice(*@attributes) }
    end
  end
end
