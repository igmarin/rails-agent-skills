#!/bin/bash

# Rails Agent Skills - Plugin Validator
#
# This script validates:
# - Valid JSON syntax for .tessl-plugin/plugin.json
# - SKILL.md frontmatter consistency
# - plugin.json synchronization with disk
#
# Usage: ./scripts/validate-plugins.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

section() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required but not installed.${NC}"
  echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

PLUGIN_FILE=".tessl-plugin/plugin.json"

section "Validating Plugin Manifest"

if [ ! -f "$PLUGIN_FILE" ]; then
  check_fail "File not found: $PLUGIN_FILE"
  exit 1
fi

if jq empty "$PLUGIN_FILE" 2>/dev/null; then
  check_pass "Valid JSON syntax"
else
  check_fail "Invalid JSON syntax"
fi

for field in "name" "version" "description" "skills"; do
  if jq -e ".$field" "$PLUGIN_FILE" > /dev/null 2>&1; then
    check_pass "Field present: $field"
  else
    check_fail "Field missing: $field"
  fi
done

section "Validating SKILL.md Frontmatter"

skill_count=0
while IFS= read -r skill_file; do
  skill_count=$((skill_count + 1))
  skill_name=$(basename "$(dirname "$skill_file")")

  if head -n 1 "$skill_file" | grep -q "^---$"; then
    check_pass "$skill_name: YAML frontmatter found"
  else
    check_fail "$skill_name: Missing YAML frontmatter start (---)"
  fi

  if grep -q "^name:" "$skill_file"; then
    check_pass "$skill_name: Has 'name' field"
  else
    check_fail "$skill_name: Missing 'name' field"
  fi

  if grep -q "^type:" "$skill_file"; then
    check_pass "$skill_name: Has 'type' field"
  else
    check_fail "$skill_name: Missing 'type' field"
  fi

  fm_name=$(awk '/^---$/{f++; next} f==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$skill_file")
  if [ -n "$fm_name" ] && [ "$fm_name" != "$skill_name" ]; then
    check_fail "$skill_name: frontmatter name ('$fm_name') does not match directory name"
  fi
done < <(find skills -name "SKILL.md" -not -path "*/.tessl/*" | sort)

info "Total SKILL.md files found: $skill_count"

section "plugin.json ↔ Disk Sync"

# Handle both auto-discovery (string) and explicit (array) formats
SKILLS_TYPE=$(jq -r '.skills | type' "$PLUGIN_FILE" 2>/dev/null)

if [ "$SKILLS_TYPE" = 'string' ]; then
  # Auto-discovery format: "skills": "./skills/"
  SKILLS_DIR=$(jq -r '.skills' "$PLUGIN_FILE" 2>/dev/null)
  info "Auto-discovery mode: skills = $SKILLS_DIR"

  if [ -d "$SKILLS_DIR" ]; then
    check_pass "Skills directory exists: $SKILLS_DIR"
  else
    check_fail "Skills directory not found: $SKILLS_DIR"
  fi

  # Validate all discovered skills have SKILL.md
  # Normalize paths: strip trailing /SKILL.md and leading ./ for comparison
  DISCOVERED_SKILLS=$(find "$SKILLS_DIR" -name "SKILL.md" -not -path "*/.tessl/*" | sed 's#/[^/]*$##' | sed 's/^\.\///' | sort -u)
  DISK_SKILL_DIRS=$(find skills -name "SKILL.md" -not -path "*/.tessl/*" | sed 's#/[^/]*$##' | sed 's/^\.\///' | sort)

  while IFS= read -r path; do
    [ -z "$path" ] && continue
    if printf '%s\n' "$DISCOVERED_SKILLS" | grep -Fxq "$path"; then
      check_pass "Auto-discovered: $path"
    else
      check_fail "Not auto-discovered: $path"
    fi
  done <<< "$DISK_SKILL_DIRS"
elif [ "$SKILLS_TYPE" = 'array' ]; then
  # Explicit array format: "skills": ["./skills/..."]
  # Normalize plugin.json paths: strip leading ./ for comparison
  PLUGIN_SKILL_PATHS=$(jq -r '.skills[]' "$PLUGIN_FILE" 2>/dev/null | sed 's/^\.\///' | sort)
  DISK_SKILL_DIRS=$(find skills -name "SKILL.md" -not -path "*/.tessl/*" | sed 's#/[^/]*$##' | sed 's/^\.\///' | sort)

  while IFS= read -r path; do
    [ -z "$path" ] && continue
    if printf '%s\n' "$PLUGIN_SKILL_PATHS" | grep -Fxq "$path"; then
      check_pass "plugin.json includes: $path"
    else
      check_fail "plugin.json missing: $path"
    fi
  done <<< "$DISK_SKILL_DIRS"
else
  check_fail "Unsupported .skills type in plugin.json: $SKILLS_TYPE (expected 'string' or 'array')"
fi

PERSONA_PATHS=$(find skills/personas -name "SKILL.md" -not -path "*/.tessl/*" | sort)
if [ -n "$PERSONA_PATHS" ]; then
  info "Persona SKILL.md files:"
  while IFS= read -r path; do
    info "  $path"
  done <<< "$PERSONA_PATHS"
  has_type_field=$(grep -l "^type: persona" $PERSONA_PATHS 2>/dev/null | wc -l)
  persona_count=$(echo "$PERSONA_PATHS" | wc -l | tr -d ' ')
  if [ "$has_type_field" -eq "$persona_count" ]; then
    check_pass "All persona SKILL.md files have type: persona"
  else
    check_fail "Some persona SKILL.md files missing type: persona"
  fi
fi

section "Summary"
echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"

if [ "$CHECKS_FAILED" -eq 0 ]; then
  echo -e "${GREEN}All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}$CHECKS_FAILED validation(s) failed.${NC}"
  exit 1
fi
