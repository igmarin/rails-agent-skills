# Changelog

## [Unreleased]

### Fixed
- `npx skills add` install docs now require `--full-depth` so nested skills are discovered (root `SKILL.md` is a catalog)

### Removed
- Core-owned evals (`skill-ddd-rails-modeling`, `skill-rails-bug-triage`, `skill-ruby-service-objects`) — now in `ruby-core-skills`.
- Tessl plugin packaging and registry integration (`.tessl-plugin/`, `tessl.json`, `.tesslignore`)
- Tessl CI workflows (`tessl-publish.yml`, `tessl-review.yml`)
- Tessl-native `evals/` scenarios and generator/validator scripts
- Tessl-only docs (`docs/skill-optimization-guide.md`, `docs/skill-description-strategy.md`, root `skill-description-strategy.md`)
- Tessl badge and documentation references from README and skill authoring docs

### Changed
- Skill catalog validation now uses `scripts/validate-skills.sh` against `directory.json` (replaces `validate-plugins.sh`)
- `personal-evals/` metadata no longer includes Tessl export fields
- Eval provenance policy documents only `personal-evals/` / `ruby-skill-bench`


## [7.0.0] - 2026-06-01

### Breaking Changes

**Flatten Agents into Personas with Type Taxonomy**

All 9 callable agents have been migrated from `agents/` to `skills/personas/` with `type: persona` frontmatter. This is a structural reorganization — skill names and invocation patterns remain the same.

### Added
- `type: atomic` frontmatter to all 28 atomic skills
- `type: catalog` to root SKILL.md
- `type: persona` to all 9 persona skills
- `tags: [personas]` to all persona skills
- `.opencode/agents/` wrappers for all 9 personas (OpenCode subagent support)

### Changed
- **Structural:**
  - Moved `agents/<name>/SKILL.md` → `skills/personas/<name>/SKILL.md`
  - Renamed "Agent" → "Persona" in all persona SKILL.md titles
  - Switched `.tessl-plugin/plugin.json` to `"skills": "./skills/"` auto-discovery
  - Merged `tessl-evals/` → `evals/` directory (plugin-mode compatible)

- **Configuration:**
  - Updated `directory.json` to v7.0.0 with 9 personas under `"skills"`
  - Updated `.tessl-plugin/plugin.json` to v7.0.0
  - Pinned CI workflows from `@latest` → `@github-v1.2.24`
  - Added `GITHUB_TOKEN` env + `use_github_token: true` to both workflows (GitHub capitalization in env var name)
  - Fixed `opencode-review.yml` permissions: `pull-requests: read` → `write`

- **Documentation:**
  - Renamed `docs/agent-guide.md` → `docs/persona-guide.md`
  - Renamed `docs/agent-template.md` → `docs/persona-template.md`
  - Renamed `docs/agents/` → `docs/personas/`
  - Updated all references: `agents/` → `skills/personas/`, `tile.json` → `directory.json`, `tessl-evals/` → `evals/`
  - Updated ~20 doc files with current directory tree and terminology
  - Added `type:` field documentation to `docs/architecture.md`

### Removed
- `agents/` directory (moved to `skills/personas/`)
- `agents.json` (merged into `directory.json`)
- `AGENTS.md` (content merged into CLAUDE.md/GEMINI.md)
- Empty `skills/ddd/`, `skills/orchestration/`, `skills/patterns/` directories

### Security Hardening (Post-Release)

**System Modification Approval Gate in `setup` persona**
- Added explicit "System Modification Approval Gate (CRITICAL)" to `skills/personas/setup/SKILL.md` Error Recovery section
- All system-level commands (`apt-get install`, `rbenv install`, `createuser`) now require explicit user confirmation before suggestion
- Changed from imperative tone ("Install system dependencies") to conditional ("If needed, ask user to run...")
- This hardens against W013 warnings from platform security scanners that flag system service modification attempts in skill instructions

**Third-Party Content Defenses (Already Present)**
The following personas already contain hardened input integrity gates for indirect prompt injection (W011) — no changes required:
- `skills/personas/review/SKILL.md` — "HARD-GATE: Security & Input Integrity" (lines 25-56): treats PR descriptions/comments as untrusted, diff as sole authority, never executes embedded instructions
- `skills/personas/bug-fix/SKILL.md` — "HARD-GATE: Input Integrity (Third-Party Content Defense)" (lines 25-35): treats bug reports as untrusted, verifies claims against actual code, ignores embedded directives
- `skills/infrastructure/version-api/SKILL.md` — Code-generation skill (not runtime request processor); scanner false positive

## [6.0.20] - 2026-05-30

### Added
- Integrated `load-context` skill with `get_project_context` tool of `agent-mcp-runtime` to automatically query `rails-ai-bridge` when available.
- GitHub Actions workflow (`.github/workflows/tile-check.yml`) to perform local `tile.json` integrity validation.

### Changed
- Optimized frontmatter descriptions of 23 local skills (`apply-code-conventions`, `apply-stack-conventions`, `code-review`, `create-engine`, `create-engine-installer`, `extract-engine`, `generate-api-collection`, `implement-authorization`, `implement-background-job`, `implement-graphql`, `implement-hotwire`, `load-context`, `optimize-performance`, `plan-tests`, `refactor-code`, `review-architecture`, `review-engine`, `security-check`, `seed-database`, `test-engine`, `upgrade-engine`, `version-api`, and `write-tests`) according to the `skill-description-strategy` to pack critical rules/constraints into the first sentence.
- Prevented premature regex splitting by avoiding periods (`. `) in the first sentence and properly quoting special characters (like `"let!"`) in frontmatter descriptions.
- Regenerated and staged all Tessl eval scenarios to the `evals/` directory.
- Raised average baseline Tessl evaluation scores from 56% to 92%.

## [6.0.0] - 2026-05-24

### Breaking Changes

**Skill Extraction to ruby-core-skills**
The following 10 skills have been extracted to the new `igmarin/ruby-core-skills` dependency and are no longer included in this repository:

**DDD Skills (3):**
- `define-domain-language` — Moved to ruby-core-skills
- `review-domain-boundaries` — Moved to ruby-core-skills
- `model-domain` — Moved to ruby-core-skills

**Ruby Pattern Skills (4):**
- `create-service-object` — Moved to ruby-core-skills
- `integrate-api-client` — Moved to ruby-core-skills
- `implement-calculator-pattern` — Moved to ruby-core-skills
- `write-yard-docs` — Moved to ruby-core-skills

**Code Quality Skills (2):**
- `triage-bug` — Moved to ruby-core-skills
- `respond-to-review` — Moved to ruby-core-skills

**Orchestration Skills (1):**
- `skill-router` — Moved to ruby-core-skills

**Migration Required:**
- Install `igmarin/ruby-core-skills` alongside this repository
- Update any references to the extracted skills
- The extracted skills are now auto-detected and available from the core dependency

### Added

**Core Dependency:**
- Added `depends_on: ["igmarin/ruby-core-skills"]` to tile.json
- Added 15 core skills from ruby-core-skills (DDD, Ruby patterns, process skills, code quality, orchestration)
- Added `deprecated_skills` section to tile.json documenting the 10 moved skills

**Documentation:**
- Added "Core Skills (from ruby-core-skills)" section to CLAUDE.md
- Added "Core Dependencies" section to root SKILL.md
- Updated skill count references from 38 to 28 local skills
- Updated workflow chains in CLAUDE.md with `*(from core)*` annotations

### Changed

**Repository Structure:**
- Removed 10 extracted skill directories (ddd/, patterns/, orchestration/ subdirectories)
- Removed empty category directories (ddd/, patterns/, orchestration/)
- Updated tile.json from v5.0.0 to v6.0.0
- Updated skill catalog from 38 to 28 local skills

**Agent Dependencies:**
- Updated all 9 agent SKILL.md files with `metadata.dependencies` frontmatter
- Agents now declare dependencies on both local and core skills
- Dependencies include source: self and source: ruby-core-skills sections

**Documentation Updates:**
- Updated AGENTS.md skill count from 38 to 28
- Updated CLAUDE.md to remove references to extracted skills
- Updated CLAUDE.md workflow chains with core skill annotations
- Updated root SKILL.md skill count and added core dependencies section
- Updated docs/reference/skill-catalog.md to remove references to deleted skills

### Deprecated

The following skills are deprecated in this repository and available from `igmarin/ruby-core-skills`:
- `define-domain-language`
- `review-domain-boundaries`
- `model-domain`
- `create-service-object`
- `integrate-api-client`
- `implement-calculator-pattern`
- `write-yard-docs`
- `triage-bug`
- `respond-to-review`
- `skill-router`

### Migration Guide

**For Users:**
1. Install the new dependency: `gh skill install igmarin/ruby-core-skills`
2. The extracted skills will be auto-detected and available automatically
3. No code changes required — skill names remain the same
4. Update any documentation that references the old skill count (38 → 28 local + 15 core)

**For Contributors:**
1. When adding new DDD or Ruby pattern skills, add them to `ruby-core-skills` instead
2. When adding Rails-specific skills, add them to this repository
3. Process skills should go to `ruby-core-skills` if framework-agnostic
4. Update agent dependencies in SKILL.md frontmatter when adding new skills

## [5.0.0] - Previous Release

Previous releases documented in git history.
