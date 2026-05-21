# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/skill_resource_builder'

class SkillResourceBuilderTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('skill_builder_test')
    @skill_dir = Pathname.new(@tmpdir).join('code-review')
    @skill_dir.mkpath
    @skill_dir.join('SKILL.md').write('# Rails Code Review')
    @skill_dir.join('EXAMPLES.md').write('# Examples')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_builds_skill_md_resource
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    skill_resource = resources.find { |r| r.name == 'skill/code-review' }
    refute_nil skill_resource
  end

  def test_skill_resource_has_correct_uri
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    skill_resource = resources.find { |r| r.name == 'skill/code-review' }
    assert skill_resource.uri.start_with?('file://')
    assert skill_resource.uri.end_with?('SKILL.md')
  end

  def test_skill_resource_has_markdown_mime_type
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    skill_resource = resources.find { |r| r.name == 'skill/code-review' }
    assert_equal 'text/markdown', skill_resource.mime_type
  end

  def test_builds_support_file_resources
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    support_resource = resources.find { |r| r.name == 'skill/code-review/examples' }
    refute_nil support_resource, 'Should build resource for EXAMPLES.md'
  end

  def test_support_resource_has_correct_uri
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    support_resource = resources.find { |r| r.name == 'skill/code-review/examples' }
    assert support_resource.uri.end_with?('EXAMPLES.md')
  end

  def test_returns_only_markdown_files
    @skill_dir.join('config.yml').write('key: value')
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir)
    resources.each do |r|
      assert r.uri.end_with?('.md'), "Expected only .md files, got: #{r.uri}"
    end
  end

  def test_builds_agent_resources_with_custom_prefix
    resources = McpSkills::SkillResourceBuilder.call(@skill_dir, prefix: 'agent')
    agent_resource = resources.find { |r| r.name == 'agent/code-review' }
    refute_nil agent_resource
  end
end
