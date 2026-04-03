# frozen_string_literal: true

require 'json'
require_relative './response'
require_relative './resource_locator'

module MCP
  # Dispatches JSON MCP method names (+ListResources+, +ReadResource+) to the resource layer and wraps {MCP::Response}.
  class RequestHandler
    # Maps JSON +method+ string to a private handler symbol.
    METHOD_DISPATCH = {
      'ListResources' => :handle_list_resources,
      'ReadResource' => :handle_read_resource
    }.freeze

    # @param resource_locator [MCP::ResourceLocator] Source for listing and reading skill resources.
    def initialize(resource_locator:)
      @resource_locator = resource_locator
    end

    # Normalizes input, routes by +method+, and returns a response hash suitable for JSON serialization.
    # @note +JSON::ParserError+, +ArgumentError+ from coercion, and other +StandardError+ subclasses are rescued
    #   and returned as {MCP::Response.error}; they are not re-raised.
    # @param raw_request [Hash, String] Parsed request hash, or a JSON string (parsed with +JSON.parse+).
    # @return [Hash] Success or error envelope from {MCP::Response.success} / {MCP::Response.error}.
    def handle(raw_request)
      request_id = nil
      request, request_id = normalize_request(raw_request)

      method_name = request['method']
      handler_method = METHOD_DISPATCH[method_name]

      if handler_method
        send(handler_method, request, request_id)
      else
        MCP::Response.error("Unknown method: #{method_name}", code: 400, request_id: request_id)
      end
    rescue JSON::ParserError => e
      MCP::Response.error("JSON Parse Error: #{e.message}", code: 400, request_id: request_id)
    rescue StandardError => e
      MCP::Response.error("Server Error: #{e.message}", code: 500, request_id: request_id)
    end

    private

    # Coerces a string body to a Hash and extracts +requestId+ when present.
    # @param raw_request [Hash, String]
    # @return [Array(Hash, String, nil)] +[parsed_request, request_id]+
    # @raise [ArgumentError] if +raw_request+ is neither a Hash nor a String
    # @raise [JSON::ParserError] if +raw_request+ is a String and not valid JSON
    def normalize_request(raw_request)
      parsed =
        case raw_request
        when String
          JSON.parse(raw_request)
        when Hash
          raw_request
        else
          raise ArgumentError, "Request must be a Hash or JSON string (got #{raw_request.class})"
        end
      rid = parsed.is_a?(Hash) ? parsed['requestId'] : nil
      [parsed, rid]
    end

    # Handles the ListResources MCP method.
    def handle_list_resources(_request, request_id)
      resources = @resource_locator.list_skill_resources
      MCP::Response.success(resources, request_id: request_id)
    end

    # Handles the ReadResource MCP method.
    def handle_read_resource(request, request_id)
      uri = request.dig('params', 'uri')
      return MCP::Response.error('Missing URI for ReadResource', code: 400, request_id: request_id) unless uri

      begin
        content = @resource_locator.read_resource(uri)
        MCP::Response.success(content, request_id: request_id)
      rescue ArgumentError, Errno::ENOENT => e
        MCP::Response.error(e.message, code: 400, request_id: request_id)
      rescue StandardError => e
        MCP::Response.error("Failed to read resource: #{e.message}", code: 500, request_id: request_id)
      end
    end
  end
end
