# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
