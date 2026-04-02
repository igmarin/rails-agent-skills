# Plugin Manifest Validation

Rails Agent Skills uses automated validation to ensure plugin manifests are consistent, valid, and compatible across all platforms (Claude Code, Cursor, Windsurf, Codex).

## What Gets Validated

### JSON Syntax
- All `plugin.json` files must be valid JSON
- All `marketplace.json` files must be valid JSON
- Files must be properly formatted and not contain trailing commas

### Required Fields

**All `plugin.json` files** must have:
- `name` — Plugin identifier (should be `rails-agent-skills`)
- `displayName` — Human-readable name
- `version` — Semantic version (e.g., `1.0.0`)
- `author.name` — Author name
- `license` — License (e.g., `MIT`)

**Marketplace.json** must have:
- `name` — Marketplace identifier
- `description` — Marketplace description
- `owner` — Owner information
- `plugins` — Non-empty array of plugin entries
- Each plugin must have `name`, `description`, `version`, `source`

### Cross-Platform Consistency

These fields must match across all platform configs:
- ✅ **name** — Same across Claude, Cursor, Windsurf
- ✅ **version** — Same across all platforms
- ✅ **author** — Same across all platforms
- ✅ **license** — Same across all platforms

When you update one platform's version, **update all platforms** to match.

### SKILL.md Frontmatter

Every `SKILL.md` file must start with YAML frontmatter:

```yaml
---
name: skill-name
description: One-line description
type: workflow | skill
---
```

Required fields in frontmatter:
- `name` — Skill identifier (kebab-case)
- `description` — Short one-line description
- `type` — Either `workflow` or `skill`

## Local Validation

### Run Before Commit

Use the local validation script to catch issues before pushing:

```bash
./scripts/validate-plugins.sh
```

### What It Checks

- ✓ Valid JSON syntax in all manifests
- ✓ Required fields present
- ✓ Cross-platform consistency (names, versions match)
- ✓ SKILL.md frontmatter structure
- ✓ Plugin names consistency across platforms

### Sample Output

```
✓ Valid JSON syntax
✓ Field present: name
✓ Field present: displayName
✓ Field present: version
✓ Field present: author
✓ Field present: license
✓ Field present: author.name
✓ Plugin names are consistent: rails-agent-skills
✓ Plugin versions are consistent: 1.0.0
✓ SKILL.md files: 50 validated
✅ All validations passed!
```

### Setup as Pre-Commit Hook

To run validation automatically before each commit:

```bash
# Create symlink to git hooks
ln -s ../../scripts/validate-plugins.sh .git/hooks/pre-commit

# Make hooks executable
chmod +x .git/hooks/pre-commit
```

Now `git commit` will run validation. If any checks fail, commit is rejected:

```bash
$ git commit -m "Update plugin version"
✗ Plugin versions are inconsistent (Claude: 1.1.0, Cursor: 1.0.0, Windsurf: 1.0.0)
❌ 1 validation(s) failed.
```

Fix the issues and try again:

```bash
# Update Cursor and Windsurf versions to match
jq '.version = "1.1.0"' .cursor-plugin/plugin.json > .cursor-plugin/plugin.json.tmp && mv .cursor-plugin/plugin.json.tmp .cursor-plugin/plugin.json
jq '.version = "1.1.0"' .windsurf-plugin/plugin.json > .windsurf-plugin/plugin.json.tmp && mv .windsurf-plugin/plugin.json.tmp .windsurf-plugin/plugin.json

# Retry commit
git commit -m "Update plugin version"
```

## CI/CD Validation

### GitHub Actions

The `.github/workflows/validate-plugins.yml` workflow runs automatically on:
- Pushes to `main` branch (if plugin files changed)
- Pull requests (if plugin files changed)

### What CI Checks

**Job: `validate-schemas`**
- JSON syntax validation
- Required field presence
- Cross-platform consistency
- SKILL.md frontmatter validation

**Job: `lint-json`**
- JSON formatting (using Prettier)
- Trailing commas
- Indentation consistency

### Check Status in PR

Before merging, GitHub shows validation status:

```
✓ Validate Plugin Schemas   — All required checks passed
✓ Lint JSON Files          — JSON properly formatted
```

If checks fail, details are shown in the workflow logs. Click **Details** to see what failed.

### Local Simulation of CI

Run the exact same checks CI would run:

```bash
# Validate schemas
jq '.' .claude-plugin/plugin.json > /dev/null
jq '.' .claude-plugin/marketplace.json > /dev/null
jq '.' .cursor-plugin/plugin.json > /dev/null
jq '.' .windsurf-plugin/plugin.json > /dev/null

# Check formatting with prettier (if installed)
npm install -g prettier
prettier --check .claude-plugin/plugin.json
prettier --check .cursor-plugin/plugin.json
prettier --check .windsurf-plugin/plugin.json

# Or use our script
./scripts/validate-plugins.sh
```

## Common Validation Failures

### Error: Plugin versions are inconsistent

**Cause**: Version number differs across platform configs.

**Fix**: Update all `plugin.json` files to the same version:

```bash
# Update all platform versions at once
NEW_VERSION="1.1.0"

jq ".version = \"$NEW_VERSION\"" .claude-plugin/plugin.json > .claude-plugin/plugin.json.tmp && mv .claude-plugin/plugin.json.tmp .claude-plugin/plugin.json

jq ".version = \"$NEW_VERSION\"" .cursor-plugin/plugin.json > .cursor-plugin/plugin.json.tmp && mv .cursor-plugin/plugin.json.tmp .cursor-plugin/plugin.json

jq ".version = \"$NEW_VERSION\"" .windsurf-plugin/plugin.json > .windsurf-plugin/plugin.json.tmp && mv .windsurf-plugin/plugin.json.tmp .windsurf-plugin/plugin.json
```

### Error: Invalid JSON syntax

**Cause**: Malformed JSON (trailing comma, unclosed brace, etc.)

**Fix**: Use `jq` to validate and pretty-print:

```bash
# Check which file has bad JSON
jq '.' .claude-plugin/plugin.json

# Fix by reformatting
jq '.' .claude-plugin/plugin.json > .claude-plugin/plugin.json.tmp && mv .claude-plugin/plugin.json.tmp .claude-plugin/plugin.json
```

### Error: Field missing (e.g., "displayName")

**Cause**: Required field is not present in the manifest.

**Fix**: Add the missing field:

```bash
# Example: add displayName if missing
jq '.displayName = "Rails Agent Skills"' .claude-plugin/plugin.json > .claude-plugin/plugin.json.tmp && mv .claude-plugin/plugin.json.tmp .claude-plugin/plugin.json
```

### Error: SKILL.md missing frontmatter

**Cause**: A skill file doesn't start with `---` or is missing required YAML fields.

**Fix**: Add frontmatter to the skill file:

```markdown
---
name: my-skill
description: Brief description of what this skill does
type: skill
---

# Skill Name

[Rest of content...]
```

### Error: Plugin names are inconsistent

**Cause**: `name` field differs across platform configs.

**Fix**: Ensure all configs use the same name:

```bash
# Verify all names match
echo "Claude: $(jq -r '.name' .claude-plugin/plugin.json)"
echo "Cursor: $(jq -r '.name' .cursor-plugin/plugin.json)"
echo "Windsurf: $(jq -r '.name' .windsurf-plugin/plugin.json)"

# If they don't match, update them
jq '.name = "rails-agent-skills"' .cursor-plugin/plugin.json > .cursor-plugin/plugin.json.tmp && mv .cursor-plugin/plugin.json.tmp .cursor-plugin/plugin.json
```

## Troubleshooting Validation

### jq not found

Install jq:

```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (Red Hat/CentOS)
sudo yum install jq
```

### Script permission denied

Make the validation script executable:

```bash
chmod +x ./scripts/validate-plugins.sh
```

### prettier not found (CI only)

The CI workflow installs prettier automatically. To test locally:

```bash
npm install -g prettier
```

### Pre-commit hook not firing

Verify the symlink is correct:

```bash
# Check if hook exists and is executable
ls -la .git/hooks/pre-commit

# Recreate if needed
rm .git/hooks/pre-commit
ln -s ../../scripts/validate-plugins.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Best Practices

### When Updating Plugin Version

1. Update the version in **all three** `plugin.json` files:
   ```bash
   .claude-plugin/plugin.json
   .cursor-plugin/plugin.json
   .windsurf-plugin/plugin.json
   ```

2. Run local validation:
   ```bash
   ./scripts/validate-plugins.sh
   ```

3. Commit with a clear message:
   ```bash
   git commit -m "Bump plugin version to 1.1.0"
   ```

### When Adding a New Skill

1. Create the skill directory and `SKILL.md`:
   ```bash
   mkdir my-new-skill
   echo "---
   name: my-new-skill
   description: What this skill does
   type: skill
   ---" > my-new-skill/SKILL.md
   ```

2. Run validation to ensure frontmatter is correct:
   ```bash
   ./scripts/validate-plugins.sh
   ```

3. Commit:
   ```bash
   git commit -am "Add my-new-skill"
   ```

### When Pushing to Main

1. Run full validation:
   ```bash
   ./scripts/validate-plugins.sh
   ```

2. Verify CI passes in GitHub Actions
3. Merge PR

## Validation Automation

The validation pipeline ensures:
- ✅ All manifests are syntactically correct
- ✅ All required fields are present
- ✅ All platforms have consistent names and versions
- ✅ All skills have proper frontmatter
- ✅ Changes are properly formatted before merge

This prevents configuration drift and ensures Rails Agent Skills works correctly across Claude Code, Cursor, Windsurf, and Codex.
