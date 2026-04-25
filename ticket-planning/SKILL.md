---
name: ticket-planning
description: >
  Drafts, classifies, and optionally creates tickets from an initiative plan.
  Use when the user provides a plan and wants ticket drafts, wants help shaping
  a plan into tickets, wants sprint-placement guidance, or wants tickets created in
  an issue tracker after the plan is approved.
license: MIT
---

# Ticket Planning

Normalize inputs, classify each work item, apply title conventions, draft tickets in a standard structure, then either return markdown drafts or create issues in the issue tracker after explicit approval.

See [EXAMPLES.md](./EXAMPLES.md) for a complete plan → ticket draft example.

## Workflow

### 1. Normalize the initiative

Extract planning inputs:

- initiative/theme
- project/board
- whether the request is **draft-only** or **create-in-tracker**
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

Backend/API enablers generally come before dependent web/mobile tickets.

### 3. Apply title conventions

Use these prefixes:

- `BE |` for backend
- `FE |` for web / frontend
- `Mobile |` for mobile

When writing the ticket title, leave a space after the `|`.

Do **not** add those prefixes to tickets that are not owned by those areas unless the user explicitly wants that.

### 4. Draft tickets in the standard structure

Use this section order:

| Section | Job |
|---------|-----|
| **Summary** | State the outcome |
| **Background** | Explain why |
| **Acceptance Criteria** | List observable criteria |
| **Dependencies** | Note blockers |
| **Technical Notes** | Implementation details that affect sequencing or scoping only |

Keep the main sections business-facing. Do not restate the background in the summary or repeat the AC in Technical Notes.

### 5. Decide: drafts or create in the issue tracker

**Drafts only:**

- return markdown tickets
- keep titles, issue types, and dependencies explicit

**Create in issue tracker:**

- verify the target project/board details first
- confirm required fields: project, issue type, sprint, status behavior, epic, labels, components
- create issues **only after** the plan is considered approved enough
- use whatever integration the user has (API, MCP, UI); do not assume credentials in the repo

## Sprint Placement Heuristics

Defaults unless the user overrides:

- `foundation` or `api` tickets go **before** client tickets
- `client` tickets depend on stable API behavior when applicable
- `external` confirmation tickets usually stay **out** of active build sprints
- `follow-up` tickets stay in `ready-to-refine` or later until enabling work is clear

For boards with a named future sprint such as **Ready to Refine**, treat it as a **planning bucket**, not an execution guarantee.

## Ticket Creation Guidance

When creating tickets in an issue tracker:

- create them in the project that backs the board
- do not assume status can be set on create; many workflows use the project's default initial status
- if sprint assignment is required, inspect create metadata and use the sprint field shape expected by that project
- validate **one** issue first if sprint field or workflow behavior is uncertain

## Output Patterns

### Draft-only output

Provide ticket markdown plus brief sequencing notes when helpful. Minimum inline shape:

```
BE | Add Google OAuth2 callback endpoint

**Summary:** Implement the Rails OAuth2 callback action that exchanges the
authorization code for a user token and creates or finds a User by email.

**Background:** Users need Google login. Callback completes the flow after Google redirects.

**Acceptance Criteria:**
- POST /auth/google/callback exchanges code for token
- Creates or finds User by email; returns session on success, error JSON on failure

**Dependencies:** None. Unblocked.

**Technical Notes:** Uses omniauth-google-oauth2. Callback path must match Google Cloud Console.
```

See [EXAMPLES.md](./EXAMPLES.md) for a full plan → ticket draft with classification applied.

### Creation output

After creation, report:

- created issue keys
- confirmed status
- confirmed sprint/bucket
- any assumptions used

## Integration

| Skill | When to chain |
|-------|----------------|
| **generate-tasks** | After tasks exist or in parallel — same initiative can feed ticket breakdown |
| **create-prd** | When tickets should align with PRD scope and acceptance themes |

## Assets

- [assets/ticket-samples/sample_issue.md](assets/ticket-samples/sample_issue.md)
