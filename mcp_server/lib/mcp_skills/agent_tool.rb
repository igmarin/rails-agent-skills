# frozen_string_literal: true

require 'mcp'
require 'yaml'
require_relative 'resource_discovery'

module McpSkills
  class AgentTool < MCP::Tool
    tool_name 'use_agent'
    title 'Use Rails Agent'
    description 'Read one Rails Agent by name after selecting it from list_agents. ' \
                'Returns the full SKILL.md instructions plus structured metadata. ' \
                'This tool is read-only and has no repository side effects.'

    input_schema(
      properties: {
        'agent_name' => {
          type: 'string',
          description: 'The directory name of the agent (e.g. "tdd", "review", "bug-fix", "graphql")'
        }
      },
      required: ['agent_name']
    )

    output_schema(
      properties: {
        found: {
          type: 'boolean',
          description: 'Whether the requested agent was found.'
        },
        name: {
          type: %w[string null],
          description: 'Normalized agent name, or null when not found.'
        },
        path: {
          type: %w[string null],
          description: 'Repository path to SKILL.md, or null when not found.'
        },
        description: {
          type: %w[string null],
          description: 'Short routing description, or null when not found.'
        },
        content: {
          type: %w[string null],
          description: 'Full SKILL.md instructions, or null when not found.'
        },
        error: {
          type: %w[string null],
          description: 'Error message when the agent cannot be loaded.'
        }
      },
      required: %w[found name path description content error],
      additionalProperties: false
    )

    annotations(
      title: 'Use Rails Agent',
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    class << self
      def call(agent_name:, server_context:, project_root: nil)
        root = resolve_root(project_root)
        name = normalize_agent_name(agent_name)
        agent_dirs = ResourceDiscovery.call(root).agent_dirs
        dir = agent_dirs.find { |d| d.basename.to_s == name }

        unless dir
          structured_content = not_found_content(name)
          return MCP::Tool::Response.new(
            [{ type: 'text', text: structured_content[:error] }],
            error: true,
            structured_content: structured_content
          )
        end

        skill_md = dir.join('SKILL.md')
        unless skill_md.exist?
          structured_content = not_found_content(name, "Agent '#{name}' has no SKILL.md.")
          return MCP::Tool::Response.new(
            [{ type: 'text', text: structured_content[:error] }],
            error: true,
            structured_content: structured_content
          )
        end

        content = skill_md.read
        frontmatter = parse_frontmatter(content)

        structured_content = {
          found: true,
          name: name,
          path: skill_md.relative_path_from(root).to_s,
          description: frontmatter_description(frontmatter),
          content: content,
          error: nil
        }

        MCP::Tool::Response.new(
          [{ type: 'text', text: content }],
          structured_content: structured_content
        )
      rescue StandardError => e
        warn "[MCP] #{e.class}: #{e.message}"
        warn e.backtrace.first(5).join("\n") if e.backtrace
        structured_content = not_found_content(
          name || agent_name,
          "Error reading agent '#{name || agent_name}': #{e.message}"
        )
        MCP::Tool::Response.new(
          [{ type: 'text', text: structured_content[:error] }],
          error: true,
          structured_content: structured_content
        )
      end

      private

      def normalize_agent_name(agent_name)
        parts = agent_name.to_s.strip.split('/').reject(&:empty?)
        return '' if parts.empty?
        return parts[-2].to_s if parts.last == 'SKILL.md'

        parts.last.to_s
      end

      def not_found_content(name, message = "Agent '#{name}' not found.")
        {
          found: false,
          name: nil,
          path: nil,
          description: nil,
          content: nil,
          error: message
        }
      end

      def parse_frontmatter(content)
        match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
        return {} unless match

        YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
      rescue Psych::SyntaxError
        {}
      end

      def frontmatter_description(frontmatter)
        frontmatter.fetch('description', '').to_s.lines.map(&:strip).reject(&:empty?).join(' ')
      end

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
