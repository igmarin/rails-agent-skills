#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

section() {
  printf '\n%s\n' "$1"
}

fail() {
  printf '✗ %s\n' "$1"
  failures=$((failures + 1))
}

pass() {
  printf '✓ %s\n' "$1"
}

section "Validating personal eval scenarios"

if [[ ! -d personal-evals ]]; then
  fail "personal-evals/ directory is missing"
else
  pass "personal-evals/ directory exists"
fi

while IFS= read -r scenario_dir; do
  relative_dir="${scenario_dir#./}"

  # Skip if it is a helper/fixture directory and not a scenario
  if [[ ! -f "$scenario_dir/task.md" && ! -f "$scenario_dir/criteria.json" && ! -f "$scenario_dir/metadata.json" ]]; then
    continue
  fi

  [[ -f "$scenario_dir/task.md" ]] || fail "$relative_dir is missing task.md"
  [[ -f "$scenario_dir/criteria.json" ]] || fail "$relative_dir is missing criteria.json"
  [[ -f "$scenario_dir/metadata.json" ]] || fail "$relative_dir is missing metadata.json"

  if [[ -f "$scenario_dir/criteria.json" ]]; then
    ruby -rjson -e '
      data = JSON.parse(File.read(ARGV.fetch(0)))
      if data.key?("dimensions")
        dimensions = data.fetch("dimensions")
        total = dimensions.sum { |item| item.fetch("max_score") }
        abort "criteria total must be 100, got #{total}" unless total == 100
      else
        abort "missing weighted_checklist type" unless data["type"] == "weighted_checklist"
        checklist = data.fetch("checklist")
        total = checklist.sum { |item| item.fetch("max_score") }
        abort "criteria total must be 100, got #{total}" unless total == 100
      end
    ' "$scenario_dir/criteria.json" \
      && pass "$relative_dir criteria.json is valid" \
      || fail "$relative_dir criteria.json failed validation"
  fi

  if [[ -f "$scenario_dir/metadata.json" ]]; then
    ruby -rjson -e '
      root = ARGV.fetch(0)
      scenario_dir = ARGV.fetch(1)
      data = JSON.parse(File.read(File.join(scenario_dir, "metadata.json")))

      required = %w[id target_type target_name context_mode requires_companion_resources]
      missing = required.reject { |key| data.key?(key) }
      abort "missing required keys: #{missing.join(", ")}" unless missing.empty?

      abort "id must match directory name" unless data.fetch("id") == File.basename(scenario_dir)
      abort "target_type must be skill, persona, or workflow" unless %w[skill persona workflow].include?(data.fetch("target_type"))
      abort "context_mode must be skill_bundle_xml" unless data.fetch("context_mode") == "skill_bundle_xml"
      abort "requires_companion_resources must be boolean" unless [true, false].include?(data.fetch("requires_companion_resources"))

      root_path = File.realpath(root)
      validate_paths = lambda do |field, paths, skill_only|
        abort "#{field} must be an array" unless paths.is_a?(Array)
        paths.each do |relative|
          abort "#{field} entries must be non-empty relative paths" unless relative.is_a?(String) && !relative.empty? && !relative.start_with?(File::SEPARATOR)

          candidate = File.expand_path(relative, root_path)
          resolved = File.realpath(candidate)
          abort "#{field} path escapes repository: #{relative}" unless resolved.start_with?(root_path + File::SEPARATOR)
          abort "#{field} path is not a file: #{relative}" unless File.file?(resolved)
          abort "#{field} skill dependency must end in SKILL.md: #{relative}" if skill_only && File.basename(resolved) != "SKILL.md"
        rescue Errno::ENOENT
          abort "#{field} path does not exist: #{relative}"
        end
      end
      companion_resources = data.fetch("companion_resources", [])
      skill_dependencies = data.fetch("skill_dependencies", [])
      abort "requires_companion_resources is true but companion_resources is empty" if data.fetch("requires_companion_resources") && companion_resources.empty?
      validate_paths.call("companion_resources", companion_resources, false)
      validate_paths.call("skill_dependencies", skill_dependencies, true)

      target_name = data.fetch("target_name")
      target_type = data.fetch("target_type")
      local_paths = Dir[File.join(root, "skills", "**", target_name, "SKILL.md")]
      core_paths = Dir[File.join(root, "..", "ruby-core-skills", "skills", "**", target_name, "SKILL.md")]
      target_path = (local_paths + core_paths).first

      abort "target SKILL.md not found for #{target_name}" unless target_path && File.file?(target_path)
    ' "$ROOT_DIR" "$scenario_dir" \
      && pass "$relative_dir metadata.json is valid" \
      || fail "$relative_dir metadata.json failed validation"
  fi
done < <(find personal-evals -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

if [[ "$failures" -gt 0 ]]; then
  printf '\nFailed: %d\n' "$failures"
  exit 1
fi

printf '\nAll eval validations passed.\n'
