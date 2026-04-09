# frozen_string_literal: true

require 'pathname'

module MCP
  # Discovers skill markdown files under a project root and resolves +file://+ URIs to file contents.
  class ResourceLocator
    # @param project_root [String, Pathname] Root directory to scan (resolved with Pathname#realpath).
    def initialize(project_root)
      @project_root = Pathname.new(project_root).realpath
    end

    # Finds all +SKILL.md+ files under {#initialize}'s root and returns MCP-style resource descriptors.
    # Skips +skill-template+ and +rails-skills-orchestrator+ directories (scaffolding / discovery-only skills).
    # @return [Array<Hash>] Each element includes +:uri+ (+String+, +file://+), +:name+ (+String+, +skill/+ prefix),
    #   and +:mimeType+ (+String+, typically +'text/markdown'+).
    def list_skill_resources
      Dir.glob(@project_root.join('**', 'SKILL.md').to_s).map do |file_path|
        # Ensure we only pick up SKILL.md files that are part of a skill directory
        next unless file_path =~ %r{/([^/]+)/SKILL\.md$}

        skill_name = Regexp.last_match(1)

        # Filter out the skill-template.md as it's not a functional skill
        next if skill_name == 'skill-template'

        # Also filter out the orchestrator SKILL.md (rails-skills-orchestrator) as it's a discovery-only skill
        next if skill_name == 'rails-skills-orchestrator'

        {
          uri: "file://#{file_path}",
          name: "skill/#{skill_name}", # MCP convention for skills
          mimeType: 'text/markdown'
        }
      end.compact # Remove any nil entries from filtering
    end

    # Reads file contents for a +file://+ URI path produced by {#list_skill_resources}.
    # @param uri [String] Absolute +file://+ URI; the path segment is read as a local filesystem path.
    # @return [String] Raw file bytes (text for markdown skills).
    # @raise [ArgumentError] if +uri+ does not start with +file://+
    # @raise [Errno::ENOENT] if the path does not exist or is not readable
    def read_resource(uri)
      raise ArgumentError, 'Only file URIs are supported' unless uri.start_with?('file://')

      file_path = uri.sub('file://', '')
      File.read(file_path)
    end
  end
end
