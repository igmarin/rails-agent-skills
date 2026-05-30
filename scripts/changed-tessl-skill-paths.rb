#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"

ROOT = File.expand_path("..", __dir__)
SKILLS_DIR = File.join(ROOT, "skills")

publishable_paths = Dir.glob("**/SKILL.md", base: SKILLS_DIR).reject { |path|
  path.start_with?("workflows/") || path.start_with?("agents/")
}.map { |path| "skills/#{path}" }

changed_files = STDIN.read.lines.map(&:strip).reject(&:empty?)

changed_skill_paths = publishable_paths.select do |skill_path|
  skill_dir = File.dirname(skill_path)
  changed_files.any? { |path| path == skill_path || path.start_with?("#{skill_dir}/") }
end

puts changed_skill_paths.join("\n")
