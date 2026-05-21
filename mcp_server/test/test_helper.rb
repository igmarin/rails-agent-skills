# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'fileutils'
require 'pathname'
require 'tmpdir'

REPO_ROOT = Pathname.new(__dir__).join('..', '..').realpath

def build_fixture_tree(base_dir)
  base = Pathname.new(base_dir)

  {
    'skills/code-quality' => ['code-review'],
    'skills/testing' => ['plan-tests'],
    'skills/patterns' => ['create-service-object']
  }.each do |parent, skills|
    skills.each do |skill|
      dir = base.join(parent, skill)
      dir.mkpath
      dir.join('SKILL.md').write("# #{skill}\nSkill content for #{skill}.")
      dir.join('EXAMPLES.md').write("# Examples for #{skill}")
    end
  end

  base.join('skill-template').mkpath
  base.join('skill-template').join('SKILL.md').write('# Template')

  docs_dir = base.join('docs')
  docs_dir.mkpath
  docs_dir.join('workflow-guide.md').write('# Workflow Guide')
  docs_dir.join('overview.md').write('# Overview')
  docs_dir.join('workflows').mkpath
  docs_dir.join('workflows', 'discovery.md').write('# Discovery Docs')

  agent_dir = base.join('agents', 'review')
  agent_dir.mkpath
  agent_dir.join('SKILL.md').write('# review agent')
  agent_dir.join('EXAMPLES.md').write('# Agent examples')

  tessl_dir = base.join('.tessl', 'tiles', 'owner', 'repo', 'code-review')
  tessl_dir.mkpath
  tessl_dir.join('SKILL.md').write('# Duplicate tessl skill')

  write_tile_manifest(
    base,
    {
      'code-review' => 'skills/code-quality/code-review/SKILL.md',
      'plan-tests' => 'skills/testing/plan-tests/SKILL.md',
      'create-service-object' => 'skills/patterns/create-service-object/SKILL.md'
    }
  )
end

def write_tile_manifest(base_dir, skills)
  base = Pathname.new(base_dir)
  base.join('tile.json').write(
    "#{JSON.pretty_generate({ 'name' => 'test/tile', 'version' => '0.0.0', 'skills' => skills.transform_values { |path| { 'path' => path } } })}\n"
  )
end
