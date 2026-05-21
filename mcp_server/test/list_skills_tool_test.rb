# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/list_skills_tool'

class ListSkillsToolTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('list_skills_tool_test')
    @base = Pathname.new(@tmpdir)
    build_fixture_tree(@base)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_call_returns_structured_skill_metadata
    result = McpSkills::ListSkillsTool.call(project_root: @base, server_context: {})

    assert_instance_of MCP::Tool::Response, result
    assert_equal 3, result.structured_content[:count]
    refute_includes result.structured_content[:skills].map { |skill| skill[:name] }, 'converting-skill-to-tessl-tile'

    code_review = result.structured_content[:skills].find { |skill| skill[:name] == 'code-review' }
    refute_nil code_review, "Expected 'code-review' skill in structured_content[:skills]"
    assert_equal 'skills/code-quality/code-review/SKILL.md', code_review[:path]
    assert_equal 'code-quality', code_review[:category]
    assert_includes result.content.first[:text], 'code-review'
  end

  def test_tool_schema_and_annotations_describe_read_only_no_arg_result
    tool_hash = McpSkills::ListSkillsTool.to_h

    assert_equal 'List Rails Skills', tool_hash[:title]
    assert_equal({}, tool_hash[:inputSchema].fetch(:properties))
    assert_equal false, tool_hash[:inputSchema].fetch(:additionalProperties)
    assert_includes tool_hash[:outputSchema].fetch(:required), 'skills'
    assert_equal true, tool_hash[:annotations].fetch(:readOnlyHint)
    assert_equal false, tool_hash[:annotations].fetch(:destructiveHint)
    assert_equal true, tool_hash[:annotations].fetch(:idempotentHint)
    assert_equal false, tool_hash[:annotations].fetch(:openWorldHint)
  end

  def test_call_raises_clear_manifest_error_when_tile_json_is_missing
    FileUtils.rm(@base.join('tile.json'))

    error = assert_raises(McpSkills::SkillCatalog::ManifestError) do
      McpSkills::ListSkillsTool.call(project_root: @base, server_context: {})
    end

    assert_match(/tile\.json/, error.message)
  end

  def test_call_rejects_manifest_paths_outside_project_root
    write_tile_manifest(@base, { 'escape' => '../outside/SKILL.md' })

    error = assert_raises(McpSkills::SkillCatalog::ManifestError) do
      McpSkills::ListSkillsTool.call(project_root: @base, server_context: {})
    end

    assert_match(/outside project root/, error.message)
  end
end
