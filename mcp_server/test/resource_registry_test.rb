# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/resource_registry'

class ResourceRegistryTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('mcp_skills_test')
    build_fixture_tree(@tmpdir)
    @registry = McpSkills::ResourceRegistry.new(Pathname.new(@tmpdir))
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_all_resources_returns_array
    assert_instance_of Array, @registry.all_resources
  end

  def test_all_resources_includes_doc_resources
    names = @registry.all_resources.map(&:name)
    assert names.any? { |n| n.start_with?('doc/') }, 'Should include doc resources'
  end

  def test_all_resources_includes_agent_resources
    names = @registry.all_resources.map(&:name)
    assert_includes names, 'agent/review'
  end

  def test_all_resources_excludes_skill_resources
    names = @registry.all_resources.map(&:name)
    refute names.any? { |n| n.start_with?('skill/') }, 'Skills should be loaded via use_skill, not published as resources'
  end

  def test_all_resources_includes_nested_doc_resources
    names = @registry.all_resources.map(&:name)
    assert_includes names, 'doc/workflows/discovery'
  end

  def test_skill_template_is_excluded
    names = @registry.all_resources.map(&:name)
    refute names.any? { |n| n.include?('skill-template') }, 'skill-template should be excluded'
  end

  def test_all_resources_have_valid_file_uris
    @registry.all_resources.each do |resource|
      assert resource.uri.start_with?('file://'), "Expected file:// URI, got: #{resource.uri}"
    end
  end

  def test_all_resources_have_markdown_mime_type
    @registry.all_resources.each do |resource|
      assert_equal 'text/markdown', resource.mime_type
    end
  end

  def test_read_returns_agent_content
    agent_uri = @registry.all_resources
                           .find { |r| r.name == 'agent/review' }
                           &.uri
    refute_nil agent_uri, 'Expected to find agent/review resource'

    result = @registry.read(agent_uri)
    assert_includes result.first[:text], 'review agent'
  end

  def test_read_raises_for_unknown_uri
    assert_raises(McpSkills::ResourceRegistry::NotFoundError) do
      @registry.read('file:///nonexistent/path/SKILL.md')
    end
  end
end
