#!/usr/bin/env bash
# Renders a Mermaid graph of the skill catalog from directory.json +
# skills.sh.json groupings + each skill's ## Integration table.
#
# Output: docs/reference/skill-graph.md
#
# Edges are derived from Integration tables: a row `| **other-skill** | ... |`
# in skill A's Integration table produces an edge A --> other-skill, but only
# if other-skill exists in directory.json (local skills only — core skills
# from ruby-core-skills are noted but not drawn, since they live in another
# repo and would clutter the graph).
#
# Usage: ./scripts/render-skill-graph.sh [--check]
#   --check   Regenerate to a temp file and diff against the committed file;
#             exit non-zero if they differ (for CI).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIRECTORY_FILE="$REPO_ROOT/directory.json"
SKILLS_SH_FILE="$REPO_ROOT/skills.sh.json"
OUTPUT_FILE="$REPO_ROOT/docs/reference/skill-graph.md"

if ! command -v jq &>/dev/null; then
  echo "jq is required (brew install jq / apt-get install jq)" >&2
  exit 1
fi

# All local skill names known to directory.json (one per line, sorted).
LOCAL_SKILLS=$(jq -r '.skills | keys[]' "$DIRECTORY_FILE" | sort)

# Emit the Mermaid graph to stdout.
render_graph() {
  echo "# Skill Graph"
  echo
  echo "Generated from \`directory.json\`, \`skills.sh.json\`, and each skill's \`## Integration\` table. Run \`./scripts/render-skill-graph.sh\` to regenerate."
  echo
  echo "## Catalog Graph"
  echo
  echo "\`\`\`mermaid"
  echo "graph LR"

  # Group subgraphs from skills.sh.json
  jq -r '
    .groupings[]
    | "  subgraph \(.title | gsub(" "; "_"))",
      (.skills[] | "    \(.)"),
      "  end"
  ' "$SKILLS_SH_FILE"

  # Personas subgraph (frontmatter type: persona)
  echo "  subgraph Personas"
  find "$REPO_ROOT/skills" -name SKILL.md | while IFS= read -r path; do
    grep -q '^type: persona' "$path" && basename "$(dirname "$path")"
  done | sed 's/^/    /'
  echo "  end"

  # Edges from Integration tables. For each local skill, scan its SKILL.md
  # for the Integration table and extract `| **name** |` references that
  # resolve to other local skills.
  while IFS= read -r skill_name; do
    skill_path=$(jq -r --arg name "$skill_name" '.skills[$name].path' "$DIRECTORY_FILE")
    skill_file="$REPO_ROOT/$skill_path"
    [ -f "$skill_file" ] || continue

    # Extract the Integration section, then pull bolded skill names from the
    # first column of the table. Strip the ** markers.
    awk '
      /^## Integration/ {in_int=1; next}
      /^## / && in_int {in_int=0}
      in_int && /^\|/ {
        # Skip header and separator rows
        if ($0 ~ /^\|[-[:space:]|]+\|$/) next
        if ($0 ~ /^\| Skill/) next
        # First data column is between the first two pipes
        cell = $0
        sub(/^\|/, "", cell)
        sub(/\|.*/, "", cell)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
        gsub(/\*\*/, "", cell)
        # Strip "(from ...)" suffixes
        sub(/[[:space:]]*\(from.*\)/, "", cell)
        if (cell != "" && cell != "Skill") print cell
      }
    ' "$skill_file" | while IFS= read -r referenced; do
      # Only draw edges to other local skills.
      if printf '%s\n' "$LOCAL_SKILLS" | grep -Fxq "$referenced" 2>/dev/null; then
        [ "$referenced" != "$skill_name" ] && echo "  $skill_name --> $referenced"
      fi
    done
  done <<< "$LOCAL_SKILLS"

  echo "\`\`\`"
  echo
  echo "## Notes"
  echo
  echo "- Edges are drawn from each skill's \`## Integration\` table (predecessor/successor references)."
  echo "- Only local skills in \`directory.json\` appear as nodes. Skills moved to \`ruby-core-skills\` (see \`deprecated_skills\` in \`directory.json\`) are not drawn — they live in a separate repo."
  echo "- Self-references are skipped. Duplicate edges are not deduplicated by Mermaid."
  echo "- Regenerate with \`./scripts/render-skill-graph.sh\`. Run \`./scripts/render-skill-graph.sh --check\` in CI to fail on drift."
}

if [ "${1:-}" = "--check" ]; then
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' EXIT
  render_graph > "$tmp"
  if [ ! -f "$OUTPUT_FILE" ]; then
    echo "skill-graph.md does not exist. Run ./scripts/render-skill-graph.sh to generate it." >&2
    exit 1
  fi
  if ! diff -u "$OUTPUT_FILE" "$tmp"; then
    echo "skill-graph.md is out of date. Run ./scripts/render-skill-graph.sh and commit the result." >&2
    exit 1
  fi
  echo "skill-graph.md is up to date."
  exit 0
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"
render_graph > "$OUTPUT_FILE"
echo "Wrote $OUTPUT_FILE"
