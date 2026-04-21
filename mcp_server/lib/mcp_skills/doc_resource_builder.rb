# frozen_string_literal: true

require 'mcp'
require 'pathname'

module McpSkills
  # Builds MCP::Resource objects for a flat directory of markdown files (docs/ or workflows/).
  # Each .md file becomes one resource with the given prefix.
  class DocResourceBuilder
    # @param dir [Pathname, String] Directory to scan for .md files.
    # @param prefix [String] Resource name prefix (e.g. 'doc' or 'workflow').
    # @return [Array<MCP::Resource>]
    def self.call(dir, prefix:)
      new(Pathname.new(dir), prefix: prefix).build
    end

    def initialize(dir, prefix:)
      @dir = Pathname.new(dir)
      @prefix = prefix
    end

    def build
      return [] unless @dir.exist? && @dir.directory?

      @dir.glob('*.md').sort.map do |path|
        slug = path.basename('.md').to_s
        name = "#{@prefix}/#{slug}"
        MCP::Resource.new(
          uri: "file://#{path.realpath}",
          name: name,
          title: name,
          description: "#{@prefix.capitalize}: #{slug}",
          mime_type: 'text/markdown'
        )
      end
    end
  end
end
