# frozen_string_literal: true

require 'cgi'
require 'optparse'
require 'pathname'
require 'yaml'

module McpSkills
  class EvalContextBuilder
    TEXT_EXTENSIONS = %w[.erb .js .json .md .rb .txt .yaml .yml].freeze
    MEDIA_TYPES = {
      '.erb' => 'text/plain',
      '.js' => 'application/javascript',
      '.json' => 'application/json',
      '.md' => 'text/markdown',
      '.rb' => 'text/x-ruby',
      '.txt' => 'text/plain',
      '.yaml' => 'application/yaml',
      '.yml' => 'application/yaml'
    }.freeze

    class Error < StandardError; end

    def self.call(target_path, repo_root: nil)
      root = repo_root || Pathname.new(__dir__).join('..').realpath
      new(repo_root: root).call(target_path: target_path)
    end

    def initialize(repo_root:)
      @repo_root = Pathname.new(repo_root).realpath
    end

    def call(target_path:, target_type: nil, target_name: nil)
      primary_path = resolve_primary_path(target_path)
      target_dir = primary_path.dirname
      metadata = frontmatter(primary_path)

      render_context(
        primary_path: primary_path,
        target_type: target_type || infer_target_type(primary_path),
        target_name: target_name || metadata.fetch('name', target_dir.basename.to_s),
        resources: companion_resources(target_dir, primary_path)
      )
    end

    private

    def resolve_primary_path(target_path)
      path = Pathname.new(target_path)
      path = @repo_root.join(path) unless path.absolute?
      path = path.join('SKILL.md') if path.directory?

      raise Error, "SKILL.md not found: #{path}" unless path.file?
      raise Error, "target path must point to SKILL.md: #{path}" unless path.basename.to_s == 'SKILL.md'

      path.realpath
    end

    def companion_resources(target_dir, primary_path)
      direct_files = target_dir.children.select(&:file?)
                               .reject { |path| path == primary_path }
                               .select { |path| text_file?(path) }

      asset_files = target_dir.join('assets').exist? ? target_dir.join('assets').glob('**/*').select(&:file?) : []

      (direct_files + asset_files.select { |path| text_file?(path) })
        .uniq
        .sort_by { |path| relative_path(path) }
    end

    def render_context(primary_path:, target_type:, target_name:, resources:)
      lines = []
      lines << %(<skill_context target_type="#{escape_attr(target_type)}" target_name="#{escape_attr(target_name)}">)
      lines << render_file('primary', primary_path)
      lines << '  <resources>'
      resources.each { |path| lines << render_file('resource', path, role: role_for(path)) }
      lines << '  </resources>'
      lines << '</skill_context>'
      lines.join("\n")
    end

    def render_file(tag_name, path, role: nil)
      attrs = {
        path: relative_path(path),
        media_type: media_type(path)
      }
      attrs[:role] = role if role

      opening = attrs.map { |key, value| %(#{key}="#{escape_attr(value)}") }.join(' ')
      indent = tag_name == 'primary' ? '  ' : '    '

      [
        "#{indent}<#{tag_name} #{opening}>",
        escape_text(path.read),
        "#{indent}</#{tag_name}>"
      ].join("\n")
    end

    def frontmatter(path)
      content = path.read
      return {} unless content.start_with?("---\n")

      yaml = content.split(/^---\s*$/, 3)[1]
      YAML.safe_load(yaml, permitted_classes: [], aliases: false) || {}
    rescue Psych::SyntaxError
      {}
    end

    def infer_target_type(path)
      relative = relative_path(path)
      return 'agent' if relative.start_with?('agents/')
      return 'workflow' if relative.start_with?('workflows/')

      'skill'
    end

    def role_for(path)
      relative = relative_path(path)
      basename = path.basename.to_s

      return 'asset' if relative.include?('/assets/')
      return 'examples' if basename == 'EXAMPLES.md'
      return 'testing' if basename == 'TESTING.md'
      return 'patterns' if basename == 'PATTERNS.md'
      return 'heuristics' if basename == 'HEURISTICS.md'
      return 'task_templates' if basename == 'TASK_TEMPLATES.md'

      'companion'
    end

    def text_file?(path)
      TEXT_EXTENSIONS.include?(path.extname)
    end

    def media_type(path)
      MEDIA_TYPES.fetch(path.extname, 'text/plain')
    end

    def relative_path(path)
      Pathname.new(path).relative_path_from(@repo_root).to_s
    end

    def escape_attr(value)
      CGI.escapeHTML(value.to_s)
    end

    def escape_text(value)
      CGI.escapeHTML(value.to_s)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    options = {
      repo_root: Pathname.new(__dir__).join('..'),
      target_type: nil,
      target_name: nil
    }

    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby scripts/eval_context_builder.rb TARGET_PATH [options]'
      opts.on('--repo-root PATH', 'Repository root') { |value| options[:repo_root] = value }
      opts.on('--target-type TYPE', 'skill or workflow') { |value| options[:target_type] = value }
      opts.on('--target-name NAME', 'Override target name') { |value| options[:target_name] = value }
    end

    parser.parse!
    target_path = ARGV.shift

    unless target_path
      warn parser
      exit 1
    end

    puts McpSkills::EvalContextBuilder.new(repo_root: options[:repo_root]).call(
      target_path: target_path,
      target_type: options[:target_type],
      target_name: options[:target_name]
    )
  rescue McpSkills::EvalContextBuilder::Error => e
    warn e.message
    exit 1
  end
end
