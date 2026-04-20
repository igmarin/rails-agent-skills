# frozen_string_literal: true

require 'mcp'
require 'pathname'

module McpSkills
  # Builds MCP::Resource objects for a single skill directory.
  # Produces one resource for SKILL.md and additional resources for each
  # recognized support file (EXAMPLES.md, TESTING.md, PATTERNS.md, etc.).
  class SkillResourceBuilder
    SUPPORT_FILES = %w[EXAMPLES.md TESTING.md PATTERNS.md HEURISTICS.md TASK_TEMPLATES.md].freeze

    # @param skill_dir [Pathname] Path to the skill directory.
    # @return [Array<MCP::Resource>]
    def self.call(skill_dir)
      new(Pathname.new(skill_dir)).build
    end

    def initialize(skill_dir)
      @skill_dir = skill_dir
      @skill_name = @skill_dir.basename.to_s
    end

    def build
      resources = []

      skill_md = @skill_dir.join('SKILL.md')
      resources << build_resource(skill_md, "skill/#{@skill_name}") if skill_md.exist?

      SUPPORT_FILES.each do |filename|
        path = @skill_dir.join(filename)
        next unless path.exist?

        key = filename.sub(/\.md$/i, '').downcase
        resources << build_resource(path, "skill/#{@skill_name}/#{key}")
      end

      resources
    end

    private

    def build_resource(path, name)
      MCP::Resource.new(
        uri: "file://#{path.realpath}",
        name: name,
        title: name,
        description: "Rails Agent Skill: #{name}",
        mime_type: 'text/markdown'
      )
    end
  end
end
