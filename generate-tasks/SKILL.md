---
name: generate-tasks
description: >
  Use when the user asks to create tasks, generate a task list, break down a PRD
  into implementation steps, plan implementation, or create an implementation checklist.
  Generates step-by-step task lists in Markdown from a PRD or feature description
  with checkboxes, relevant files, and test commands.
---

# Generating a Task List from Requirements

## Goal

Create a step-by-step task list in Markdown that guides a developer through implementing a feature. Tasks should be actionable, ordered, and tied to the requirements.

**Core principle:** Each task should take 2-5 minutes. If a task takes longer, break it down further.

## Quick Reference

| Step | Action | Output |
|------|--------|--------|
| 1 | Receive PRD or feature description | Raw requirements |
| 2 | Analyze scope and work areas | Understanding |
| 3 | Generate parent tasks (~5) | High-level structure |
| 4 | Wait for "Go" (default) or generate all | User confirmation |
| 5 | Generate sub-tasks with exact file paths | Detailed checklist |
| 6 | Save to `/tasks/` | `tasks-[feature-name].md` |

## HARD-GATE

```
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
```

## When to Use

- User asks for tasks, task list, implementation checklist, or to "break down" a feature.
- User points to an existing PRD and wants implementation steps.
- **Input:** A PRD file, a feature description, or a link to requirements. If a PRD exists, derive tasks from its **Functional Requirements** and **Goals** first.

## Process

1. **Receive requirements:** User provides a feature description, task request, or path to a PRD (e.g. `tasks/prd-[feature-name].md`).
2. **Analyze:** If a PRD is given, extract Functional Requirements and Goals. Otherwise use the feature description. Identify scope and main work areas.
3. **Choose flow:**
   - **Default (with pause):** Generate only parent tasks (~5 high-level tasks). Present them and say: "I've generated the high-level tasks. Reply **Go** to generate sub-tasks, or tell me what to change."
   - **One shot:** If the user said "todo junto", "all at once", "sin pausa", "no pause", "generate everything", or similar, generate parent tasks and sub-tasks in a single pass and save the full file. Do not wait for "Go".
4. **Parent tasks:** Always include **0.0 Create feature branch** as the first task unless the user asks otherwise. Aim for ~5 parent tasks (e.g. setup, backend, frontend, tests, docs/deploy).
5. **Sub-tasks:** For each parent, break down into small, concrete steps. One sub-task = one clear action. Order so that dependencies are respected. Include exact file paths.
6. **Relevant Files:** List files that will likely be created or modified (including tests). Refine this list when generating sub-tasks. Infer test command from the project when possible (e.g. Gemfile -> `bundle exec rspec`, package.json scripts -> `npm test` or `npx jest`).
7. **Save:** Save as `tasks-[feature-name].md` in `/tasks/`. Use the same `[feature-name]` as the PRD if one was provided.
8. **Verify:** Re-read the saved file and confirm the task count and structure match expectations.

## Output Format

The task list must follow this structure:

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
```

## Interaction Model

- **With pause:** After showing parent tasks, wait for "Go" (or user corrections) before generating and saving the full list with sub-tasks.
- **Without pause:** If the user requested everything in one go, generate and save the complete task list immediately.

## Target Audience

Write for a **junior developer**: each sub-task should be a single, clear action they can complete and check off without ambiguity.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Vague sub-tasks ("set up the backend") | Each sub-task must name the exact file and action |
| Tasks without file paths | Always include the file path being created or modified |
| Tasks that take 30+ minutes | Break down further — target 2-5 minutes per sub-task |
| Skipping task 0.0 (feature branch) | Always start with branch creation unless user says otherwise |
| Generating all at once by default | Default is pause after parent tasks. Only skip pause when user asks |
| No test command in relevant files | Infer from project (Gemfile, package.json, etc.) |
| Dependencies out of order | A task should never reference something created in a later task |

## Red Flags

- Sub-task contains "and" (likely two tasks combined)
- No test files listed in relevant files
- Parent tasks exceed 7 (scope too large — suggest splitting into phases)
- Sub-task says "update as needed" or "configure appropriately" (too vague)
- Task list generated without reading the PRD first
- Implementation started before task list was reviewed

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | Generate PRD first, then derive tasks from it |
| **rails-stack-conventions** | When generating tasks for a Rails feature |
| **rspec-best-practices** | When generating test-related tasks |
| **refactor-safely** | When tasks involve refactoring existing code |
