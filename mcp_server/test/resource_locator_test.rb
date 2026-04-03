# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require_relative '../lib/mcp/resource_locator'

# Tests for {MCP::ResourceLocator} listing and reading skill resources under a project root.
class MCPResourceLocatorTest < Minitest::Test
  def setup
    @temp_project_root = Pathname.new(__dir__).join('..', 'tmp_project_root')
    @temp_project_root.mkdir unless @temp_project_root.exist?
    @locator = MCP::ResourceLocator.new(@temp_project_root)
    install_skill_fixtures
  end

  def install_skill_fixtures
    @skill_dir1 = write_skill_dir('skill_one', '# Skill One')
    @skill_dir2 = write_skill_dir('another_skill', '# Another Skill')
    write_skill_dir('skill-template', '# Skill Template')
    write_skill_dir('rails-agent-skills', '# Main Skill')
    @temp_project_root.join('not_a_skill.md').write('# Not A Skill')
  end

  def write_skill_dir(dirname, content)
    dir = @temp_project_root.join(dirname)
    dir.mkdir unless dir.exist?
    dir.join('SKILL.md').write(content)
    dir
  end

  def teardown
    @temp_project_root.rmtree if @temp_project_root.exist?
  end

  def test_list_skill_resources_returns_array_of_hashes
    resources = @locator.list_skill_resources
    assert_instance_of Array, resources
    assert resources.any?, 'Should find some skill resources'
    assert_instance_of Hash, resources.first
    assert_includes resources.first.keys, :uri
    assert_includes resources.first.keys, :name
    assert_includes resources.first.keys, :mimeType
  end

  def test_list_skill_resources_filters_out_template_and_main_skill
    resources = @locator.list_skill_resources
    refute resources.any? { |r| r[:name] == 'skill/skill-template' }, 'Should filter out skill-template'
    refute resources.any? { |r|
      r[:name] == 'skill/rails-agent-skills'
    }, 'Should filter out main rails-agent-skills discovery skill'
  end

  def test_list_skill_resources_formats_name_correctly
    resources = @locator.list_skill_resources
    assert resources.any? { |r| r[:name] == 'skill/skill_one' }, 'Should find skill_one'
    assert resources.any? { |r| r[:name] == 'skill/another_skill' }, 'Should find another_skill'
  end

  def test_read_resource_reads_file_content
    file_uri = "file://#{@skill_dir1.join('SKILL.md')}"
    content = @locator.read_resource(file_uri)
    assert_equal '# Skill One', content.strip
  end

  def test_read_resource_raises_error_for_non_file_uri
    assert_raises ArgumentError do
      @locator.read_resource('http://example.com/skill.md')
    end
  end

  def test_read_resource_raises_error_for_nonexistent_file
    assert_raises Errno::ENOENT do
      @locator.read_resource('file:///non/existent/path/skill.md')
    end
  end
end
