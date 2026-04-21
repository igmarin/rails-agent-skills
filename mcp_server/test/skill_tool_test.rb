# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/skill_tool'

class SkillToolTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('skill_tool_test')
    @base = Pathname.new(@tmpdir)

    skill_dir = @base.join('rails-code-review')
    skill_dir.mkpath
    skill_dir.join('SKILL.md').write('# Rails Code Review\nContent here.')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_call_returns_skill_content
    result = McpSkills::SkillTool.call(
      skill_name: 'rails-code-review',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    content_text = result.content.first[:text]
    assert_includes content_text, 'Rails Code Review'
  end

  def test_call_returns_error_response_for_unknown_skill
    result = McpSkills::SkillTool.call(
      skill_name: 'nonexistent-skill',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    assert result.error?, 'Expected an error response for unknown skill'
  end

  def test_call_returns_error_response_for_missing_skill_md
    empty_skill = @base.join('empty-skill')
    empty_skill.mkpath

    result = McpSkills::SkillTool.call(
      skill_name: 'empty-skill',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    assert result.error?, 'Expected an error response when SKILL.md is absent'
  end

  def test_tool_has_description
    refute_nil McpSkills::SkillTool.description
    refute_empty McpSkills::SkillTool.description
  end

  def test_tool_input_schema_requires_skill_name
    schema = McpSkills::SkillTool.input_schema.to_h
    assert_includes schema[:required], 'skill_name'
  end
end
