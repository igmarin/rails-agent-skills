# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/resource_discovery'

class ResourceDiscoveryTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('resource_discovery_test')
    build_fixture_tree(@tmpdir)
    @discovery = McpSkills::ResourceDiscovery.call(@tmpdir)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_discovers_nested_skills
    skill_dirs = @discovery.skill_dirs.map { |dir| dir.relative_path_from(Pathname.new(@tmpdir)).to_s }

    assert_includes skill_dirs, 'skills/code-quality/code-review'
    assert_includes skill_dirs, 'skills/testing/plan-tests'
    assert_includes skill_dirs, 'skills/patterns/create-service-object'
  end

  def test_discovers_root_agents
    agent_dirs = @discovery.agent_dirs.map { |dir| dir.relative_path_from(Pathname.new(@tmpdir)).to_s }

    assert_equal ['agents/review'], agent_dirs
  end

  def test_workflow_dirs_compat_returns_agents
    workflow_dirs = @discovery.workflow_dirs.map { |dir| dir.relative_path_from(Pathname.new(@tmpdir)).to_s }

    assert_equal ['agents/review'], workflow_dirs
  end

  def test_deduplicates_tessl_skill_duplicates_by_name
    skill_names = @discovery.skill_dirs.map(&:basename).map(&:to_s)

    assert_equal 1, skill_names.count('code-review')
  end

  def test_keeps_non_tessl_duplicates_in_different_categories
    duplicate_dir = Pathname.new(@tmpdir).join('skills', 'testing', 'code-review')
    duplicate_dir.mkpath
    duplicate_dir.join('SKILL.md').write('# code-review testing variant')

    discovery = McpSkills::ResourceDiscovery.call(@tmpdir)
    matching_dirs = discovery.skill_dirs.select { |dir| dir.basename.to_s == 'code-review' }

    assert_equal 2, matching_dirs.size
    assert_includes matching_dirs.map { |dir| dir.relative_path_from(Pathname.new(@tmpdir)).to_s },
                    'skills/code-quality/code-review'
    assert_includes matching_dirs.map { |dir| dir.relative_path_from(Pathname.new(@tmpdir)).to_s },
                    'skills/testing/code-review'
  end
end
