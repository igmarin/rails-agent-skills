# frozen_string_literal: true

module McpSkills
  # Discovers the repository paths that should be exposed through MCP resources.
  class ResourceDiscovery
    EXCLUDED_DIRS = %w[skill-template rails-agent-skills mcp_server].freeze
    SKILL_PATTERNS = [
      'skills/*/*/SKILL.md',
      '.tessl/tiles/*/*/*/SKILL.md'
    ].freeze
    AGENT_PATTERN = 'agents/*/SKILL.md'

    Result = Struct.new(:skill_dirs, :agent_dirs, :workflow_dirs, :docs_dir, keyword_init: true) do
      def workflow_dirs
        agent_dirs
      end
    end

    # Resolves the current resource topology for the repository.
    #
    # @param project_root [String, Pathname] Root of the repository to scan.
    # @return [Result] The discovered skill directories, agent directories, and docs directory.
    # @raise [TypeError] when `project_root` cannot be converted into a pathname.
    def self.call(project_root)
      new(project_root).call
    end

    # @param project_root [String, Pathname] Root of the repository to scan.
    # @return [void]
    # @raise [TypeError] when `project_root` cannot be converted into a pathname.
    def initialize(project_root)
      @project_root = Pathname.new(project_root)
    end

    # Performs path discovery for MCP resources.
    #
    # @return [Result] The discovered skill directories, agent directories, and docs directory.
    def call
      agent_dirs = discover_agent_dirs
      Result.new(
        skill_dirs: discover_skill_dirs,
        agent_dirs: agent_dirs,
        docs_dir: @project_root.join('docs')
      )
    end

    private

    def discover_skill_dirs
      grouped_dirs = SKILL_PATTERNS.flat_map { |pattern| @project_root.glob(pattern) }
                                   .sort_by { |path| [sort_weight(path), path.to_s] }
                                   .map(&:dirname)
                                   .reject { |dir| EXCLUDED_DIRS.include?(dir.basename.to_s) }
                                   .group_by { |dir| dir.basename.to_s }

      grouped_dirs.values.flat_map { |dirs| deduplicate_dirs(dirs) }
    end

    def deduplicate_dirs(dirs)
      non_tessl_dirs, tessl_dirs = dirs.partition { |dir| sort_weight(dir).zero? }
      warn_on_duplicate_non_tessl_dirs(non_tessl_dirs)

      return non_tessl_dirs if non_tessl_dirs.any?

      tessl_dirs.first ? [tessl_dirs.first] : []
    end

    def warn_on_duplicate_non_tessl_dirs(non_tessl_dirs)
      return unless non_tessl_dirs.size > 1

      warn "Duplicate published skill names detected: #{non_tessl_dirs.map(&:to_s).join(', ')}"
    end

    def discover_agent_dirs
      @project_root.glob(AGENT_PATTERN).sort.map(&:dirname)
    end

    def sort_weight(path)
      path.to_s.include?('/.tessl/') ? 1 : 0
    end
  end
end
