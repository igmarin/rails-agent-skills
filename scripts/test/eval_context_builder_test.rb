# frozen_string_literal: true

require 'minitest/autorun'
require 'rexml/document'
require 'tmpdir'
require_relative '../eval_context_builder'

class EvalContextBuilderTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('eval_context_builder_test')
    @root = Pathname.new(@tmpdir)

    skill_dir = @root.join('skills', 'patterns', 'create-service-object')
    skill_dir.mkpath
    skill_dir.join('SKILL.md').write(<<~MARKDOWN)
      ---
      name: create-service-object
      description: Use when creating service objects.
      ---
      # Create Service Object
    MARKDOWN
    skill_dir.join('EXAMPLES.md').write('# Examples')
    skill_dir.join('notes.bin').write("\x00\x01")
    skill_dir.join('assets', 'service_skeleton.md').tap do |path|
      path.dirname.mkpath
      path.write('# Skeleton')
    end
    skill_dir.join('assets', 'schema.json').write('{"type":"object"}')

    agent_dir = @root.join('agents', 'tdd')
    agent_dir.mkpath
    agent_dir.join('SKILL.md').write("# TDD Agent\n")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_builds_xml_with_primary_and_companion_resources
    xml = EvalContextBuilder.new(repo_root: @root).call(
      target_path: 'skills/patterns/create-service-object'
    )
    document = REXML::Document.new(xml)

    assert_equal 'skill_context', document.root.name
    assert_equal 'skill', document.root.attributes['target_type']
    assert_equal 'create-service-object', document.root.attributes['target_name']
    assert_equal 'skills/patterns/create-service-object/SKILL.md',
                 REXML::XPath.first(document, '/skill_context/primary').attributes['path']

    resource_paths = REXML::XPath.match(document, '/skill_context/resources/resource').map do |node|
      node.attributes['path']
    end

    assert_equal [
      'skills/patterns/create-service-object/EXAMPLES.md',
      'skills/patterns/create-service-object/assets/schema.json',
      'skills/patterns/create-service-object/assets/service_skeleton.md'
    ], resource_paths
  end

  def test_infers_agent_target_type
    xml = EvalContextBuilder.new(repo_root: @root).call(target_path: 'agents/tdd')
    document = REXML::Document.new(xml)

    assert_equal 'agent', document.root.attributes['target_type']
    assert_equal 'tdd', document.root.attributes['target_name']
  end
end
