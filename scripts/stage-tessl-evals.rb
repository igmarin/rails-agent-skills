#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Deprecated: Tessl plugin mode auto-discovers evals/ directly.
# This script kept for reference but no longer needed.
# Use `tessl eval run .` instead.

require "fileutils"

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "evals")
DEFAULT_DESTINATION = File.join(ROOT, "evals")
DESTINATION = File.expand_path(ARGV[0] || DEFAULT_DESTINATION, ROOT)

abort "Missing evals/ source directory" unless Dir.exist?(SOURCE)
abort "Refusing to stage outside the repository: #{DESTINATION}" unless DESTINATION.start_with?(ROOT)

FileUtils.rm_rf(DESTINATION)
FileUtils.mkdir_p(DESTINATION)

Dir.children(SOURCE).sort.each do |entry|
  source_path = File.join(SOURCE, entry)
  next unless File.directory?(source_path)

  Dir.children(source_path).grep(/\Ascenario-\d+\z/).sort.each do |scenario|
    scenario_path = File.join(source_path, scenario)
    staged_name = scenario == "scenario-0" ? entry : "#{entry}-#{scenario}"

    FileUtils.cp_r(scenario_path, File.join(DESTINATION, staged_name))
  end
end

puts "Staged Tessl eval scenarios into #{DESTINATION.sub("#{ROOT}/", "")}"
