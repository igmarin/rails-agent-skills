# frozen_string_literal: true

require 'mcp'
require 'pathname'
require_relative 'lib/mcp_skills/resource_registry'
require_relative 'lib/mcp_skills/skill_tool'

PROJECT_ROOT = Pathname.new(__dir__).join('..').realpath

registry = McpSkills::ResourceRegistry.new(PROJECT_ROOT)

server = MCP::Server.new(
  name: 'rails-agent-skills',
  version: '1.0.0',
  tools: [McpSkills::SkillTool],
  resources: registry.all_resources
)

server.resources_read_handler do |params|
  registry.read(params[:uri])
end

transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
