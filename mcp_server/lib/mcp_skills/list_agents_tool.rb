# frozen_string_literal: true

require 'mcp'
require 'yaml'
require_relative 'resource_discovery'

module McpSkills
  class ListAgentsTool < MCP::Tool
    tool_name 'list_agents'
    title 'List Rails Agents'
    description 'Discover available Rails Agent orchestrated workflows before loading one with use_agent. ' \
                'Returns names (without -agent suffix), paths, descriptions, and keywords only; it does not return full agent bodies. ' \
                'This tool is read-only and has no repository side effects.'

    input_schema(
      properties: {},
      additionalProperties: false
    )

    output_schema(
      properties: {
        count: {
          type: 'integer',
          minimum: 0,
          description: 'Number of agents returned.'
        },
        agents: {
          type: 'array',
          description: 'Rails Agents available through use_agent.',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string', description: 'Agent directory name.' },
              path: { type: 'string', description: 'Repository path to SKILL.md.' },
              description: { type: 'string', description: 'Short routing description.' },
              keywords: { type: 'string', description: 'Comma-separated discovery keywords.' }
            },
            required: %w[name path description keywords],
            additionalProperties: false
          }
        }
      },
      required: %w[count agents],
      additionalProperties: false
    )

    annotations(
      title: 'List Rails Agents',
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    class << self
      def call(server_context:, project_root: nil)
        root = resolve_root(project_root)
        agent_dirs = ResourceDiscovery.call(root).agent_dirs
        agents = agent_dirs.map { |dir| build_agent_metadata(dir, root) }
        structured_content = { count: agents.length, agents: agents }
        text = agents.map { |a| "#{a[:name]}\t#{a[:description]}" }.join("\n")

        MCP::Tool::Response.new(
          [{ type: 'text', text: text }],
          structured_content: structured_content
        )
      end

      private

      def build_agent_metadata(dir, root)
        skill_md = dir.join('SKILL.md')
        content = skill_md.exist? ? skill_md.read : ''
        frontmatter = parse_frontmatter(content)

        {
          name: dir.basename.to_s,
          path: skill_md.relative_path_from(root).to_s,
          description: frontmatter_description(frontmatter),
          keywords: frontmatter_keywords(frontmatter)
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

      def frontmatter_keywords(frontmatter)
        raw = frontmatter['keywords'] || frontmatter.dig('metadata', 'keywords') || ''
        raw.to_s.strip
      end

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
