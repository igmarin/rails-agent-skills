# Task List: Integrate agent-skills patterns and new rails-context-engineering skill

Based on: (no PRD — direct planning request from maintainer, 2026-04-18)

## Relevant Files

### Existing skills to reinforce

- `create-prd/SKILL.md` — absorb acceptance-criteria + "plan-mode" discipline from `planning-and-task-breakdown` into Output Style; no structural rewrite.
- `create-prd/PRD_TEMPLATE.md` — confirm sections match criteria (no change expected).
- `generate-tasks/SKILL.md` — reinforce TDD quadruplet language, Task 0.0 feature branch, Relevant Files, YARD/doc/review gates in the frontmatter trigger words.
- `generate-tasks/TASK_TEMPLATES.md` — confirm template (no change expected).
- `generate-tasks/HEURISTICS.md` — confirm change-type → first-slice mapping (no change expected).
- `rspec-best-practices/SKILL.md` — absorb increment cycle (implement → test → verify → commit → next slice) and 100-line rule from `incremental-implementation` into Core Process / Output Style; reinforce `# frozen_string_literal: true` at line 1 as MUST.
- `rails-tdd-slices/SKILL.md` — absorb vertical-slice framing and risk-first slicing from `incremental-implementation` without diluting the Rails-first boundary table.

### New skill

- `rails-context-engineering/SKILL.md` — new SKILL file, Rails-first adaptation of `context-engineering`. Rails-specific signals: `db/schema.rb`, `config/routes.rb`, neighboring models/factories/specs, `Gemfile.lock`, engine boundaries.
- `rails-context-engineering/references/context-sources.md` — progressive-disclosure reference with exact Grep/Read commands for Rails context gathering.
- `rails-context-engineering/references/confusion-management.md` — progressive-disclosure reference with patterns for surfacing ambiguity (spec vs code drift, missing requirements).

### Manifests and discovery

- `tile.json` — add `rails-context-engineering` to the `skills` map; bump version.
- `tessl.json` — bump `igmarin/rails-agent-skills` version to force republish if needed.
- `rails-skills-orchestrator/SKILL.md` — add `rails-context-engineering` to the routing tables and workflow chains.

### Project documentation

- `README.md` — add row to Skills Catalog + update Mermaid flowchart + TDD Feature Loop mention.
- `docs/workflow-guide.md` — insert `rails-context-engineering` step between `rails-tdd-slices` and `rspec-best-practices` in the primary TDD Feature Loop and its Mermaid.
- `docs/architecture.md` — add to Skill Types listing if it maps to an existing category.
- `docs/skill-design-principles.md` — no change expected.
- `CLAUDE.md` — add row to the Available Skills table (Testing section feels right since it precedes rspec-best-practices; or a new "Context & Setup" row).
- `AGENTS.md` — same update as CLAUDE.md.
- `GEMINI.md` — same update.

### Evals (read-only — DO NOT modify)

- `evals/worst-cases/` — reference only, to aim reinforcements at the actual weak points.
- `evals/*/criteria.json` — reference only, to confirm Output Style requirements align with weighted checklists.

### Notes

- Tests live per skill: run `tessl lint` and `tessl skill review --optimize --yes <skill-folder>` after every skill edit.
- `tessl eval run ./` cannot be executed locally — only post-push via remote Tessl. Validation loop locally is: lint + skill review + manual diff against criteria.json.
- After green locals: commit grouped (reinforcements → new skill → manifests → docs) and push. User triggers remote eval.

## Instructions for Completing Tasks

Check off each task when done: change `- [ ]` to `- [x]`. Update this file after each sub-task, not only after a full parent task. Use `tessl skill review --optimize --yes <folder>` as the local equivalent of the "run spec" step for each skill.

## Tasks

- [x] 0.0 Create feature branch
  - [x] 0.1 Created and checked out branch: `feat/agent-skills-integration-and-context-engineering`

- [x] 1.0 ~~Reinforce `create-prd`~~ — **SKIPPED: already 100% on `tessl skill review`; MUSTs already explicit in existing Output Style / HARD-GATE / Pitfalls. Test-edit caused score drop 100% → 89%. Reverted.**

- [x] 2.0 ~~Reinforce `generate-tasks`~~ — **SKIPPED: already 100%. Frontmatter and Output Style already enforce Task 0.0 branch, 4-sub-task TDD quadruplets with explicit run-fail / run-pass, YARD parent, doc parent, code-review gate, Relevant Files. Worst-case failures are runtime-adherence gaps, not skill-text gaps.**

- [x] 3.0 ~~Reinforce `rspec-best-practices`~~ — **SKIPPED: already 100%. Skill already enforces `# frozen_string_literal: true` on line 1 and `travel_to` for time-dependent behavior (with example block). Worst-case `subscription_spec.rb` violations are runtime-adherence gaps.**

- [x] 4.0 ~~Reinforce `rails-tdd-slices`~~ — **SKIPPED: already 100%. Existing Quick Reference table + HARD-GATE cover "highest-value boundary" (vertical slicing rephrased in Rails-first language). Adding new vocabulary risks duplication without eval lift.**

- [ ] 5.0 Create `rails-context-engineering` skill (Rails-first adaptation of context-engineering)
  - [ ] 5.1a Draft local "spec" — list what the skill MUST produce: one-line pre-task context summary, concrete Rails files inspected (schema, routes, neighboring code), pattern example, gotchas surfaced, confusion-management block when ambiguity exists
  - [ ] 5.1b Run `tessl lint` (nothing should exist yet — confirms skill absence) and confirm this is genuinely a new skill
  - [ ] 5.1c Write `rails-context-engineering/SKILL.md` with frontmatter, Quick Reference, HARD-GATE ("no code/spec until context is loaded and summarized"), Core Process, Extended Resources, Output Style, Integration. Write `references/context-sources.md` and `references/confusion-management.md` with progressive-disclosure instructions
  - [ ] 5.1d Run `tessl lint` and `tessl skill review --optimize --yes rails-context-engineering` — target 100% on skill review; iterate until achieved

- [ ] 6.0 Wire new skill into manifests
  - [ ] 6.1 Add `rails-context-engineering` entry to `tile.json` skills map (alphabetical position)
  - [ ] 6.2 Bump `tile.json` version (e.g. 2.4.15 → 2.5.0 since this is a new skill)
  - [ ] 6.3 Bump `tessl.json` dependency version to the new tile version
  - [ ] 6.4 Run `tessl lint` on repo root — fix any warnings

- [ ] 7.0 Update workflows and discovery documents
  - [ ] 7.1 Update `rails-skills-orchestrator/SKILL.md` — add row under Testing (or new Context section) + insert into TDD Feature Loop
  - [ ] 7.2 Update `README.md` — add row to Skills Catalog + update Mermaid `flowchart TD` + TDD Feature Loop description
  - [ ] 7.3 Update `docs/workflow-guide.md` — insert node in primary TDD Feature Loop Mermaid + step-by-step list
  - [ ] 7.4 Update `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` — add skill rows consistent with each file's style
  - [ ] 7.5 Run `tessl skill review --optimize --yes rails-skills-orchestrator` — re-verify after orchestrator edits

- [ ] 8.0 YARD and public API documentation
  - [ ] 8.1 N/A — no Ruby source changed. (Skill docs are not YARD; leave this sub-task checked with note).

- [ ] 9.0 Documentation artifact validation
  - [ ] 9.1 Verify all Mermaid diagrams render (no syntax errors) — inspect README.md and docs/workflow-guide.md changes visually
  - [ ] 9.2 Grep for stale references to skills and confirm all cross-links still valid

- [ ] 10.0 Local validation gate
  - [ ] 10.1 Run `tessl lint` on repo root — zero warnings
  - [ ] 10.2 Run `tessl skill review --optimize --yes` on EVERY changed skill folder — all ≥ current baseline, new skill at 100%
  - [ ] 10.3 Confirm `evals/` is untouched: `git status evals/` shows no modifications (only untracked `evals/worst-cases/` which was pre-existing)

- [ ] 11.0 Commit grouped changes (no push yet)
  - [ ] 11.1 Commit A: reinforcements — "feat(skills): reinforce create-prd, generate-tasks, rspec-best-practices, rails-tdd-slices with agent-skills patterns"
  - [ ] 11.2 Commit B: new skill — "feat(skills): add rails-context-engineering"
  - [ ] 11.3 Commit C: manifests + docs — "chore: wire rails-context-engineering + update workflows and README/CLAUDE/AGENTS/GEMINI"

- [ ] 12.0 Code review before merge
  - [ ] 12.1 Self-review full diff following `rails-code-review` checklist applied to skill authoring (progressive disclosure respected, Output Style explicit, frontmatter CSO-optimized, no dead links)
  - [ ] 12.2 User pushes branch and triggers remote Tessl eval
  - [ ] 12.3 Run `tessl eval view --last` (post-push) — record scores per scenario for affected skills
  - [ ] 12.4 If any scenario below 100%, iterate using `docs/skill-optimization-guide.md` workflow and push again
