# frozen_string_literal: true

require 'mcp'
require_relative 'lib/mcp_skills/list_skills_tool'
require_relative 'lib/mcp_skills/list_agents_tool'
require_relative 'lib/mcp_skills/resource_registry'
require_relative 'lib/mcp_skills/skill_tool'
require_relative 'lib/mcp_skills/agent_tool'

PROJECT_ROOT = Pathname.new(__dir__).join('..').realpath

# Enable logging
$stderr.sync = true
warn '[MCP] Starting server...'

begin
  registry = McpSkills::ResourceRegistry.new(PROJECT_ROOT)
  warn '[MCP] Registry created'

  server = MCP::Server.new(
    name: 'rails-agent-skills',
    version: '1.0.0',
    tools: [
      McpSkills::ListSkillsTool,
      McpSkills::SkillTool,
      McpSkills::ListAgentsTool,
      McpSkills::AgentTool
    ],
    resources: registry.all_resources
  )
  warn '[MCP] Server created'

  server.resources_read_handler do |params|
    registry.read(params[:uri])
  end
  warn '[MCP] Resource handler defined'

  transport = MCP::Server::Transports::StdioTransport.new(server)
  warn '[MCP] Transport created, opening...'
  transport.open
  warn '[MCP] Transport opened'
rescue StandardError => e
  warn "[MCP] Error: #{e.message}"
  warn e.backtrace.join("\n")
  exit 1
end
