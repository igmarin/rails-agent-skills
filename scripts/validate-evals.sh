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

section "Validating eval ownership"

tracked_root_evals="$(git ls-files 'evals/**')"
if [[ -n "$tracked_root_evals" ]]; then
  fail "root evals/ is generated Tessl staging output and must not be tracked"
  printf '%s\n' "$tracked_root_evals"
else
  pass "root evals/ has no tracked files"
fi

section "Validating personal eval scenarios"

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

      required = %w[id target_type target_name context_mode requires_companion_resources tessl_export]
      missing = required.reject { |key| data.key?(key) }
      abort "missing required keys: #{missing.join(", ")}" unless missing.empty?

      abort "id must match directory name" unless data.fetch("id") == File.basename(scenario_dir)
      abort "target_type must be skill or agent" unless %w[skill agent].include?(data.fetch("target_type"))
      abort "context_mode must be skill_bundle_xml" unless data.fetch("context_mode") == "skill_bundle_xml"
      abort "requires_companion_resources must be boolean" unless [true, false].include?(data.fetch("requires_companion_resources"))

      tessl_export = data.fetch("tessl_export")
      abort "tessl_export.supported must be boolean" unless [true, false].include?(tessl_export["supported"])
      abort "tessl_export.reason is required" if tessl_export["reason"].to_s.strip.empty?

      target_name = data.fetch("target_name")
      target_path =
        if data.fetch("target_type") == "agent"
          File.join(root, "agents", target_name, "SKILL.md")
        else
          Dir[File.join(root, "skills", "*", target_name, "SKILL.md")].first
        end

      abort "target SKILL.md not found for #{target_name}" unless File.file?(target_path)
    ' "$ROOT_DIR" "$scenario_dir" \
      && pass "$relative_dir metadata.json is valid" \
      || fail "$relative_dir metadata.json failed validation"
  fi
done < <(find personal-evals -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$failures" -gt 0 ]]; then
  printf '\nFailed: %d\n' "$failures"
  exit 1
fi

printf '\nAll eval validations passed.\n'
