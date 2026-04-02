# frozen_string_literal: true

require 'pathname'

module MCP
  # Locates skill resources within the project directory.
  class ResourceLocator
    def initialize(project_root)
      @project_root = Pathname.new(project_root).realpath
    end

    # Finds all SKILL.md files and formats them as MCP resources.
    # Filters out template and main discovery skill files.
    # @return [Array<Hash>] an array of resource hashes
    def list_skill_resources
      Dir.glob("\#{@project_root}/**/SKILL.md").map do |file_path|
        # Ensure we only pick up SKILL.md files that are part of a skill directory
        next unless file_path =~ %r{/([^/]+)/SKILL\.md$}

        skill_name = Regexp.last_match(1)
        
        # Filter out the skill-template.md as it's not a functional skill
        next if skill_name == 'skill-template'
        
        # Also filter out the main rails-agent-skills/SKILL.md as it's a discovery skill
        next if skill_name == 'rails-agent-skills'

        {
          uri: "file://\#{file_path}",
          name: "skill/\#{skill_name}", # MCP convention for skills
          mimeType: "text/markdown"
        }
      end.compact # Remove any nil entries from filtering
    end

    # Reads the content of a specific resource by its URI.
    # @param uri [String] The URI of the resource (expected to be 'file://...')
    # @return [String] The content of the file
    # @raise [ArgumentError] if the URI is not a file URI
    # @raise [Errno::ENOENT] if the file does not exist
    def read_resource(uri)
      raise ArgumentError, 'Only file URIs are supported' unless uri.start_with?('file://')

      file_path = uri.sub('file://', '')
      File.read(file_path)
    end
  end
end
