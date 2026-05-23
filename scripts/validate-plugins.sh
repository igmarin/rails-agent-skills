#!/bin/bash

# Rails Agent Skills - Manifest Validator
#
# This script validates:
# - Valid JSON syntax for tile.json
# - SKILL.md frontmatter consistency
# - tile.json synchronization with disk
#
# Usage: ./scripts/validate-plugins.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Helper functions
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

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required but not installed.${NC}"
  echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"

section "Validating Tile Manifest"

# Validate Tessl tile.json
if [ ! -f "tile.json" ]; then
  check_fail "File not found: tile.json"
else
  if jq empty tile.json 2>/dev/null; then
    check_pass "Valid JSON syntax"
  else
    check_fail "Invalid JSON syntax"
  fi

  for field in "name" "version" "summary" "skills"; do
    if jq -e ".$field" tile.json > /dev/null 2>&1; then
      check_pass "Field present: $field"
    else
      check_fail "Field missing: $field"
    fi
  done
fi

# Validate SKILL.md files
section "Validating SKILL.md Frontmatter"

skill_count=0
while IFS= read -r skill_file; do
  skill_count=$((skill_count + 1))
  skill_name=$(basename "$(dirname "$skill_file")")

  # Check if first line is ---
  if head -n 1 "$skill_file" | grep -q "^---$"; then
    check_pass "$skill_name: YAML frontmatter found"
  else
    check_fail "$skill_name: Missing YAML frontmatter start (---)"
  fi

  # Check for required YAML fields
  if grep -q "^name:" "$skill_file"; then
    check_pass "$skill_name: Has 'name' field"
  else
    check_fail "$skill_name: Missing 'name' field"
  fi

  # Frontmatter name must match directory name
  fm_name=$(awk '/^---$/{f++; next} f==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$skill_file")
  if [ -n "$fm_name" ] && [ "$fm_name" != "$skill_name" ]; then
    check_fail "$skill_name: frontmatter name ('$fm_name') does not match directory name"
  fi
done < <(find skills agents -name "SKILL.md" -not -path "*/.tessl/*" | sort)

info "Total SKILL.md files found: $skill_count"

# Cross-check: every public publishable skill dir with SKILL.md must be in tile.json.skills.
# Root agents are repo-local orchestrations and are intentionally excluded from the Tessl tile.
section "tile.json ↔ Disk Sync"

if [ -f "tile.json" ]; then
  TILE_SKILL_PATHS=$(jq -r '.skills | .[].path' tile.json 2>/dev/null | sort)
  DISK_SKILL_PATHS=$(find skills -name "SKILL.md" -not -path "*/.tessl/*" | sed 's#^\./##' | sort)

  while IFS= read -r path; do
    if printf '%s\n' "$TILE_SKILL_PATHS" | grep -qx "$path"; then
      check_pass "tile.json includes: $path"
    else
      check_fail "tile.json missing: $path"
    fi
  done <<< "$DISK_SKILL_PATHS"

  AGENT_PATHS=$(find agents -name "SKILL.md" -not -path "*/.tessl/*" | sed 's#^\./##' | sort)
  while IFS= read -r path; do
    if printf '%s\n' "$TILE_SKILL_PATHS" | grep -qx "$path"; then
      check_fail "tile.json should not include agent: $path"
    else
      check_pass "agent excluded from Tessl tile: $path"
    fi
  done <<< "$AGENT_PATHS"
fi

# Summary
section "Summary"
echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"

if [ "$CHECKS_FAILED" -eq 0 ]; then
  echo -e "${GREEN}✅ All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ $CHECKS_FAILED validation(s) failed.${NC}"
  exit 1
fi
