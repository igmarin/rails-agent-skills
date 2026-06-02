# Plan 4: Flatten Agents into Skills — agnostic-planning-skills

**Status:** Completed
**Scope:** igmarin/agnostic-planning-skills (Phase 1 of 4 repos)
**Next:** Copy this plan to rails-agent-skills, ruby-core-skills

## Core Decisions (from grill session)

| Decision | Outcome |
|----------|---------|
| Target directory | `skills/personas/` — not `skills/workflows/` |
| Type field | Explicit `type: atomic` and `type: persona` in frontmatter |
| Requirements-clarifier | New atomic skill at `skills/requirements-clarifier/` (not a persona) |
| Repo-agnostic | requirements-clarifier feeds into product-owner and tech-lead personas |
| OpenCode support | `.opencode/agents/` wrappers with `mode: subagent` + tool restrictions |
| Cross-LLM | Canonical source is `SKILL.md` — `.opencode/agents/` is opencode-specific |
| Persona tooling | Orchestrator personas: allow edit/write, deny bash |
| Persona tooling | Read-only personas: deny edit, write, bash (requirements-clarifier) |
| Future repos | rails-agent-skills → `skills/personas/`; hanakai-yaku → `skills/personas/` |
| New roles (future) | architect-designer → ruby-core-skills; test-automation-engineer → ruby-core-skills |

## Vocabulary

| Old Term | New Term | Definition |
|----------|----------|------------|
| Agent | Persona | A role-based workflow (orchestrates atomic skills) |
| Agent directory | `skills/personas/` | Location for persona SKILL.md files |
| Skill | Atomic Skill | Single capability with `type: atomic` |
| Orchestrator | Orchestrating Persona | A persona that chains atomic skills |
| agents.json | (deleted) | Merged into directory.json |
| AGENTS.md | (deleted) | Content merged into CLAUDE.md / GEMINI.md |
| tile.json | directory.json | Old tessl registry → new `directory.json` format |

---

## PHASE 1 — Add `type: atomic` to existing skills

Add `type: atomic` to the YAML frontmatter of every existing atomic skill. Root SKILL.md gets `type: catalog`.

- [x] All atomic skill SKILL.md files
- [x] Root `SKILL.md` — `type: catalog`

---

## PHASE 2 — Move agents to skills/personas/

- [x] Move all `agents/<name>/SKILL.md` → `skills/personas/<name>/SKILL.md`
- [x] Add `type: persona` to frontmatter
- [x] Rename title from "Agent" → "Persona"

---

## PHASE 3 — Create skills/requirements-clarifier/ (if applicable)

- [x] New atomic skill for transforming vague requests into specs (agnostic-planning-skills only)

---

## PHASE 4 — Create `.opencode/agents/` wrappers

Create `mode: subagent` wrappers for opencode users. One per persona, with:

- `prompt: "{file:./skills/personas/<name>/SKILL.md}"` referencing canonical source
- `permission` block: orchestrator personas get `edit/write: allow, bash: deny`; read-only personas (requirements-clarifier) get `edit/write/bash: deny`

- [x] One `.md` file per persona in `.opencode/agents/`

---

## PHASE 5 — Delete obsolete files

- [x] Delete `agents/` directory
- [x] Delete `agents.json` (entries merged into `directory.json`)
- [x] Delete `AGENTS.md` (content merged into CLAUDE.md / GEMINI.md)

---

## PHASE 6 — Update directory.json

- [x] Add all personas under `"skills"` key
- [x] Add new atomic skills (e.g. requirements-clarifier)
- [x] Bump major version

---

## PHASE 7 — Update root SKILL.md

- [x] Update description counts (skills + personas)
- [x] Rename "Agents" section to "Personas"
- [x] Add any new skills to Quick Reference
- [x] Remove `agents.json` references

---

## PHASE 8 — Update documentation

- [x] `README.md` — counts, tables, terminology
- [x] `CLAUDE.md` / `GEMINI.md` — agent → persona, add new skills
- [x] `docs/architecture.md` — directory tree, skill types
- [x] `docs/agent-guide.md` → `docs/persona-guide.md` — rename + content update
- [x] `docs/calling-skills.md` — agents → personas
- [x] `docs/reference/skill-catalog.md` — agents → personas, add new skills
- [x] `docs/index.md` — counts, terminology
- [x] `CONTRIBUTING.md` — remove tile.json references, update paths
- [x] `CHANGELOG.md` — major version entry

---

## PHASE 9 — Tessl plugin migration

- [x] Update `.tessl-plugin/plugin.json` to use `"skills": "./skills/"` (auto-discovery)
- [x] Rename `tessl-evals/` → `evals/` (required for plugin eval mode)
- [x] Run `tessl project repair` to confirm project link
- [x] Update `tile.json` references in docs to `directory.json`

---

## PHASE 10 — CI workflow fixes (all repos)

The `anomalyco/opencode/github@latest` action was failing with "Failed to parse JSON" errors.

- [x] Pin from `@latest` → `@github-v1.2.24` (avoid pulling broken builds mid-CI)
- [x] Add `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` env to both workflows
- [x] Add `use_github_token: true` to both workflows
- [x] Fix PR review workflow: `pull-requests: read` → `pull-requests: write` (needed to post comments)

Applied to: agnostic-planning-skills, ruby-core-skills, rails-agent-skills, hanakai-yaku

---

## PHASE 11 — Description optimization (eval-driven)

Run Tessl evals, identify skills with <80% baseline score, and fix their `description` first sentence.

### Rules applied:

1. **Lead with non-negotiable rules** not high-level summaries
2. **Pack critical constraints before the first `.`** — use commas, em dashes, parentheses
3. **Persona strategy**: hard gates first, not what the persona does
4. **Eliminate `...` followed by space** (triggers regex split)

### Results (agnostic-planning-skills, sonnet-4-6):

| Skill | Before | After | Delta | Fix |
|-------|--------|-------|-------|-----|
| Identify Risks | 76% | 94% | **+18** | Led with "do NOT fabricate, every risk MUST reference evidence, verify ratings" |
| Generate Status Report | 90% | 92% | +2 | Tightened never-fabricate constraint |
| Review Prd | 97% | 99% | +2 | N/A (already high) |
| Delivery Lead* | 19% | N/A | — | Packed 3 hard gates + phase ordering |
| Product Owner* | 62% | N/A | — | Packed 4 hard gates into first sentence |
| Project Manager* | 37% | N/A | — | Packed 3 hard gates + constraints |
| Tech Lead* | 84% | N/A | — | Added evidence citation + severity classification |
| **Baseline avg** | **81%** | **93%** | **+12** | With context avg: 100% |

*\*Persona skills use Tessl auto-generated evals — no local `evals/` scenarios*

### Known issue:

`claude:glm-5.1` produces false 0% baseline scores. Always use `claude:claude-sonnet-4-6` for evals:

```bash
tessl eval run . --agent "claude:claude-sonnet-4-6"
```

### Ceiling:

Some rules resist first-sentence compression — e.g., Plan Tickets instruction-4 ("do not re-plan if a plan already exists") is a nuanced conditional. Accept 70-75% for these.

---

## PHASE 12 — Post-merge fixes (PR review findings)

- [x] `CONTRIBUTING.md` — `tile.json` → `directory.json` on line 15
- [x] `integration-matrix.md` — "Complete Agent Loops" → "Complete Persona Loops"
- [x] `integration-matrix.md` — Quick Decision Matrix code block unclosed + missing labels + missing Checkpoints & Gates + See Also
- [x] `skill-catalog.md` — "All 11 skills" → "All 10 skills" for delivery-lead
- [x] `.opencode/agents/delivery-lead.md` — add clarifying permission comment

---

## Reusable Checklist for Other Repos

Copy this plan and run through these steps for each target repo:

### Structural migration

- [ ] Add `type: atomic` to all existing atomic skills
- [ ] Move agents/ → skills/personas/ with `type: persona`
- [ ] Delete `agents/`, `agents.json`, `AGENTS.md`
- [ ] Update `directory.json` to include personas
- [ ] Update root SKILL.md, README, CLAUDE.md, GEMINI.md
- [ ] Create `.opencode/agents/` wrappers (if opencode users exist)

### Tessl plugin
- [ ] Ensure `.tessl-plugin/plugin.json` uses `"skills": "./skills/"`
- [ ] Rename `tessl-evals/` → `evals/` if exists
- [ ] Run `tessl project repair` to verify link

### CI workflows
- [ ] Pin `anomalyco/opencode/github@latest` → `@github-v1.2.24`
- [ ] Add `GITHUB_TOKEN` env + `use_github_token: true`
- [ ] Fix `pull-requests: read` → `pull-requests: write` in PR review workflow

### Description optimization
- [ ] Run `tessl eval run . --agent "claude:claude-sonnet-4-6"`
- [ ] Check baseline scores — fix any <80%
- [ ] Apply persona hard-gate strategy for any persona skills
- [ ] Run evals again to validate
- [ ] Update `docs/skill-description-strategy.md` with results

---

---

## PHASE 13 — Apply to hanakai-yaku (Phase 2 of 4)

| Item | Result |
|------|--------|
| **Repo** | `igmarin/hanakai-yaku` |
| **Skills** | 35 atomic + 10 personas |
| **CI workflows** | 2 files pinned, `GITHUB_TOKEN` + `use_github_token` added, `pull-requests` → `write` |
| **Tessl plugin** | Switched to `"skills": "./skills/"` auto-discovery — no breaking changes |
| **Eval baseline** | 91% avg across all 35 atomic skills (no personas tested — no local evals) |
| **Low scorers fixed** | `write-request-spec` (67%→improved), `extract-slice` (79%→improved) — first-sentence packing |

### Findings unique to hanakai-yaku

1. **Auto-discovery worked seamlessly.** Switching `.tessl-plugin/plugin.json` from explicit array to `"skills": "./skills/"` picked up all 35 skills + 10 personas without issues. Personas at `skills/personas/` are discovered automatically.

2. **review-security is an outlier.** Lives at `skills/review-security/SKILL.md` (no category subdirectory). All other skills nest under `skills/actions/`, `skills/db/`, etc. Left in place since auto-discovery handles it, but recommend normalizing to `skills/cross-cutting/review-security/`.

3. **Eval scenario generation for descriptions is slow.** Running `tessl scenario generate .` on 35 skills took >5 minutes. For single-skill description fixes, delete `evals/<skill>/` dir and run targeted evals instead.

4. **No `.claude-plugin/agents/` equivalent exists.** Claude Code doesn't have a subagent wrapper format. The `CLAUDE.md` file handles Claude discovery — no wrappers needed.

5. **`.opencode/agents/` wrappers are simple.** Each is a Markdown file with YAML frontmatter (`mode: subagent`, `prompt`, `permission`). Orchestrator personas get `edit/write: allow, bash: deny` by design — the subagent plans/generates code, user executes commands.

6. **Tags needed updating.** Agent files had `tags: [agents]` in metadata. Moved to `tags: [personas]` in the persona SKILL.md copies.

7. **Sync ALL plugin versions together.** After bumping `directory.json`, also bump `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `.tessl-plugin/plugin.json` to the same version. These were at `1.0.0` while `directory.json` was at `0.4.0` — easy to miss.

8. **CONTRIBUTING.md needs more than path updates.** Beyond `tile.json → directory.json`, also add `type:` field requirements, a persona-adding section, and update validation steps (no `bin/validate_skills` script exists in most repos).

9. **CODE_REVIEW.md and skill-quality-guide.md may have stale `agents/` paths.** Historical review docs reference `agents/tdd-loop/SKILL.md` paths that no longer exist. Update to `skills/personas/tdd-loop/SKILL.md`.

10. **Pre-existing file truncation may surface.** The `tdd-loop/SKILL.md` had a truncated table row (end of "Common Mistakes" section) that was pre-existing but only surfaced during PR review. Sweep all persona SKILL.md files for incomplete tables or cut-off sections before merge.

### Checklist additions for remaining repos

In addition to the reusable checklist above, for **rails-agent-skills** and **ruby-core-skills**:

- [ ] Check for outlier skills outside category subdirectories (e.g., `skills/<name>/` without category)
- [ ] Update `tags: [agents]` → `tags: [personas]` in moved persona files
- [ ] Verify `.opencode/agents/` wrappers have correct `permission` block (orchestrators: edit/write allow, bash deny)
- [ ] After switching to auto-discovery, run `tessl eval run . --agent "claude:claude-sonnet-4-6"` to validate no skills are missed
- [ ] Sync versions across ALL plugin configs: `.claude-plugin/`, `.cursor-plugin/`, `.tessl-plugin/`, `directory.json`
- [ ] Sweep `CODE_REVIEW.md` and `skill-quality-guide.md` for stale `agents/` paths
- [ ] Sweep all moved persona SKILL.md files for pre-existing truncation (incomplete tables, cut-off sections)
- [ ] After fixing descriptions, delete cached `evals/<skill>/task.md` and regenerate scenarios for those skills

### Summary of Operations (hanakai-yaku)

| Action | Files |
|--------|-------|
| Add `type:` atomic | 35 SKILL.md files |
| Add `type:` catalog | 1 root SKILL.md |
| Move agents → personas | 10 files (agents → skills/personas/) |
| Add `type:` persona | 10 files |
| Create `.opencode/agents/` wrappers | 10 files |
| Delete obsolete | 1 dir (`agents/`) + 2 files (`agents.json`, `AGENTS.md`) + 1 dir (`tessl-evals/`) |
| Update `directory.json` | 1 file (added 10 personas, bumped to 0.4.0) |
| Update `.tessl-plugin/plugin.json` | 1 file (auto-discovery, bumped to 0.4.0) |
| Update documentation | ~12 files (SKILL.md, CLAUDE.md, GEMINI.md, README.md, docs/*) |
| Fix CI workflows | 2 files (pinned `@latest`, added `GITHUB_TOKEN`, fixed permissions) |
| Fix description evals | 2 skills (write-request-spec, extract-slice) |
| Fix PR review findings | 16 files (headings, stale refs, versions, docs cleanup) |
| Fix tdd-loop truncation | 1 file (completed truncated table row) |
| **Total** | **~90 file operations** |

---

## Summary of Operations (agnostic-planning-skills)

| Action | Files |
|--------|-------|
| Add `type:` field | 11 SKILL.md files |
| Move agents → personas | 4 files |
| Create new atomic skill | 1 file (requirements-clarifier) |
| Create .opencode/agents wrappers | 5 files |
| Delete obsolete | 1 dir + 2 files |
| Update directory.json | 1 file |
| Update documentation | ~10 files |
| Fix CI workflows | 2 files (×4 repos) |
| Fix PR review findings | 4 files |
| Optimize descriptions | 7 skills (4 personas + 3 atomic) |
| **Total** | **~50 file operations** |

---

## Kudos

| Repo | Phase | Contributor |
|------|-------|-------------|
| **agnostic-planning-skills** (Phase 1) | All 12 phases | @igmarin |
| **hanakai-yaku** (Phase 2) | PHASE 1–13 | @igmarin |
| `docs/persona-guide.md` | Created for hanakai-yaku, usable by all repos | @igmarin |

The `docs/persona-guide.md` document was created during the hanakai-yaku migration and is available for reuse by rails-agent-skills and ruby-core-skills. It provides a shared reference for persona structure, invocation, and phases that all persona-based repos can adopt.
