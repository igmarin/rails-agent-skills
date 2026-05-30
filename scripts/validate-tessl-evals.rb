#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
EVAL_ROOT = File.join(ROOT, "tessl-evals")
SKILLS_DIR = File.join(ROOT, "skills")

def read_json(path)
  JSON.parse(File.read(path))
rescue JSON::ParserError => e
  abort "Invalid JSON in #{path}: #{e.message}"
end

def fail_with(message)
  warn "x #{message}"
  $failures += 1
end

def pass_with(message)
  puts "#{message}"
end

$failures = 0

publishable_skill_paths = Dir.glob("**/SKILL.md", base: SKILLS_DIR).reject { |path|
  path.start_with?("workflows/") || path.start_with?("agents/")
}
expected_names = publishable_skill_paths.map { |path| File.basename(File.dirname(path)) }.to_set

unless Dir.exist?(EVAL_ROOT)
  abort "Missing tessl-evals/ directory"
end

actual_names = Dir.children(EVAL_ROOT).select { |entry| File.directory?(File.join(EVAL_ROOT, entry)) }.to_set

(expected_names - actual_names).sort.each { |name| fail_with("missing tessl-evals/#{name}") }
(actual_names - expected_names).sort.each { |name| fail_with("unexpected tessl-evals/#{name}") }

expected_names.sort.each do |name|
  dir = File.join(EVAL_ROOT, name)
  next unless Dir.exist?(dir)

  %w[instructions.json summary.json summary_infeasible.json].each do |file|
    path = File.join(dir, file)
    File.file?(path) ? read_json(path) : fail_with("#{name} missing #{file}")
  end

  scenarios = Dir.children(dir).grep(/\Ascenario-\d+\z/).sort
  fail_with("#{name} has no scenario directories") if scenarios.empty?

  scenarios.each_with_index do |scenario, index|
    fail_with("#{name} scenario numbering has a gap at scenario-#{index}") unless scenario == "scenario-#{index}"

    scenario_dir = File.join(dir, scenario)
    %w[capability.txt task.md criteria.json].each do |file|
      path = File.join(scenario_dir, file)
      File.file?(path) ? pass_with("#{name}/#{scenario} has #{file}") : fail_with("#{name}/#{scenario} missing #{file}")
    end

    criteria_path = File.join(scenario_dir, "criteria.json")
    next unless File.file?(criteria_path)

    criteria = read_json(criteria_path)
    fail_with("#{name}/#{scenario} criteria type must be weighted_checklist") unless criteria["type"] == "weighted_checklist"
    checklist = criteria["checklist"]
    if checklist.is_a?(Array) && checklist.any?
      total = checklist.sum { |item| item.fetch("max_score") }
      total == 100 ? pass_with("#{name}/#{scenario} criteria total is 100") : fail_with("#{name}/#{scenario} criteria total is #{total}")
    else
      fail_with("#{name}/#{scenario} criteria checklist is empty")
    end
  end
end

if $failures.positive?
  abort "Failed: #{$failures}"
end

puts "All Tessl eval validations passed for #{expected_names.length} publishable skills."
