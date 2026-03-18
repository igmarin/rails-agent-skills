---
name: jira-ticket-planning
description: >
  Drafts, classifies, and optionally creates Jira tickets from an initiative plan.
  Use when the user provides a plan and wants Jira-ready tickets, wants help shaping
  a plan into tickets, wants sprint-placement guidance, or wants tickets created in
  Jira after the plan is approved.
---

# Jira Ticket Planning

Use this skill for initiative-to-ticket workflows:

- the user already has a plan and wants ticket drafts
- the user wants help turning an emerging plan into tickets
- the user wants sprint-placement guidance for those tickets
- the assistant should create the approved tickets in Jira (when the user has Jira access/tools configured)

This skill covers **planning and execution flow**, not Jira product documentation.

## Overview

Normalize inputs, classify each work item, apply title conventions, draft tickets in a standard structure, reduce redundancy, then either return markdown drafts or create issues in Jira after explicit approval.

## Workflow

### 1. Normalize the initiative

Extract planning inputs:

- initiative/theme
- project/board
- whether the request is **draft-only** or **create-in-Jira**
- default sprint or backlog bucket
- constraints on issue types, prefixes, epic, labels, components, status, or sprint

If the user already has a plan, **do not re-plan** unless there is a material gap.

### 2. Classify each ticket before drafting it

Assign these planning attributes to each ticket:

| Attribute | Values |
|-----------|--------|
| `area` | `backend` \| `web` \| `mobile` \| `cross-platform` \| `external` |
| `type` | `Story` \| `Task` |
| `dependency_level` | `unblocked` \| `blocked` |
| `execution_order` | `foundation` \| `api` \| `client` \| `follow-up` |
| `coordination_need` | `single-team` \| `multi-team` |
| `external_dependency` | `yes` \| `no` |
| `urgency` | `normal` \| `priority` |
| `target_bucket` | `ready-to-refine` \| `next-dev-sprint` \| `later` |

Use the classification to decide sequence and sprint placement. Backend/API enablers usually come before dependent web/mobile tickets.

### 3. Apply Jira title conventions

Use these prefixes:

- `BE | ` for backend / mob-api
- `FE | ` for web / frontend
- `Mobile | ` for mobile

Do **not** add those prefixes to tickets that are not owned by those areas unless the user explicitly wants that.

### 4. Draft tickets in the standard structure

Use this section order:

1. **Summary**
2. **Background**
3. **Acceptance Criteria**
4. **Dependencies**
5. **Technical Notes**

Write primarily for planning and execution clarity. Keep the main sections business-facing; use **Technical Notes** only for implementation details that help sequencing or scoping.

### 5. Reduce redundancy

Do not repeat the same business intent in every section.

Prefer:

- **Summary** — core outcome
- **Background** — why it exists
- **Acceptance Criteria** — observable completion
- **Dependencies** — sequencing
- **Technical Notes** — fields, systems, identifiers, integration constraints, implementation boundaries

### 6. Decide whether to stop at drafts or create in Jira

**Drafts only:**

- return markdown tickets
- keep titles, issue types, and dependencies explicit

**Create in Jira:**

- verify the target Jira project/board details first
- confirm required fields: project, issue type, sprint, status behavior, epic, labels, components
- create issues **only after** the plan is considered approved enough
- use whatever Jira integration the user has (API, MCP, UI); do not assume credentials in the repo

## Sprint Placement Heuristics

Defaults unless the user overrides:

- `foundation` or `api` tickets go **before** client tickets
- `client` tickets depend on stable API behavior when applicable
- `external` confirmation tickets usually stay **out** of active build sprints
- `follow-up` tickets can stay in `ready-to-refine` or later until enabling work is clear

For boards with a named future sprint such as **Ready to Refine**, treat it as a **planning bucket**, not an execution guarantee.

## Jira Creation Guidance

When creating tickets in Jira:

- create them in the Jira project that backs the board
- do not assume status can be set on create; many workflows use the project's default initial status
- if sprint assignment is required, inspect create metadata and use the sprint field shape expected by that project
- validate **one** issue first if sprint field or workflow behavior is uncertain

## Output Patterns

### Draft-only output

Provide ticket markdown plus brief sequencing notes when helpful.

### Creation output

After creation, report:

- created issue keys
- confirmed status
- confirmed sprint/bucket
- any assumptions used

## Use This Skill When

Typical prompts:

- "Turn this plan into Jira tickets"
- "Help me plan the tickets for this initiative"
- "Draft backend, web, and mobile tickets from this plan"
- "Which sprint should these tickets go into?"
- "Create these tickets in Jira once the plan looks right"

## Integration

| Skill | When to chain |
|-------|----------------|
| **generate-tasks** | After tasks exist or in parallel — same initiative can feed ticket breakdown |
| **create-prd** | When tickets should align with PRD scope and acceptance themes |
