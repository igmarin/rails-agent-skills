# frozen_string_literal: true

require_relative './response'
require_relative './resource_locator'

module MCP
  # Handles incoming MCP requests and dispatches them to the appropriate logic.
  class RequestHandler
    # A mapping of MCP method names to their corresponding handler methods.
    METHOD_DISPATCH = {
      'ListResources' => :handle_list_resources,
      'ReadResource' => :handle_read_resource
    }.freeze

    def initialize(resource_locator:)
      @resource_locator = resource_locator
    end

    # Processes a single MCP request by dispatching to the correct handler.
    # @param request [Hash] The parsed JSON request from the client.
    # @return [Hash] The JSON response to send back to the client.
    def handle(request)
      request_id = request['requestId']
      method_name = request['method']
      handler_method = METHOD_DISPATCH[method_name]

      if handler_method
        send(handler_method, request, request_id)
      else
        MCP::Response.error("Unknown method: \#{method_name}", code: 400, request_id: request_id)
      end
    rescue JSON::ParserError => e
      MCP::Response.error("JSON Parse Error: \#{e.message}", code: 400, request_id: request_id)
    rescue StandardError => e
      MCP::Response.error("Server Error: \#{e.message}", code: 500, request_id: request_id)
    end

    private

    # Handles the ListResources MCP method.
    def handle_list_resources(request, request_id)
      resources = @resource_locator.list_skill_resources
      MCP::Response.success({ resources: resources }, request_id: request_id)
    end

    # Handles the ReadResource MCP method.
    def handle_read_resource(request, request_id)
      uri = request.dig('params', 'uri')
      return MCP::Response.error('Missing URI for ReadResource', code: 400, request_id: request_id) unless uri

      begin
        content = @resource_locator.read_resource(uri)
        MCP::Response.success({ content: content }, request_id: request_id)
      rescue ArgumentError, Errno::ENOENT => e
        MCP::Response.error(e.message, code: 400, request_id: request_id)
      rescue StandardError => e
        MCP::Response.error("Failed to read resource: \#{e.message}", code: 500, request_id: request_id)
      end
    end
  end
end
