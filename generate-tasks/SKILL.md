---
name: generate-tasks
description: >
  Use when breaking down a feature or generating an implementation task list from a PRD.
  Output MUST follow this exact structure: (1) Task 0.0: Create feature branch with git
  checkout command, (2) Relevant Files section listing all files with concrete paths,
  (3) At least 3 TDD task groups with four sub-tasks each: X.Xa Write spec, X.Xb Run spec
  and verify it FAILS, X.Xc Implement, X.Xd Run spec and verify it PASSES, (4) YARD
  documentation task, (5) Documentation update task for README/diagrams, (6) Code review
  gate, (7) Save as tasks-[name].md in /tasks/ folder. Trigger words: task list,
  implementation plan, feature breakdown, todo list, project tasks, work plan, break
  down this PRD, generate tasks, feature branch, TDD, write spec, run spec fail, run
  spec pass.
license: MIT
---

# Generating a Task List from Requirements

## Output Requirements (MUST Follow)

```text
Task 0.0 is ALWAYS "Create feature branch" unless user explicitly says otherwise.
Each sub-task MUST be a single, clear action completable in 2-5 minutes.
Sub-tasks MUST include exact file paths, not vague references.

OUTPUT MODE:
  If the user asks for strategy, sequencing, phases, or approach, produce a phased plan first.
  If the user asks for implementation tasks, checklist, or exact steps, produce the detailed mode.
```

Every generated task list MUST contain the following elements:

1. **Task 0.0** — "Create feature branch" with checkout command (e.g., `git checkout -b feature/name`)
2. **Relevant Files section** — All files to create/modify with concrete paths, listed before Tasks
3. **TDD quadruplets** — At least 3 implementation groups with four sub-tasks each:
   - `X.Xa` Write spec at `spec/...`
   - `X.Xb` Run spec — verify it **fails**
   - `X.Xc` Implement at `app/...`
   - `X.Xd` Run spec — verify it **passes**
4. **YARD parent task** — Add YARD docs to new/changed public API; name each file (skill: yard-documentation)
5. **Documentation update task** — Update README, diagrams (Mermaid, ADRs), domain docs; list concrete paths
6. **Code review gate** — Self-review via rails-code-review; fix blockers before opening PR
7. **Save location** — `tasks-[feature-name].md` in `/tasks/` folder

See [TASK_TEMPLATES.md](./TASK_TEMPLATES.md) for full templates.

## Extended Resources (Load When Needed)

Load these files only when their specific guidance is required:

- **[HEURISTICS.md](./HEURISTICS.md)** — Use when deciding the first spec to write for a given change type (endpoint, service, job, engine, bug fix)
- **[TASK_TEMPLATES.md](./TASK_TEMPLATES.md)** — Use when you need the full template structure for phased plans or detailed checklists

## Process

1. **Analyze:** Extract Functional Requirements and Goals from the PRD, or use the feature description. Identify scope and main work areas.
2. **Detect work type:** Rails monolith, engine, API-only, background job, or external integration — affects spec paths and follow-up skills.
3. **Relevant Files:** List files to create or modify including tests, docs, and diagrams. Infer test command (`bundle exec rspec` or `npm test`).
4. **Save:** Save as `tasks-[feature-name].md` in `/tasks/`. Use the same `[feature-name]` as the PRD if one was provided.
5. **Verify:** Re-read the saved file and confirm all of the following:
   - Task `0.0` creates the feature branch
   - `Relevant Files` section is present
   - At least 3 implementation task groups use the full TDD sequence: write spec -> run fail -> implement -> run pass
   - YARD, documentation, and code-review parent tasks appear after implementation work

## Rails-First Slice Heuristics

See [HEURISTICS.md](./HEURISTICS.md) for the full change-type → first-slice mapping table.

## Pitfalls

| Problem | Correct approach |
|---------|------------------|
| Dependencies out of order | A task must never reference something created in a later task |
| No README/diagram/doc paths when integrators need updates | List concrete doc paths in Relevant Files |

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | Generate PRD first, then derive tasks from it |
| **rails-tdd-slices** | When planning the best first failing spec for a Rails change |
| **ticket-planning** | When the same initiative also needs ticket drafts |
| **rails-bug-triage** | When the request starts from a bug report |
