# frozen_string_literal: true

module MCP
  # Builds wire-format response hashes for the MCP-style JSON protocol used by this server.
  class Response
    # Builds a successful response envelope.
    # @param content [Object] Payload for the client (e.g. resource list Array, or file String for reads).
    # @param request_id [String, nil] Correlates to the incoming request's +requestId+, if present.
    # @return [Hash] Hash with +:content+ and +:requestId+ keys (+requestId+ matches JSON key +requestId+).
    def self.success(content, request_id: nil)
      { content: content, requestId: request_id }
    end

    # Builds an error response envelope.
    # @param message [String] Human-readable error description.
    # @param code [Integer] Application-specific error code (e.g. 400, 500).
    # @param request_id [String, nil] Correlates to the incoming request's +requestId+, if present.
    # @return [Hash] Hash with +:error+ (+:message+, +:code+) and +:requestId+ keys.
    def self.error(message, code: 500, request_id: nil)
      { error: { message: message, code: code }, requestId: request_id }
    end
  end
end
