# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/doc_resource_builder'

class DocResourceBuilderTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('doc_builder_test')
    base = Pathname.new(@tmpdir)

    @docs_dir = base.join('docs')
    @docs_dir.mkpath
    @docs_dir.join('workflow-guide.md').write('# Workflow Guide')
    @docs_dir.join('overview.md').write('# Overview')

    @workflows_dir = base.join('.windsurf', 'workflows')
    @workflows_dir.mkpath
    @workflows_dir.join('deploy.md').write('# Deploy Workflow')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_builds_doc_resources_from_docs_dir
    resources = McpSkills::DocResourceBuilder.call(@docs_dir, prefix: 'doc')
    names = resources.map(&:name)
    assert_includes names, 'doc/workflow-guide'
    assert_includes names, 'doc/overview'
  end

  def test_builds_workflow_resources_from_workflows_dir
    resources = McpSkills::DocResourceBuilder.call(@workflows_dir, prefix: 'workflow')
    names = resources.map(&:name)
    assert_includes names, 'workflow/deploy'
  end

  def test_resources_have_file_uris
    resources = McpSkills::DocResourceBuilder.call(@docs_dir, prefix: 'doc')
    resources.each do |r|
      assert r.uri.start_with?('file://'), "Expected file:// URI, got: #{r.uri}"
    end
  end

  def test_resources_have_markdown_mime_type
    resources = McpSkills::DocResourceBuilder.call(@docs_dir, prefix: 'doc')
    resources.each do |r|
      assert_equal 'text/markdown', r.mime_type
    end
  end

  def test_returns_empty_array_for_nonexistent_dir
    nonexistent = Pathname.new(@tmpdir).join('does_not_exist')
    resources = McpSkills::DocResourceBuilder.call(nonexistent, prefix: 'doc')
    assert_equal [], resources
  end

  def test_ignores_non_markdown_files
    @docs_dir.join('notes.txt').write('plain text')
    resources = McpSkills::DocResourceBuilder.call(@docs_dir, prefix: 'doc')
    resources.each do |r|
      assert r.uri.end_with?('.md'), "Expected only .md files, got: #{r.uri}"
    end
  end
end
