# frozen_string_literal: true

require_relative './request_handler'
require_relative './resource_locator'
require_relative './response'
require 'json'
require 'pathname'

module MCP
  # STDIN/STDOUT MCP-style JSON line server: reads one JSON object per line, writes one JSON response per line.
  class Server
    # Repository root (parent of +mcp_server/+), derived from this file's location (+lib/mcp/+ → three levels up).
    PROJECT_ROOT = Pathname.new(__dir__).join('..', '..', '..').realpath

    # Append-only log path under +mcp_server/mcp_server_log.log+ relative to {PROJECT_ROOT}.
    LOG_FILE = PROJECT_ROOT.join('mcp_server', 'mcp_server_log.log')

    # Builds a {ResourceLocator} for {PROJECT_ROOT} and a {RequestHandler} wired to it.
    # @return [void]
    def initialize
      resource_locator = ResourceLocator.new(PROJECT_ROOT)
      @request_handler = RequestHandler.new(resource_locator: resource_locator)
    end

    # Runs until EOF or blank line: each non-empty line is JSON-parsed and passed to {MCP::RequestHandler#handle}.
    # Responses and parse failures are written as single-line JSON to STDOUT; activity is appended to {LOG_FILE}.
    # @return [void]
    def start
      announce_startup
      log_message('MCP Ruby Server starting.')
      loop do
        request_line = ARGF.gets
        break if request_line.nil? || request_line.strip.empty?

        process_request_line(request_line)
      end
      log_message('MCP Ruby Server stopped.')
    end

    private

    # Prints startup hints to STDOUT (human-facing; not part of the JSON protocol).
    # @return [void]
    def announce_startup
      puts 'MCP Ruby Server starting.'
      puts "LOG_FILE: #{LOG_FILE}"
      puts 'To exit, press Ctrl+C'
    end

    # Parses +request_line+ as JSON, delegates to {MCP::RequestHandler#handle}, and emits the result or a JSON error line.
    # @param request_line [String] Single-line JSON request body.
    # @return [void]
    def process_request_line(request_line)
      log_message("Received request: #{request_line.strip}")
      emit_json_response(@request_handler.handle(JSON.parse(request_line)))
    rescue JSON::ParserError => e
      emit_json_error(e, code: 400, label: 'JSON Parse Error', log_prefix: 'Error processing request: ')
    rescue StandardError => e
      emit_json_error(e, code: 500, label: 'Server Error', log_prefix: 'Unhandled error in server loop: ')
    end

    # @param response [Hash] Handler result (already a Ruby Hash mirroring JSON shape).
    # @return [void]
    def emit_json_response(response)
      log_message("Sending response: #{response.to_json}")
      write_json_line(response)
    end

    # Writes {MCP::Response.error} as one JSON line and logs at +:error+ severity.
    # @param exception [Exception]
    # @param code [Integer] HTTP-style error code stored in the response (+:error+ +:code+).
    # @param label [String] Short prefix combined with +exception.message+ in the client-visible message.
    # @param log_prefix [String] Prefix for the log line (without the exception message).
    # @return [void]
    def emit_json_error(exception, code:, label:, log_prefix:)
      log_message("#{log_prefix}#{exception.message}", severity: :error)
      write_json_line(MCP::Response.error("#{label}: #{exception.message}", code: code))
    end

    # @param payload [Hash] Serializable hash written with +#to_json+.
    # @return [void]
    def write_json_line(payload)
      puts(payload.to_json)
      $stdout.flush
    end

    # Appends a timestamped line to {LOG_FILE}.
    # @param message [String]
    # @param severity [Symbol] e.g. +:info+, +:error+ (uppercased in the log).
    # @return [void]
    def log_message(message, severity: :info)
      File.open(LOG_FILE, 'a') do |f|
        f.puts "#{Time.now} [#{severity.to_s.upcase}] #{message}"
      end
    end
  end
end
