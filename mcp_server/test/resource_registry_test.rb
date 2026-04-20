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

  def test_all_resources_includes_skill_resources
    names = @registry.all_resources.map(&:name)
    assert_includes names, 'skill/rails-code-review'
    assert_includes names, 'skill/rails-tdd-slices'
    assert_includes names, 'skill/ruby-service-objects'
  end

  def test_all_resources_includes_support_files
    names = @registry.all_resources.map(&:name)
    assert names.any? { |n| n.start_with?('skill/rails-code-review/') },
           'Should include support files with subpath prefix'
  end

  def test_all_resources_includes_doc_resources
    names = @registry.all_resources.map(&:name)
    assert names.any? { |n| n.start_with?('doc/') }, 'Should include doc resources'
  end

  def test_all_resources_includes_workflow_resources
    names = @registry.all_resources.map(&:name)
    assert names.any? { |n| n.start_with?('workflow/') }, 'Should include workflow resources'
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

  def test_read_returns_file_content
    skill_uri = @registry.all_resources
                         .find { |r| r.name == 'skill/rails-code-review' }
                         &.uri
    refute_nil skill_uri, 'Expected to find skill/rails-code-review resource'
    result = @registry.read(skill_uri)
    assert_includes result.first[:text], 'rails-code-review'
  end

  def test_read_raises_for_unknown_uri
    assert_raises(McpSkills::ResourceRegistry::NotFoundError) do
      @registry.read('file:///nonexistent/path/SKILL.md')
    end
  end

  def test_new_skill_dir_auto_discovered
    new_skill = Pathname.new(@tmpdir).join('my-new-skill')
    new_skill.mkpath
    new_skill.join('SKILL.md').write('# My New Skill')

    fresh_registry = McpSkills::ResourceRegistry.new(Pathname.new(@tmpdir))
    names = fresh_registry.all_resources.map(&:name)
    assert_includes names, 'skill/my-new-skill'
  end
end
