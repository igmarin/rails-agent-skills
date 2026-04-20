#!/bin/bash

# Rails Agent Skills - Plugin Manifest Validator
#
# This script validates all plugin manifests for:
# - Valid JSON syntax
# - Required fields
# - Cross-platform consistency
# - SKILL.md frontmatter
#
# Usage: ./scripts/validate-plugins.sh
# Or add as pre-commit hook: ln -s ../../scripts/validate-plugins.sh .git/hooks/pre-commit

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

section "Validating Plugin Manifests"

# Validate Claude Code plugin.json
section "Claude Code (.claude-plugin/plugin.json)"

if [ ! -f ".claude-plugin/plugin.json" ]; then
  check_fail "File not found: .claude-plugin/plugin.json"
else
  if jq empty .claude-plugin/plugin.json 2>/dev/null; then
    check_pass "Valid JSON syntax"
  else
    check_fail "Invalid JSON syntax"
  fi

  # Check required fields
  for field in "name" "displayName" "version" "author" "license"; do
    if jq -e ".$field" .claude-plugin/plugin.json > /dev/null 2>&1; then
      check_pass "Field present: $field"
    else
      check_fail "Field missing: $field"
    fi
  done

  # Check author.name
  if jq -e ".author.name" .claude-plugin/plugin.json > /dev/null 2>&1; then
    check_pass "Field present: author.name"
  else
    check_fail "Field missing: author.name"
  fi

  # Get name for consistency check
  CLAUDE_NAME=$(jq -r '.name' .claude-plugin/plugin.json 2>/dev/null)
  CLAUDE_VERSION=$(jq -r '.version' .claude-plugin/plugin.json 2>/dev/null)
fi

# Validate Claude Code marketplace.json
section "Claude Code Marketplace (.claude-plugin/marketplace.json)"

if [ ! -f ".claude-plugin/marketplace.json" ]; then
  check_fail "File not found: .claude-plugin/marketplace.json"
else
  if jq empty .claude-plugin/marketplace.json 2>/dev/null; then
    check_pass "Valid JSON syntax"
  else
    check_fail "Invalid JSON syntax"
  fi

  # Check required fields
  for field in "name" "description" "owner" "plugins"; do
    if jq -e ".$field" .claude-plugin/marketplace.json > /dev/null 2>&1; then
      check_pass "Field present: $field"
    else
      check_fail "Field missing: $field"
    fi
  done

  # Check plugins array has items
  if jq -e ".plugins | length > 0" .claude-plugin/marketplace.json > /dev/null 2>&1; then
    check_pass "Plugins array is not empty"
  else
    check_fail "Plugins array is empty"
  fi

  # Check first plugin has required fields
  if jq -e ".plugins[0].name" .claude-plugin/marketplace.json > /dev/null 2>&1; then
    check_pass "First plugin has name field"
  else
    check_fail "First plugin missing name field"
  fi
fi

# Validate Cursor plugin.json
section "Cursor (.cursor-plugin/plugin.json)"

if [ ! -f ".cursor-plugin/plugin.json" ]; then
  check_fail "File not found: .cursor-plugin/plugin.json"
else
  if jq empty .cursor-plugin/plugin.json 2>/dev/null; then
    check_pass "Valid JSON syntax"
  else
    check_fail "Invalid JSON syntax"
  fi

  # Check required fields
  for field in "name" "displayName" "version"; do
    if jq -e ".$field" .cursor-plugin/plugin.json > /dev/null 2>&1; then
      check_pass "Field present: $field"
    else
      check_fail "Field missing: $field"
    fi
  done

  CURSOR_NAME=$(jq -r '.name' .cursor-plugin/plugin.json 2>/dev/null)
  CURSOR_VERSION=$(jq -r '.version' .cursor-plugin/plugin.json 2>/dev/null)
fi

# Validate Windsurf plugin.json
section "Windsurf (.windsurf-plugin/plugin.json)"

if [ ! -f ".windsurf-plugin/plugin.json" ]; then
  check_fail "File not found: .windsurf-plugin/plugin.json"
else
  if jq empty .windsurf-plugin/plugin.json 2>/dev/null; then
    check_pass "Valid JSON syntax"
  else
    check_fail "Invalid JSON syntax"
  fi

  # Check required fields
  for field in "name" "displayName" "version"; do
    if jq -e ".$field" .windsurf-plugin/plugin.json > /dev/null 2>&1; then
      check_pass "Field present: $field"
    else
      check_fail "Field missing: $field"
    fi
  done

  WINDSURF_NAME=$(jq -r '.name' .windsurf-plugin/plugin.json 2>/dev/null)
  WINDSURF_VERSION=$(jq -r '.version' .windsurf-plugin/plugin.json 2>/dev/null)
fi

# Validate Tessl tile.json
section "Tessl Tile (tile.json)"

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

  TILE_VERSION=$(jq -r '.version' tile.json 2>/dev/null)
fi

# Validate tessl.json dependency version matches tile.json version
section "Tessl Dependency Version Sync"

if [ -f "tessl.json" ] && [ -n "$TILE_VERSION" ]; then
  TESSL_DEP_VERSION=$(jq -r '.dependencies."igmarin/rails-agent-skills".version' tessl.json 2>/dev/null)
  if [ "$TESSL_DEP_VERSION" = "$TILE_VERSION" ]; then
    check_pass "tessl.json self-dependency matches tile.json: $TILE_VERSION"
  else
    check_fail "tessl.json self-dependency ($TESSL_DEP_VERSION) does not match tile.json ($TILE_VERSION)"
  fi
fi

# Check consistency across platforms
section "Cross-Platform Consistency"

if [ "$CLAUDE_NAME" = "$CURSOR_NAME" ] && [ "$CLAUDE_NAME" = "$WINDSURF_NAME" ]; then
  check_pass "Plugin names are consistent: $CLAUDE_NAME"
else
  check_fail "Plugin names are inconsistent (Claude: $CLAUDE_NAME, Cursor: $CURSOR_NAME, Windsurf: $WINDSURF_NAME)"
fi

if [ "$CLAUDE_VERSION" = "$CURSOR_VERSION" ] && [ "$CLAUDE_VERSION" = "$WINDSURF_VERSION" ]; then
  check_pass "Plugin versions are consistent: $CLAUDE_VERSION"
else
  check_fail "Plugin versions are inconsistent (Claude: $CLAUDE_VERSION, Cursor: $CURSOR_VERSION, Windsurf: $WINDSURF_VERSION)"
fi

# Validate SKILL.md files
section "Validating SKILL.md Frontmatter"

skill_count=0
skill_errors=0

while IFS= read -r skill_file; do
  skill_count=$((skill_count + 1))
  skill_name=$(basename "$(dirname "$skill_file")")

  # Check if file exists
  if [ ! -f "$skill_file" ]; then
    check_fail "$skill_name: File not found"
    skill_errors=$((skill_errors + 1))
    continue
  fi

  # Check if first line is ---
  if head -n 1 "$skill_file" | grep -q "^---$"; then
    check_pass "$skill_name: YAML frontmatter found"
  else
    check_fail "$skill_name: Missing YAML frontmatter start (---)"
    skill_errors=$((skill_errors + 1))
  fi

  # Check for required YAML fields
  if grep -q "^name:" "$skill_file"; then
    check_pass "$skill_name: Has 'name' field"
  else
    check_fail "$skill_name: Missing 'name' field in frontmatter"
    skill_errors=$((skill_errors + 1))
  fi

  if grep -q "^description:" "$skill_file"; then
    check_pass "$skill_name: Has 'description' field"
  else
    check_fail "$skill_name: Missing 'description' field in frontmatter"
    skill_errors=$((skill_errors + 1))
  fi

  # Frontmatter name must match directory name
  fm_name=$(awk '/^---$/{f++; next} f==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$skill_file")
  if [ -n "$fm_name" ] && [ "$fm_name" != "$skill_name" ]; then
    check_fail "$skill_name: frontmatter name ('$fm_name') does not match directory name"
    skill_errors=$((skill_errors + 1))
  fi
done < <(find . -maxdepth 2 -name "SKILL.md" -not -path "./.git/*" | sort)

info "Total SKILL.md files found: $skill_count"

# Cross-check: every top-level skill dir with SKILL.md must be in tile.json.skills
section "tile.json ↔ Disk Skill Inventory Sync"

if [ -f "tile.json" ]; then
  while IFS= read -r dir; do
    skill_name=$(basename "$dir")
    if jq -e ".skills.\"$skill_name\"" tile.json > /dev/null 2>&1; then
      check_pass "tile.json includes skill: $skill_name"
    else
      check_fail "tile.json missing skill present on disk: $skill_name"
    fi
  done < <(find . -maxdepth 2 -name "SKILL.md" -not -path "./.git/*" -not -path "./.claude/*" -not -path "./.cursor*/*" -not -path "./.windsurf*/*" -exec dirname {} \; | sort)

  # And every tile.json.skills entry must exist on disk
  while IFS= read -r tile_skill; do
    if [ -f "$tile_skill/SKILL.md" ]; then
      check_pass "Disk has skill listed in tile.json: $tile_skill"
    else
      check_fail "tile.json references missing skill dir: $tile_skill"
    fi
  done < <(jq -r '.skills | keys[]' tile.json 2>/dev/null | sort)
fi

# Summary
section "Summary"

echo ""
echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"

if [ "$CHECKS_FAILED" -eq 0 ]; then
  echo ""
  echo -e "${GREEN}✅ All validations passed!${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}❌ $CHECKS_FAILED validation(s) failed.${NC}"
  echo ""
  echo "Please fix the issues above and run this script again."
  exit 1
fi
