# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/agent_tool'

class AgentToolTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('agent_tool_test')
    @base = Pathname.new(@tmpdir)

    agent_dir = @base.join('agents', 'tdd')
    agent_dir.mkpath
    agent_dir.join('SKILL.md').write("# TDD Agent\nFull TDD feature cycle with red-green-refactor.")

    docs_dir = @base.join('docs')
    docs_dir.mkpath
    docs_dir.join('overview.md').write('# Overview')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_call_returns_agent_content
    result = McpSkills::AgentTool.call(
      agent_name: 'tdd',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    content_text = result.content.first[:text]
    assert_includes content_text, 'TDD Agent'
    assert_equal true, result.structured_content[:found]
    assert_equal 'tdd', result.structured_content[:name]
    assert_equal 'agents/tdd/SKILL.md', result.structured_content[:path]
    assert_includes result.structured_content[:content], 'TDD Agent'
  end

  def test_call_accepts_full_skill_md_path
    result = McpSkills::AgentTool.call(
      agent_name: 'agents/tdd/SKILL.md',
      project_root: @base,
      server_context: {}
    )

    assert_instance_of MCP::Tool::Response, result
    assert_equal false, result.error?
    assert_equal true, result.structured_content[:found]
    assert_equal 'tdd', result.structured_content[:name]
  end

  def test_call_returns_error_response_for_unknown_agent
    result = McpSkills::AgentTool.call(
      agent_name: 'nonexistent',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    assert result.error?, 'Expected an error response for unknown agent'
    assert_equal false, result.structured_content[:found]
    assert_match(/not found/, result.structured_content[:error])
  end

  def test_tool_input_schema_requires_agent_name
    schema = McpSkills::AgentTool.input_schema.to_h
    assert_includes schema[:required], 'agent_name'
  end

  def test_tool_output_schema_and_annotations_describe_read_only_structured_result
    tool_hash = McpSkills::AgentTool.to_h

    assert_equal 'Use Rails Agent', tool_hash[:title]
    assert_includes tool_hash[:outputSchema].fetch(:required), 'content'
    assert_equal true, tool_hash[:annotations].fetch(:readOnlyHint)
    assert_equal false, tool_hash[:annotations].fetch(:destructiveHint)
    assert_equal true, tool_hash[:annotations].fetch(:idempotentHint)
    assert_equal false, tool_hash[:annotations].fetch(:openWorldHint)
  end
end
