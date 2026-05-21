# frozen_string_literal: true

require_relative 'skill_resource_builder'
require_relative 'doc_resource_builder'
require_relative 'resource_discovery'

module McpSkills
  # Single source of truth for all MCP resources exposed by this server.
  # Scans the repository root for published agents and docs.
  # Skills are now exclusively exposed via the `use_skill` tool, not as resources.
  # Published locations are discovered centrally so runtime and docs stay aligned.
  class ResourceRegistry
    class NotFoundError < StandardError; end

    # @param project_root [Pathname, String] Root of the rails-agent-skills repository.
    # @raise [TypeError] if `project_root` is not a valid path.
    def initialize(project_root)
      @project_root = Pathname.new(project_root)
      @discovery = ResourceDiscovery.call(@project_root)
    end

    # Returns all MCP::Resource objects (docs + agents).
    # @return [Array<MCP::Resource>]
    # @raise [Errno::EACCES] when a published resource cannot be accessed.
    # @raise [Errno::ENOENT] when a published resource disappears during registry construction.
    def all_resources
      doc_resources + agent_resources
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

    def doc_resources
      DocResourceBuilder.call(@discovery.docs_dir, prefix: 'doc')
    end

    def agent_resources
      @discovery.agent_dirs.flat_map { |dir| SkillResourceBuilder.call(dir, prefix: 'agent') }
    end
  end
end
