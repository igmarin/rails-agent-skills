---
name: generate-tasks
description: >
  Use when the user asks to create tasks, generate a task list, break down a PRD
  into implementation steps, plan implementation, or create an implementation checklist.
  Generates phased plans or step-by-step task lists in Markdown from a PRD or
  feature description with checkboxes, relevant files, test commands, YARD,
  documentation updates, and code-review gates after implementation.
---

# Generating a Task List from Requirements

## Goal

Create a phased plan or step-by-step task list in Markdown that guides a developer through implementing a feature. Tasks should be actionable, ordered, and tied to the requirements.

**Core principle:** Match the output to the request. Strategy requests get a phased plan; implementation requests get detailed 2-5 minute tasks.

## Quick Reference

| Step | Action | Output |
|------|--------|--------|
| 1 | Receive PRD or feature description | Raw requirements |
| 2 | Detect project/work type | Monolith, engine, API-only, integration |
| 3 | Choose output mode | Phased plan or detailed checklist |
| 4 | Generate parent phases/tasks | High-level structure |
| 5 | Wait for "Go" (default) or generate all | User confirmation |
| 6 | Generate sub-tasks with exact file paths | Detailed checklist |
| 7 | Save to `/tasks/` | `tasks-[feature-name].md` |
| 8 | Include completion phase | YARD, docs, self-review tasks |

## HARD-GATE

```text
Task 0.0 is ALWAYS "Create feature branch" unless user explicitly says otherwise.
Each sub-task MUST be a single, clear action completable in 2-5 minutes.
Sub-tasks MUST include exact file paths, not vague references.
DO NOT skip the verification step after saving.

TESTS GATE IMPLEMENTATION:
  The test is a GATE — implementation CANNOT proceed until the test:
    1. EXISTS (written and saved)
    2. Has been RUN
    3. FAILS for the correct reason (feature missing)

  Structure sub-tasks as:
    a) "Write spec for X" (with exact file path)
    b) "Run spec — verify it fails because X does not exist yet"
    c) "Implement X to pass spec" (with exact file path)
    d) "Run spec — verify it passes"

  NEVER generate a task that writes implementation before its test.
  NEVER skip the "run and verify failure" step between test and implementation.

OUTPUT MODE:
  If the user asks for strategy, sequencing, phases, or approach, produce a phased plan first.
  If the user asks for implementation tasks, checklist, or exact steps, produce the detailed mode.

POST-IMPLEMENTATION GATE (always include as explicit parent tasks after tests pass):

  Every task list that adds or changes production Ruby/Rails code MUST end with:

  1. YARD — Document every new or changed public class and public method
     (skill: yard-documentation). Sub-tasks must name each file to document.

  2. Documentation — Update README, architecture/diagrams (e.g. Mermaid, ADRs),
     and any domain docs touched by the change. List concrete paths in
     "Relevant Files" and as sub-tasks (create diagram updates if behavior
     or data flow changed).

  3. Code review — Self-review the full diff using rails-code-review (and
     rails-security-review / rails-architecture-review when scope warrants).
     Sub-tasks: run through review checklist, fix blocking issues, then open PR
     (or hand off for human review). Do not treat "implementation done" as
     complete without this step.
```

## When to Use

- User asks for tasks, task list, implementation checklist, or to "break down" a feature.
- User asks for sequencing, implementation phases, or strategy from a PRD.
- User points to an existing PRD and wants implementation steps.
- **Input:** A PRD file, a feature description, or a link to requirements. If a PRD exists, derive tasks from its **Functional Requirements** and **Goals** first.

## Process

1. **Receive requirements:** User provides a feature description, task request, or path to a PRD (e.g. `tasks/prd-[feature-name].md`).
2. **Analyze:** If a PRD is given, extract Functional Requirements and Goals. Otherwise use the feature description. Identify scope and main work areas.
3. **Detect work type:** Call out whether the work is mainly a Rails monolith change, engine change, API-only surface, background job flow, or external integration. This affects spec selection, file paths, and follow-up skills.
4. **Choose output mode:**
   - **Phased plan:** If the user is asking for strategy, sequencing, or architecture-level planning, generate phases with goals, likely files, and decision points.
   - **Detailed checklist (default for implementation):** Generate parent tasks and then sub-tasks with exact file paths.
5. **Choose flow for detailed mode:**
   - **Default (with pause):** Generate only parent tasks (~5 high-level tasks). Present them and say: "I've generated the high-level tasks. Reply **Go** to generate sub-tasks, or tell me what to change."
   - **One shot:** If the user said "todo junto", "all at once", "sin pausa", "no pause", "generate everything", or similar, generate parent tasks and sub-tasks in a single pass and save the full file. Do not wait for "Go".
6. **Parent tasks/phases:** Always include **0.0 Create feature branch** as the first task unless the user asks otherwise. After implementation parents, always add parents for **YARD**, **documentation** (README, diagrams, related docs), and **code review** (self-review + PR readiness). Typical order: setup -> tests/specs -> implementation -> YARD -> docs -> review.
7. **Sub-tasks:** For each parent, break down into small, concrete steps. One sub-task = one clear action. Order so that dependencies are respected. Include exact file paths. Documentation sub-tasks must name real paths (e.g. `docs/telematics.md`, `README.md`, `doc/architecture/*.md`) or state "add diagram under docs/..." when the repo layout is unknown.
8. **Relevant Files:** List files that will likely be created or modified (including tests, README, diagrams, and internal docs). Refine this list when generating sub-tasks. Infer test command from the project when possible (e.g. Gemfile -> `bundle exec rspec`, package.json scripts -> `npm test` or `npx jest`). For style checks, name the project linter command if the repo defines one.
9. **Save:** Save as `tasks-[feature-name].md` in `/tasks/`. Use the same `[feature-name]` as the PRD if one was provided.
10. **Verify:** Re-read the saved file and confirm the task count and structure match expectations.

## Rails-First Slice Heuristics

Use the smallest slice that proves behavior at the right boundary:

| Change type | Default first slice |
|-------------|---------------------|
| New endpoint or controller behavior | Request spec -> controller/service wiring -> persistence/docs |
| New service or domain rule | Service or model spec -> implementation -> callers/docs |
| Background work | Job spec -> service/domain spec if logic is substantial |
| External integration | Client/fetcher layer spec -> builder/domain mapping -> callers |
| Rails engine work | Engine request/routing/generator spec -> engine code -> install/docs |
| Bug fix | Highest-value reproducing spec at the boundary where users feel the bug |

When in doubt, prefer the highest-value failing spec that proves the user-visible behavior before descending into lower-level units.

## Output Format

Use one of these structures depending on the request.

### Detailed Checklist

The detailed task list must follow this structure:

```markdown
# Task List: [Feature Name]

Based on: `prd-[feature-name].md` *(only if PRD was the source)*

## Relevant Files

- `path/to/file1.ext` - Why this file is relevant.
- `path/to/file1.spec.ext` (or `.test.ext`) - Tests for file1.
- `path/to/file2.ext` - Why this file is relevant.

### Notes

- Tests live next to or mirror the code they cover.
- Run tests: `bundle exec rspec` *(replace with project's test command)*
- After green tests: add YARD on public Ruby API, update README/diagrams/docs as needed, then self code review before PR.

## Instructions for Completing Tasks

Check off each task when done: change `- [ ]` to `- [x]`. Update the file after each sub-task, not only after a full parent task.

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout branch (e.g. `git checkout -b feature/[feature-name]`)
- [ ] 1.0 [Parent task title]
  - [ ] 1.1 Write spec for [behavior] (`spec/path/to/spec.rb`)
  - [ ] 1.2 Run spec — verify it fails (feature does not exist yet)
  - [ ] 1.3 Implement [behavior] to pass spec (`app/path/to/file.rb`)
  - [ ] 1.4 Run spec — verify it passes and no other tests break
- [ ] 2.0 [Parent task title]
  - [ ] 2.1 Write spec for [behavior] (`spec/path/to/spec.rb`)
  - [ ] 2.2 Run spec — verify it fails (feature does not exist yet)
  - [ ] 2.3 Implement [behavior] to pass spec (`app/path/to/file.rb`)
  - [ ] 2.4 Run spec — verify it passes
- [ ] 3.0 YARD and public API documentation
  - [ ] 3.1 Add YARD to new/changed public classes and methods (`app/path/to/file.rb`) — English only
  - [ ] 3.2 Run `yard doc` or project doc task if applicable — fix warnings on touched files
- [ ] 4.0 Update documentation artifacts
  - [ ] 4.1 Update README or module README if behavior or setup changed (`README.md` or `docs/...`)
  - [ ] 4.2 Update diagrams or architecture docs if flows or boundaries changed (`docs/...`, ADRs)
- [ ] 5.0 Code review before merge
  - [ ] 5.1 Self-review full diff (rails-code-review checklist); fix Critical/Suggestion items
  - [ ] 5.2 Security/architecture pass if scope warrants (rails-security-review, rails-architecture-review)
  - [ ] 5.3 Open PR or request review — attach summary of doc/YARD updates
```

### Phased Plan

Use this lighter structure when the user asks for sequencing or strategy rather than a full checklist:

```markdown
# Implementation Plan: [Feature Name]

Based on: `prd-[feature-name].md` *(only if PRD was the source)*

## Work Type

- Rails monolith / engine / API-only / external integration

## Phases

### Phase 1: [Goal]
- Target behavior:
- First failing spec:
- Likely files:
- Dependencies / decisions:

### Phase 2: [Goal]
- Target behavior:
- First failing spec:
- Likely files:
- Dependencies / decisions:

## Completion

- YARD updates
- README / diagrams / docs updates
- Self-review with follow-up skills
```

## Interaction Model

- **Phased mode:** Use when the user asks for strategy, phases, or sequencing. Save the phased plan directly unless the user wants iteration first.
- **With pause:** In detailed mode, after showing parent tasks, wait for "Go" (or user corrections) before generating and saving the full list with sub-tasks.
- **Without pause:** If the user requested everything in one go, generate and save the complete detailed list immediately.

## Target Audience

Write for a **junior developer**: each sub-task should be a single, clear action they can complete and check off without ambiguity.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Vague sub-tasks ("set up the backend") | Each sub-task must name the exact file and action |
| Forcing a detailed checklist when the user asked for strategy | Use phased mode for sequencing and architectural planning |
| Tasks without file paths | Always include the file path being created or modified |
| Tasks that take 30+ minutes | Break down further — target 2-5 minutes per sub-task |
| Skipping task 0.0 (feature branch) | Always start with branch creation unless user says otherwise |
| Generating all at once by default | Default is pause after parent tasks. Only skip pause when user asks |
| No test command in relevant files | Infer from project (Gemfile, package.json, etc.) |
| Choosing low-level unit tasks first for an API or UI-facing change | Start at the boundary that proves the behavior, then move inward |
| Dependencies out of order | A task should never reference something created in a later task |

## Red Flags

- Sub-task contains "and" (likely two tasks combined)
- No test files listed in relevant files
- Implementation/test parent tasks exceed ~7 (scope too large — suggest phased task files; YARD/docs/review parents are expected)
- Strategy request answered with a giant checklist instead of phases
- Sub-task says "update as needed" or "configure appropriately" (too vague)
- Task list generated without reading the PRD first
- Implementation started before task list was reviewed
- Task list ends at "tests pass" with no YARD, docs, or code-review parents — incomplete; add completion parents
- No README/diagram/doc paths in Relevant Files when integrators or operators need updates

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | Generate PRD first, then derive tasks from it |
| **rails-tdd-slices** | When planning the best first failing spec or vertical slice for a Rails change |
| **rails-stack-conventions** | When generating tasks for a Rails feature |
| **jira-ticket-planning** | When the user also wants Jira ticket drafts or board placement from the same initiative |
| **rspec-best-practices** | When generating test-related tasks |
| **rails-bug-triage** | When the request starts from a bug report and needs reproduction plus sequencing |
| **refactor-safely** | When tasks involve refactoring existing code |
| **yard-documentation** | After implementation — sub-tasks under the YARD parent |
| **rails-code-review** | Final parent — self-review full diff before PR |
| **rails-security-review** | When tasks touch auth, params, external IO, or sensitive data |
| **rails-architecture-review** | When boundaries, domains, or structure shift |
| **rails-engine-docs** | When the change affects a Rails engine's install or public API |
