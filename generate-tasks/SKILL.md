---
name: generate-tasks
description: >
  Use when the user asks to break down a feature, create an implementation plan,
  or generate a task list from a PRD or feature description. Produces phased plans
  or step-by-step Markdown checklists with checkboxes, file paths, test commands,
  YARD documentation, and code-review gates for Rails-oriented workflows. Trigger
  words: task list, implementation plan, feature breakdown, todo list, project tasks,
  work plan, break down this PRD, generate tasks.
---

# Generating a Task List from Requirements

## HARD-GATE

```text
Task 0.0 is ALWAYS "Create feature branch" unless user explicitly says otherwise.
Each sub-task MUST be a single, clear action completable in 2-5 minutes.
Sub-tasks MUST include exact file paths, not vague references.

TESTS GATE IMPLEMENTATION — structure sub-tasks as:
  a) "Write spec for X" (with exact file path)
  b) "Run spec — verify it fails because X does not exist yet"
  c) "Implement X to pass spec" (with exact file path)
  d) "Run spec — verify it passes"

OUTPUT MODE:
  If the user asks for strategy, sequencing, phases, or approach, produce a phased plan first.
  If the user asks for implementation tasks, checklist, or exact steps, produce the detailed mode.

POST-IMPLEMENTATION GATE (add as explicit parent tasks after tests pass):

  Every task list touching production code MUST end with:
  1. YARD — name each file to document (skill: yard-documentation)
  2. Documentation — update README, diagrams (Mermaid, ADRs), domain docs; list concrete paths
  3. Code review — self-review via rails-code-review; fix blockers before opening PR
```

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

## Output Format

See [TASK_TEMPLATES.md](./TASK_TEMPLATES.md) for full templates. A typical task block looks like:

```markdown
- [ ] 1.0 Parent task title
  - [ ] 1.1a Write spec for `ServiceName` at `spec/services/module/service_name_spec.rb`
  - [ ] 1.1b Run spec — verify it fails: `bundle exec rspec spec/services/module/service_name_spec.rb`
  - [ ] 1.1c Implement `ServiceName` at `app/services/module/service_name.rb`
  - [ ] 1.1d Run spec — verify it passes
```

## Pitfalls

| Problem | Correct approach |
|---------|-----------------|
| Dependencies out of order | A task must never reference something created in a later task |
| No README/diagram/doc paths when integrators need updates | List concrete doc paths in Relevant Files |

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | Generate PRD first, then derive tasks from it |
| **rails-tdd-slices** | When planning the best first failing spec for a Rails change |
| **ticket-planning** | When the same initiative also needs Jira ticket drafts |
| **rails-bug-triage** | When the request starts from a bug report |
