#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
OUTPUT_ROOT = File.join(ROOT, "tessl-evals")
SKILLS_DIR = File.join(ROOT, "skills")

Instruction = Struct.new(:text, :snippet, :why_given, keyword_init: true)

def read_json(path)
  JSON.parse(File.read(path))
rescue JSON::ParserError => e
  abort "Invalid JSON in #{path}: #{e.message}"
end

def split_frontmatter(markdown)
  return [{}, markdown] unless markdown.start_with?("---\n")

  _, yaml, body = markdown.split(/^---\s*$/, 3)
  [YAML.safe_load(yaml, permitted_classes: [], aliases: false) || {}, body.to_s]
rescue Psych::SyntaxError
  [{}, markdown]
end

def sentence_from_description(text)
  text.to_s.split(/(?<=[.!?])\s+/).find { |sentence| sentence.match?(/[[:alpha:]]/) }.to_s.strip
end

def instruction_candidates(markdown)
  lines = markdown.lines.map(&:strip)
  lines.each_with_object([]) do |line, list|
    next if line.empty?
    next if line.start_with?("```", "|", "---", "#")

    normalized = line.sub(/\A[-*]\s+/, "").sub(/\A\d+\.\s+/, "").strip
    next if normalized.length < 24
    next unless normalized.match?(/\b(MUST|SHOULD|should|must|Use|Do not|Don't|Never|Always|Run|Verify|Load|Create|Write|Review|Check|Avoid|Prefer)\b/)

    list << normalized
  end
end

def fallback_instructions(skill_name, description)
  [
    "Use the #{skill_name} skill only for tasks that match its documented trigger and scope.",
    "Follow the skill-specific workflow and gates instead of giving generic Rails advice.",
    "Produce concrete artifacts requested by the task in English unless another language is explicitly requested.",
    "Call out assumptions, constraints, and verification steps that matter for the task."
  ].map do |text|
    Instruction.new(text: text, snippet: description, why_given: "preference")
  end
end

def extract_instructions(skill_name, skill_path)
  markdown = File.read(File.join(ROOT, skill_path))
  metadata, body = split_frontmatter(markdown)
  description = sentence_from_description(metadata["description"])

  candidates = instruction_candidates(body).uniq.first(12)
  instructions = candidates.map do |candidate|
    why =
      if candidate.match?(/\b(MUST|must|Never|Do not|Don't|HARD-GATE)\b/)
        "preference"
      elsif candidate.match?(/\b(Use|Run|Verify|Load|Create|Write|Review|Check)\b/)
        "new knowledge"
      else
        "reminder"
      end

    Instruction.new(text: candidate, snippet: candidate, why_given: why)
  end

  instructions = fallback_instructions(skill_name, description) if instructions.empty?
  [description, instructions]
end

def weighted_checklist(instructions)
  selected = instructions.first(10)
  selected = instructions if selected.empty?
  base_score = 100 / selected.length
  remainder = 100 - (base_score * selected.length)

  selected.each_with_index.map do |instruction, index|
    {
      "name" => "instruction-#{index + 1}",
      "description" => "The submitted artifact follows this skill instruction: #{instruction.text}",
      "max_score" => base_score + (index < remainder ? 1 : 0)
    }
  end
end

def write_json(path, data)
  File.write(path, "#{JSON.pretty_generate(data)}\n")
end

def write_skill_eval(skill_name, skill_path)
  description, instructions = extract_instructions(skill_name, skill_path)
  target_dir = File.join(OUTPUT_ROOT, skill_name)
  scenario_dir = File.join(target_dir, "scenario-0")

  FileUtils.mkdir_p(scenario_dir)

  write_json(
    File.join(target_dir, "instructions.json"),
    {
      "target_skill" => skill_name,
      "source_path" => skill_path,
      "instructions" => instructions.map do |instruction|
        {
          "instruction" => instruction.text,
          "original_snippets" => instruction.snippet,
          "relevant_when" => "When a user asks for Rails work that should trigger #{skill_name}.",
          "why_given" => instruction.why_given
        }
      end
    }
  )

  write_json(
    File.join(target_dir, "summary.json"),
    {
      "target_skill" => skill_name,
      "total_scenarios" => 1,
      "instructions_coverage" => {
        "total_instructions" => instructions.length,
        "instructions_tested" => [instructions.length, 10].min,
        "coverage_percentage" => ((([instructions.length, 10].min.to_f / instructions.length) * 100).round)
      },
      "reason_distribution" => instructions.group_by(&:why_given).transform_values(&:length)
    }
  )

  write_json(
    File.join(target_dir, "summary_infeasible.json"),
    {
      "target_skill" => skill_name,
      "total_infeasible" => 0,
      "infeasible_scenarios" => []
    }
  )

  File.write(File.join(scenario_dir, "capability.txt"), "#{skill_name} workflow adherence\n")
  File.write(
    File.join(scenario_dir, "task.md"),
    <<~MARKDOWN
      # #{skill_name.split("-").map(&:capitalize).join(" ")} Task

      ## Problem

      A Rails team needs help with a task in this area:

      #{description.empty? ? "Use the repository's Rails skill conventions to produce the requested result." : description}

      The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

      ## Output

      Create `answer.md` with:

      - a short plan for the work
      - the concrete Rails-oriented artifact or recommendation
      - the verification steps or quality gates that should be run
      - any assumptions that affect the result
    MARKDOWN
  )

  write_json(
    File.join(scenario_dir, "criteria.json"),
    {
      "context" => "Checks whether the final artifact follows the #{skill_name} instructions from the published Rails Agent Skills plugin.",
      "type" => "weighted_checklist",
      "checklist" => weighted_checklist(instructions)
    }
  )
end

skills = Dir.glob("**/SKILL.md", base: SKILLS_DIR).each_with_object({}) do |path, hash|
  next if path.start_with?("workflows/") || path.start_with?("agents/")
  name = File.basename(File.dirname(path))
  hash[name] = { "path" => "skills/#{path}" }
end

FileUtils.mkdir_p(OUTPUT_ROOT)

skills.each do |skill_name, spec|
  skill_path = spec.fetch("path")
  write_skill_eval(skill_name, skill_path)
end

puts "Generated Tessl eval source for #{skills.length} publishable skills in tessl-evals/"
