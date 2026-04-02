# frozen_string_literal: true

require_relative './request_handler'
require_relative './resource_locator'
require_relative './response'
require 'json'
require 'pathname'

module MCP
  # Main server class for handling Model Context Protocol requests.
  class Server
    # Defines the project root as one level up from the mcp_server directory.
    # `__dir__` gets the directory of the current file (e.g., /path/to/repo/mcp_server/lib/mcp).
    # `.join('..', '..', '..')` navigates up three levels to the main project root.
    # `.realpath` resolves any symlinks to get the true path.
    PROJECT_ROOT = Pathname.new(__dir__).join('..', '..', '..').realpath
    # The log file is now located within the mcp_server directory itself
    LOG_FILE = PROJECT_ROOT.join('mcp_server', 'mcp_server_log.log')

    def initialize
      resource_locator = ResourceLocator.new(PROJECT_ROOT)
      @request_handler = RequestHandler.new(resource_locator: resource_locator)
    end

    # Starts the MCP server, listening for requests on STDIN and responding to STDOUT.
    def start
      log_message("MCP Ruby Server starting.")
      loop do
        request_line = ARGF.gets
        break if request_line.nil? || request_line.strip.empty?

        log_message("Received request: \#{request_line.strip}")
        response = @request_handler.handle(JSON.parse(request_line))
        log_message("Sending response: \#{response.to_json}")
        puts(response.to_json)
        $stdout.flush
      rescue JSON::ParserError => e
        error_response = MCP::Response.error("JSON Parse Error: \#{e.message}", code: 400)
        log_message("Error processing request: \#{e.message}", severity: :error)
        puts(error_response.to_json)
        $stdout.flush
      rescue StandardError => e
        error_response = MCP::Response.error("Server Error: \#{e.message}", code: 500)
        log_message("Unhandled error in server loop: \#{e.message}", severity: :error)
        puts(error_response.to_json)
        $stdout.flush
      end
      log_message("MCP Ruby Server stopped.")
    end

    private

    def log_message(message, severity: :info)
      File.open(LOG_FILE, 'a') do |f|
        f.puts "\#{Time.now} [\#{severity.to_s.upcase}] \#{message}"
      end
    end
  end
end
