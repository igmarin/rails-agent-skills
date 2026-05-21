#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
tile = JSON.parse(File.read(File.join(ROOT, "tile.json")))
publishable_paths = tile.fetch("skills").values.map { |spec| spec.fetch("path") }.reject { |path| path.start_with?("workflows/") || path.start_with?("agents/") }
changed_files = STDIN.read.lines.map(&:strip).reject(&:empty?)

changed_skill_paths = publishable_paths.select do |skill_path|
  skill_dir = File.dirname(skill_path)
  changed_files.any? { |path| path == skill_path || path.start_with?("#{skill_dir}/") }
end

puts changed_skill_paths.join("\n")
