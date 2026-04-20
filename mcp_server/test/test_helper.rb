# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require 'tmpdir'

REPO_ROOT = Pathname.new(__dir__).join('..', '..').realpath

def build_fixture_tree(base_dir)
  base = Pathname.new(base_dir)

  skill_dirs = %w[rails-code-review rails-tdd-slices ruby-service-objects]
  skill_dirs.each do |skill|
    dir = base.join(skill)
    dir.mkpath
    dir.join('SKILL.md').write("# #{skill}\nSkill content for #{skill}.")
    dir.join('EXAMPLES.md').write("# Examples for #{skill}")
  end

  base.join('skill-template').mkpath
  base.join('skill-template').join('SKILL.md').write('# Template')

  docs_dir = base.join('docs')
  docs_dir.mkpath
  docs_dir.join('workflow-guide.md').write('# Workflow Guide')
  docs_dir.join('overview.md').write('# Overview')

  workflows_dir = base.join('.windsurf', 'workflows')
  workflows_dir.mkpath
  workflows_dir.join('deploy.md').write('# Deploy Workflow')
end
