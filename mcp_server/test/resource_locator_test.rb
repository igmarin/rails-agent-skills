# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require_relative '../lib/mcp/resource_locator'

class MCPResourceLocatorTest < Minitest::Test
  def setup
    # Define a temporary project root for testing purposes
    @temp_project_root = Pathname.new(__dir__).join('..', 'tmp_project_root')
    @temp_project_root.mkdir unless @temp_project_root.exist?

    @locator = MCP::ResourceLocator.new(@temp_project_root)

    # Create dummy skill files
    @skill_dir1 = @temp_project_root.join('skill_one')
    @skill_dir1.mkdir unless @skill_dir1.exist?
    @skill_dir1.join('SKILL.md').write('# Skill One')

    @skill_dir2 = @temp_project_root.join('another_skill')
    @skill_dir2.mkdir unless @skill_dir2.exist?
    @skill_dir2.join('SKILL.md').write('# Another Skill')

    # Create a dummy skill-template.md to ensure it's filtered
    @template_dir = @temp_project_root.join('skill-template')
    @template_dir.mkdir unless @template_dir.exist?
    @template_dir.join('SKILL.md').write('# Skill Template')

    # Create a dummy rails-agent-skills/SKILL.md to ensure it's filtered
    @main_skill_dir = @temp_project_root.join('rails-agent-skills')
    @main_skill_dir.mkdir unless @main_skill_dir.exist?
    @main_skill_dir.join('SKILL.md').write('# Main Skill')

    # Create a non-skill file to ensure it's ignored by glob
    @temp_project_root.join('not_a_skill.md').write('# Not A Skill')
  end

  def teardown
    @temp_project_root.rmtree if @temp_project_root.exist?
  end

  def test_list_skill_resources_returns_array_of_hashes
    resources = @locator.list_skill_resources
    assert_instance_of Array, resources
    assert resources.any?, "Should find some skill resources"
    assert_instance_of Hash, resources.first
    assert_includes resources.first.keys, :uri
    assert_includes resources.first.keys, :name
    assert_includes resources.first.keys, :mimeType
  end

  def test_list_skill_resources_filters_out_template_and_main_skill
    resources = @locator.list_skill_resources
    refute resources.any? { |r| r[:name] == 'skill/skill-template' }, "Should filter out skill-template"
    refute resources.any? { |r| r[:name] == 'skill/rails-agent-skills' }, "Should filter out main rails-agent-skills discovery skill"
  end

  def test_list_skill_resources_formats_name_correctly
    resources = @locator.list_skill_resources
    assert resources.any? { |r| r[:name] == 'skill/skill_one' }, "Should find skill_one"
    assert resources.any? { |r| r[:name] == 'skill/another_skill' }, "Should find another_skill"
  end

  def test_read_resource_reads_file_content
    file_uri = "file://\#{@skill_dir1.join('SKILL.md').to_s}"
    content = @locator.read_resource(file_uri)
    assert_equal "# Skill One", content.strip
  end

  def test_read_resource_raises_error_for_non_file_uri
    assert_raises ArgumentError do
      @locator.read_resource("http://example.com/skill.md")
    end
  end

  def test_read_resource_raises_error_for_nonexistent_file
    assert_raises Errno::ENOENT do
      @locator.read_resource("file:///non/existent/path/skill.md")
    end
  end
end
