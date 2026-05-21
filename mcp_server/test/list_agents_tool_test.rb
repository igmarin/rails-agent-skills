# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/list_agents_tool'

class ListAgentsToolTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('list_agents_tool_test')
    @base = Pathname.new(@tmpdir)

    agent_dir = @base.join('agents', 'tdd')
    agent_dir.mkpath
    agent_dir.join('SKILL.md').write(<<~MARKDOWN)
      ---
      name: tdd
      description: Full TDD feature cycle
      metadata:
        keywords: tdd, testing, red-green-refactor
      ---
      # TDD Agent
    MARKDOWN

    docs_dir = @base.join('docs')
    docs_dir.mkpath
    docs_dir.join('overview.md').write('# Overview')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_call_returns_structured_agent_metadata
    result = McpSkills::ListAgentsTool.call(project_root: @base, server_context: {})

    assert_instance_of MCP::Tool::Response, result
    assert_equal 1, result.structured_content[:count]

    tdd = result.structured_content[:agents].find { |a| a[:name] == 'tdd' }
    refute_nil tdd, "Expected 'tdd' agent in structured_content[:agents]"
    assert_equal 'agents/tdd/SKILL.md', tdd[:path]
    assert_equal 'Full TDD feature cycle', tdd[:description]
    assert_equal 'tdd, testing, red-green-refactor', tdd[:keywords]
    assert_includes result.content.first[:text], 'tdd'
  end

  def test_tool_schema_and_annotations_describe_read_only_no_arg_result
    tool_hash = McpSkills::ListAgentsTool.to_h

    assert_equal 'List Rails Agents', tool_hash[:title]
    assert_equal({}, tool_hash[:inputSchema].fetch(:properties))
    assert_equal false, tool_hash[:inputSchema].fetch(:additionalProperties)
    assert_includes tool_hash[:outputSchema].fetch(:required), 'agents'
    assert_equal true, tool_hash[:annotations].fetch(:readOnlyHint)
    assert_equal false, tool_hash[:annotations].fetch(:destructiveHint)
    assert_equal true, tool_hash[:annotations].fetch(:idempotentHint)
    assert_equal false, tool_hash[:annotations].fetch(:openWorldHint)
  end

  def test_call_returns_empty_result_when_no_agents_exist
    empty_base = Pathname.new(Dir.mktmpdir('empty_agents_test'))
    docs = empty_base.join('docs')
    docs.mkpath
    docs.join('overview.md').write('# Overview')

    result = McpSkills::ListAgentsTool.call(project_root: empty_base, server_context: {})
    assert_instance_of MCP::Tool::Response, result
    assert_equal 0, result.structured_content[:count]
    assert_empty result.structured_content[:agents]
  ensure
    FileUtils.remove_entry(empty_base) if empty_base && Dir.exist?(empty_base.to_s)
  end

end
