#!/bin/bash

# Rails Agent Skills - Skill Catalog Validator
#
# Validates:
# - Valid JSON syntax for directory.json
# - SKILL.md frontmatter consistency
# - directory.json synchronization with disk
#
# Usage: ./scripts/validate-skills.sh

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

DIRECTORY_FILE="directory.json"

section "Validating directory.json"

if [ ! -f "$DIRECTORY_FILE" ]; then
  check_fail "File not found: $DIRECTORY_FILE"
  exit 1
fi

if jq empty "$DIRECTORY_FILE" 2>/dev/null; then
  check_pass "Valid JSON syntax"
else
  check_fail "Invalid JSON syntax"
  exit 1
fi

for field in "name" "version" "skills"; do
  if jq -e ".$field" "$DIRECTORY_FILE" > /dev/null 2>&1; then
    check_pass "Field present: $field"
  else
    check_fail "Field missing: $field"
  fi
done

if jq -e '.skills | type == "object"' "$DIRECTORY_FILE" > /dev/null 2>&1; then
  check_pass "skills is an object map"
else
  check_fail "skills must be an object map of name -> { path }"
fi

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
done < <(find skills -name "SKILL.md" | sort)

info "Total SKILL.md files found: $skill_count"

section "directory.json ↔ Disk Sync"

# directory.json maps skill name -> { "path": "skills/.../SKILL.md" }
DIRECTORY_PATHS=$(jq -r '.skills | to_entries[] | .value.path' "$DIRECTORY_FILE" 2>/dev/null | sed 's/^\.\///' | sort)
DISK_SKILL_PATHS=$(find skills -name "SKILL.md" | sed 's/^\.\///' | sort)

while IFS= read -r path; do
  [ -z "$path" ] && continue
  if [ -f "$path" ]; then
    check_pass "directory.json path exists: $path"
  else
    check_fail "directory.json path missing on disk: $path"
  fi
done <<< "$DIRECTORY_PATHS"

while IFS= read -r path; do
  [ -z "$path" ] && continue
  if printf '%s\n' "$DIRECTORY_PATHS" | grep -Fxq "$path"; then
    check_pass "disk skill registered: $path"
  else
    check_fail "disk skill not in directory.json: $path"
  fi
done <<< "$DISK_SKILL_PATHS"

# name key should match directory basename of path
while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  name="${entry%%|*}"
  path="${entry#*|}"
  dir_name=$(basename "$(dirname "$path")")
  if [ "$name" = "$dir_name" ]; then
    check_pass "directory.json key matches path: $name"
  else
    check_fail "directory.json key '$name' does not match path dir '$dir_name' ($path)"
  fi
done < <(jq -r '.skills | to_entries[] | "\(.key)|\(.value.path)"' "$DIRECTORY_FILE")

PERSONA_PATHS=$(find skills/personas -name "SKILL.md" 2>/dev/null | sort)
if [ -n "$PERSONA_PATHS" ]; then
  info "Persona SKILL.md files:"
  while IFS= read -r path; do
    info "  $path"
  done <<< "$PERSONA_PATHS"
  has_type_field=$(grep -l "^type: persona" $PERSONA_PATHS 2>/dev/null | wc -l | tr -d ' ')
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
