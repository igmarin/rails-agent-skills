# frozen_string_literal: true

require 'json'
require 'pathname'
require 'yaml'

module McpSkills
  # Builds structured metadata for public Rails Agent Skills.
  class SkillCatalog
    class ManifestError < StandardError; end

    Skill = Struct.new(:name, :path, :category, :description, :content, keyword_init: true) do
      def metadata
        {
          name: name,
          path: path,
          category: category,
          description: description
        }
      end
    end

    # Builds the public skill catalog from the root Tessl manifest.
    #
    # @param project_root [String, Pathname] Root of the repository containing tile.json.
    # @return [Array<Skill>] Skills declared in tile.json, in manifest order.
    # @raise [ManifestError] when tile.json is missing, malformed, or lacks a skills object.
    def self.call(project_root)
      new(project_root).call
    end

    def initialize(project_root)
      @project_root = Pathname.new(project_root).expand_path
    end

    # Builds skills declared by the loaded manifest.
    #
    # @return [Array<Skill>] Skills declared in tile.json, in manifest order.
    # @raise [ManifestError] when the manifest is missing a valid "skills" Hash.
    def call
      skills = manifest['skills']
      raise ManifestError, 'tile.json is missing required "skills" object' unless skills.is_a?(Hash)

      skills.map { |name, spec| build_skill(name, spec) }
    end

    private

    def manifest
      JSON.parse(@project_root.join('tile.json').read)
    rescue Errno::ENOENT => e
      raise ManifestError, "Unable to read tile.json: #{e.message}"
    rescue JSON::ParserError => e
      raise ManifestError, "Unable to parse tile.json: #{e.message}"
    end

    def build_skill(name, spec)
      relative_path = spec.fetch('path')
      skill_md = safe_skill_path(name, relative_path)
      content = skill_md.exist? ? skill_md.read : nil

      Skill.new(
        name: name,
        path: relative_path,
        category: category_from_path(relative_path),
        description: description_from(content.to_s),
        content: content
      )
    rescue KeyError => e
      raise ManifestError, "Skill '#{name}' in tile.json is missing required path: #{e.message}"
    end

    def safe_skill_path(name, relative_path)
      candidate = @project_root.join(relative_path).cleanpath
      root_path = @project_root.to_path
      candidate_path = candidate.to_path

      return candidate if candidate_path == root_path || candidate_path.start_with?("#{root_path}#{File::SEPARATOR}")

      raise ManifestError, "Skill '#{name}' in tile.json points outside project root: #{relative_path}"
    end

    def category_from_path(path)
      parts = path.split('/')
      return parts[1] if parts[0] == 'skills' && parts[1]
      return 'agent' if parts[0] == 'agents'
      return 'workflow' if parts[0] == 'workflows'

      'unknown'
    end

    def description_from(content)
      frontmatter = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)&.[](1)
      return '' unless frontmatter

      metadata = YAML.safe_load(frontmatter, permitted_classes: [], aliases: false) || {}
      metadata.fetch('description', '').to_s.lines.map(&:strip).reject(&:empty?).join(' ')
    rescue Psych::SyntaxError
      ''
    end
  end
end
