# frozen_string_literal: true

module MCP
  # Standardizes MCP server responses.
  class Response
    def self.success(content, request_id: nil)
      { content: content, requestId: request_id }
    end

    def self.error(message, code: 500, request_id: nil)
      { error: { message: message, code: code }, requestId: request_id }
    end
  end
end
