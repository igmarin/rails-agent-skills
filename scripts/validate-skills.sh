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

# Prefer /usr/bin/python3 (system) to avoid version-manager shims (mise,
# asdf, pyenv) that may hang on startup. Fall back to python3 on PATH.
if [ -x /usr/bin/python3 ]; then
  PYTHON=/usr/bin/python3
elif command -v python3 &> /dev/null; then
  PYTHON=python3
else
  echo -e "${RED}Error: python3 is required but not installed.${NC}"
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

# Cache the find result once — previously this was run twice (here and in the
# disk-sync section below). Stored in a newline-delimited string and replayed
# via a process substitution. Portable across bash 3.2 (macOS) and bash 4+.
DISK_SKILL_FILES_CACHE="$(find skills -name "SKILL.md" | sort)"

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
done < <(printf '%s\n' "$DISK_SKILL_FILES_CACHE")

info "Total SKILL.md files found: $skill_count"

section "directory.json ↔ Disk Sync"

# directory.json maps skill name -> { "path": "skills/.../SKILL.md" }
DIRECTORY_PATHS=$(jq -r '.skills | to_entries[] | .value.path' "$DIRECTORY_FILE" 2>/dev/null | sed 's/^\.\///' | sort)
# Reuse the cached find result instead of walking the tree a second time.
DISK_SKILL_PATHS=$(printf '%s\n' "$DISK_SKILL_FILES_CACHE" | sed 's/^\.\///' | sort)

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

PERSONA_PATHS=$(find skills -name SKILL.md | while IFS= read -r f; do
  grep -q '^type: persona' "$f" && echo "$f"
done | sort)
if [ -n "$PERSONA_PATHS" ]; then
  info "Persona SKILL.md files:"
  persona_count=0
  persona_type_matches=0
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    info "  $path"
    persona_count=$((persona_count + 1))
    if grep -q "^type: persona" "$path" 2>/dev/null; then
      persona_type_matches=$((persona_type_matches + 1))
    fi
  done <<< "$PERSONA_PATHS"
  if [ "$persona_type_matches" -eq "$persona_count" ]; then
    check_pass "All persona SKILL.md files have type: persona"
  else
    check_fail "Some persona SKILL.md files missing type: persona ($persona_type_matches/$persona_count)"
  fi
fi

section "Description size and structure"

# Canonical skills only (skills/**/SKILL.md). Catalog lives at skills/rails-agent-skills/.
DESC_LIMIT=1024
DESC_TARGET=600
BODY_LINE_WARN=500

while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  skill_name=$(basename "$(dirname "$skill_file")")

  if ! grep -q "^description:" "$skill_file"; then
    check_fail "$skill_name: Missing 'description' field"
    continue
  fi
  check_pass "$skill_name: Has 'description' field"

  desc_len=$("$PYTHON" - "$skill_file" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
m = re.search(r"^description:\s*>\s*\n((?:[ \t]+.+\n)+)", text, re.M)
if m:
    desc = " ".join(line.strip() for line in m.group(1).splitlines() if line.strip())
    print(len(desc))
else:
    m = re.search(r"^description:\s+(.+)$", text, re.M)
    print(len(m.group(1).strip()) if m else -1)
PY
)
  if [ "$desc_len" -lt 0 ]; then
    check_fail "$skill_name: could not parse description"
  elif [ "$desc_len" -gt "$DESC_LIMIT" ]; then
    check_fail "$skill_name: description is ${desc_len} chars (max ${DESC_LIMIT})"
  elif [ "$desc_len" -gt "$DESC_TARGET" ]; then
    check_fail "$skill_name: description is ${desc_len} chars (target ≤${DESC_TARGET})"
  else
    check_pass "$skill_name: description ${desc_len} chars (≤${DESC_TARGET})"
  fi

  body_lines=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$body_lines" -gt "$BODY_LINE_WARN" ]; then
    check_fail "$skill_name: SKILL.md is ${body_lines} lines (warn at ${BODY_LINE_WARN})"
  else
    check_pass "$skill_name: SKILL.md ${body_lines} lines"
  fi

  for heading in "Quick Reference" "HARD-GATE" "Core Process" "Output Style" "Integration"; do
    if grep -Eq "^## ${heading}s?\$" "$skill_file"; then
      check_pass "$skill_name: has ## ${heading}"
    else
      info "$skill_name: missing ## ${heading} (warning)"
    fi
  done
done < <(printf '%s\n' "$DISK_SKILL_FILES_CACHE")

section "skills.sh.json ↔ directory.json Sync"

SKILLS_SH_FILE="skills.sh.json"
if [ ! -f "$SKILLS_SH_FILE" ]; then
  check_fail "File not found: $SKILLS_SH_FILE"
else
  if jq empty "$SKILLS_SH_FILE" 2>/dev/null; then
    check_pass "$SKILLS_SH_FILE: valid JSON syntax"
  else
    check_fail "$SKILLS_SH_FILE: invalid JSON syntax"
  fi

  # Every skill referenced in skills.sh.json groupings must exist in directory.json.skills.
  DIRECTORY_SKILL_KEYS=$(jq -r '.skills | keys[]' "$DIRECTORY_FILE" 2>/dev/null | sort)
  SH_REFERENCED_SKILLS=$(jq -r '[.groupings[].skills[]] | unique[]' "$SKILLS_SH_FILE" 2>/dev/null | sort)

  if [ -z "$SH_REFERENCED_SKILLS" ]; then
    check_fail "$SKILLS_SH_FILE: no skills found in groupings"
  else
    while IFS= read -r skill_name; do
      [ -z "$skill_name" ] && continue
      if printf '%s\n' "$DIRECTORY_SKILL_KEYS" | grep -Fxq "$skill_name"; then
        check_pass "$SKILLS_SH_FILE skill in directory.json: $skill_name"
      else
        check_fail "$SKILLS_SH_FILE skill missing from directory.json: $skill_name"
      fi
    done <<< "$SH_REFERENCED_SKILLS"
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
