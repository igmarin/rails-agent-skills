# Animal Shelter Data Export

## Problem/Feature Description

An animal shelter management company runs a Rails application that tracks animals across multiple shelter locations. They use a third-party data warehouse API (already integrated with Auth, Client, and Fetcher layers in the codebase) to store and query shelter records. A new requirement has arrived: the application needs to query `animals` records from the warehouse, exposing only the fields `tag_number`, `name`, `species_id`, `shelter_id`, and `intake_date`. There must also be a way to look up a single animal by its `tag_number`.

The existing integration module is `app/services/shelter_api/` and already contains `auth.rb`, `client.rb`, and `fetcher.rb`. You need to add the missing transformation and domain layers so the application can request and use animal data safely. A particular concern is that the warehouse API returns many more fields than are needed — leaking internal API schema details into the application domain would make refactoring painful.

## Output Specification

Add the Builder and Domain Entity layers to the existing `shelter_api` integration. Also write specs for the new components.

Expected output files:
- `app/services/shelter_api/builder.rb`
- `app/services/shelter_api/animal.rb` (domain entity)
- `spec/services/shelter_api/builder_spec.rb`
- `spec/services/shelter_api/animal_spec.rb`
- `spec/factories/shelter_api/animal_response.rb` (FactoryBot hash factory for API response test data)

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/services/shelter_api/client.rb ===============
module ShelterApi
  class Client
    include HTTParty

    MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
    DEFAULT_TIMEOUT = 30
    DEFAULT_RETRIES = 3

    class Error < StandardError; end

    def self.default
      token = Auth.default.token
      host = Rails.configuration.secrets[:shelter_api_host]
      new(token:, host:)
    end

    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)
      @token = token
      @host = host
      @timeout = timeout
      @max_retries = max_retries
    end

    def execute_query(payload)
      response = self.class.post(
        "#{@host}/api/query",
        headers: { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' },
        body: payload.to_json,
        timeout: @timeout
      )
      JSON.parse(response.body)
    rescue JSON::ParserError, HTTParty::Error => e
      raise Error, "Request failed: #{e.message}"
    end
  end
end

=============== FILE: app/services/shelter_api/fetcher.rb ===============
module ShelterApi
  class Fetcher
    MAX_RETRIES = 3
    RETRY_DELAY_IN_SECONDS = 2

    def initialize(client, data_builder:, default_query:)
      @client = client
      @data_builder = data_builder
      @default_query = default_query
    end

    def execute_query(query = @default_query)
      retries = 0
      begin
        raw_response = @client.execute_query(query)
        @data_builder.build(raw_response)
      rescue ShelterApi::Client::Error => e
        retries += 1
        if retries < MAX_RETRIES
          sleep(RETRY_DELAY_IN_SECONDS ** retries)
          retry
        end
        raise
      end
    end
    alias query execute_query
  end
end
