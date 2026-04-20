# frozen_string_literal: true

require 'mcp'
require 'pathname'

module McpSkills
  # MCP Tool that returns the content of a SKILL.md given a skill name.
  # The agent invokes this tool by name ('use_skill') with a skill_name argument.
  class SkillTool < MCP::Tool
    tool_name 'use_skill'
    description 'Returns the full SKILL.md content for a given Rails Agent Skill by name. ' \
                'Use this to load a specific skill workflow before implementing a feature.'

    input_schema(
      properties: {
        'skill_name' => {
          type: 'string',
          description: 'The directory name of the skill (e.g. "rails-code-review", "rspec-best-practices")'
        }
      },
      required: ['skill_name']
    )

    class << self
      # @param skill_name [String] The skill directory name.
      # @param project_root [Pathname, String] Override for testing; defaults to repo root.
      # @param server_context [Hash] MCP server context (unused but required by protocol).
      # @return [MCP::Tool::Response]
      def call(skill_name:, server_context:, project_root: nil)
        root = resolve_root(project_root)
        skill_md = root.join(skill_name, 'SKILL.md')

        unless skill_md.exist?
          return MCP::Tool::Response.new(
            [{ type: 'text', text: "Skill '#{skill_name}' not found or has no SKILL.md." }],
            error: true
          )
        end

        content = skill_md.read
        MCP::Tool::Response.new([{ type: 'text', text: content }])
      rescue StandardError => e
        MCP::Tool::Response.new(
          [{ type: 'text', text: "Error reading skill '#{skill_name}': #{e.message}" }],
          error: true
        )
      end

      private

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
