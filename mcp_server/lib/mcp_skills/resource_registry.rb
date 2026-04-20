# frozen_string_literal: true

require 'pathname'
require_relative 'skill_resource_builder'
require_relative 'doc_resource_builder'

module McpSkills
  # Single source of truth for all MCP resources exposed by this server.
  # Scans the repository root for skill directories, docs/, and .windsurf/workflows/.
  # Zero hardcoded skill names — any new skill directory with SKILL.md is auto-discovered.
  class ResourceRegistry
    class NotFoundError < StandardError; end

    EXCLUDED_DIRS = %w[skill-template rails-agent-skills mcp_server].freeze

    # @param project_root [Pathname, String] Root of the rails-agent-skills repository.
    def initialize(project_root)
      @project_root = Pathname.new(project_root)
    end

    # Returns all MCP::Resource objects (skills + docs + workflows).
    # @return [Array<MCP::Resource>]
    def all_resources
      skill_resources + doc_resources + workflow_resources
    end

    # Reads a resource by URI and returns the MCP resources/read payload.
    # @param uri [String] file:// URI of the resource.
    # @return [Array<Hash>] Array with one hash containing :uri, :mimeType, :text.
    # @raise [NotFoundError] if the URI is not a known registered resource.
    def read(uri)
      resource = all_resources.find { |r| r.uri == uri }
      raise NotFoundError, "Resource not found: #{uri}" unless resource

      file_path = uri.sub('file://', '')
      [{ uri: uri, mimeType: resource.mime_type, text: File.read(file_path) }]
    end

    private

    def skill_resources
      skill_dirs.flat_map { |dir| SkillResourceBuilder.call(dir) }
    end

    def skill_dirs
      # Find SKILL.md files in both root directories and tessl tiles
      skill_files = @project_root.glob('*/SKILL.md') +
                   @project_root.glob('.tessl/tiles/igmarin/rails-agent-skills/*/SKILL.md')
      
      skill_files.map(&:dirname)
                .reject { |dir| EXCLUDED_DIRS.include?(dir.basename.to_s) }
                .sort
    end

    def doc_resources
      DocResourceBuilder.call(@project_root.join('docs'), prefix: 'doc')
    end

    def workflow_resources
      DocResourceBuilder.call(@project_root.join('.windsurf', 'workflows'), prefix: 'workflow')
    end
  end
end
