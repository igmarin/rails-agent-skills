---
name: create-prd
description: >
  Generates a clear, actionable Product Requirements Document (PRD) in Markdown
  from a feature description. Use when a user asks to plan a feature, define
  requirements, or create a PRD. Covers goals, user stories, requirements,
  and non-goals for Rails-oriented workflows.
---

# Generating a Product Requirements Document (PRD)

## Goal

Create a clear, actionable PRD in Markdown that a junior developer can use to understand and implement a feature. Focus on *what* and *why*, not *how*.

**Core principle:** Design before implementation. No code until the PRD is approved.

## Quick Reference

| Step | Action | Output |
|------|--------|--------|
| 1 | Receive feature description | Raw input |
| 2 | Ask clarifying questions (only if ambiguous) | Shared understanding |
| 3 | Identify likely implementation surface (when useful) | Rails-aware scope |
| 4 | Generate PRD | `prd-[feature-name].md` |
| 5 | Save to `/tasks/` | File on disk |
| 6 | Suggest next step | Link to **generate-tasks** / optional **ticket-planning** |

## HARD-GATE

```text
DO NOT implement the PRD. Only produce the document.
DO NOT skip clarifying questions when the prompt is ambiguous.
DO NOT start generating tasks without user confirmation.
```

## When to Use

- User asks for a PRD, requirements doc, or to "plan a feature".
- User describes a feature and you need to capture it in a structured way before implementation.
- **Next step:** After saving the PRD, suggest `generate-tasks` for implementation planning and `ticket-planning` only when the user also wants tickets or sprint placement.

## Process

1. **Receive prompt:** User provides a feature description or request.
2. **Socratic questioning phase:**
   - If the prompt is **already detailed** (clear goal, scope, and success criteria), skip clarifying questions and generate the PRD directly.
   - If anything is **ambiguous**, ask only the most essential questions (3-5 max). Understand "what" and "why", not "how". Use letter/number options for quick answers.
   - Ask one question at a time when possible — do not overwhelm with a wall of questions.
3. **Identify implementation surface (optional):** If the feature is for a Rails app or engine, note the likely areas it will touch without prescribing the solution: `controllers`, `models`, `services`, `jobs`, `serializers`, `policies`, `mailers`, `engines`, `docs`, or external integrations.
4. **Generate PRD:** Use the structure below. Derive `[feature-name]` from the feature (lowercase, hyphenated slug, e.g. `user-onboarding`, `export-csv`).
5. **Save:** Save as `prd-[feature-name].md` in the `/tasks` directory (create the directory if needed).
6. **Verify:** Re-read the saved file and confirm it matches the agreed scope.
7. **Do NOT** start implementing the PRD. Offer to generate tasks if the user wants an implementation checklist. When suggesting **generate-tasks**, note that the resulting checklist will include tests-first sequencing, YARD, README/diagram/doc updates, and a code-review-before-PR phase unless the user opts out.

## Clarifying Questions (Only When Needed)

Ask only when the answer is not reasonably inferable. Typical areas:

- **Problem/Goal:** What problem does this solve for the user?
- **Actor:** Who performs the action or experiences the outcome?
- **Core actions:** What are the key actions the user should perform?
- **Business rules:** What validations, policies, or domain rules must hold?
- **Side effects:** Should this trigger emails, jobs, external API calls, audits, or notifications?
- **Dependencies:** Does it depend on another system, migration, feature flag, or background job?
- **Scope:** What should this feature *not* do?
- **Success:** How do we know it's done or successful?

### Question Format

Use numbered questions with A/B/C/D options when possible:

```text
1. What is the primary goal of this feature?
   A. Improve onboarding
   B. Increase retention
   C. Reduce support load
   D. Other (describe)

2. Who is the target user?
   A. New users only
   B. Existing users only
   C. All users
```

## PRD Structure

Generate the document with these sections. Use concrete wording; avoid vague phrases.

1. **Introduction/Overview** — One short paragraph: what the feature is and what problem it solves.
2. **Goals** — Specific, measurable objectives (bullet list).
3. **User Stories** — "As a [role], I want [action] so that [benefit]." One per key flow.
4. **Functional Requirements** — Numbered list of must-have behaviors. Clear and testable.
5. **Non-Goals (Out of Scope)** — Explicitly what this feature will *not* include.
6. **Design Considerations (Optional)** — UI/UX notes, mockup links, or component references.
7. **Technical Considerations (Optional)** — Constraints, dependencies, or tech suggestions.
8. **Implementation Surface (Optional)** — Likely Rails areas involved (`controllers`, `services`, `jobs`, `engines`, `docs`, etc.) without prescribing code structure.
9. **Success Metrics** — How success will be measured (even if qualitative).
10. **Open Questions** — Anything still unclear or to be decided later.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `prd-[feature-name].md`

## Target Audience

Write for a **junior developer**: explicit, unambiguous, minimal jargon. Each requirement should be implementable without guessing.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Jumping straight to PRD without understanding the problem | Ask clarifying questions first — garbage in, garbage out |
| PRD describes "how" instead of "what" | PRD is requirements, not implementation. Leave "how" for tasks |
| Vague requirements ("make it fast", "good UX") | Every requirement must be testable and unambiguous |
| Asking 10+ clarifying questions | Max 3-5 essential questions. Infer the rest |
| Ignoring side effects or external dependencies | Capture jobs, mailers, APIs, audits, and flags early so tasks are scoped correctly |
| Starting implementation after writing PRD | HARD-GATE: only produce the document. Suggest generate-tasks next |
| Skipping Non-Goals section | Non-Goals prevent scope creep. Always include them |

## Red Flags

- PRD contains implementation details (specific code, database schema)
- Requirements use words like "should", "might", "could" instead of "must"
- No success metrics defined
- Rails feature has no mention of side effects, boundaries, or likely system area touched
- User stories are too generic ("As a user, I want a good experience")
- PRD was generated without any clarifying questions on an ambiguous prompt
- Implementation started before PRD was approved

## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-tasks** | After PRD is approved — implementation + tests + YARD + docs + review tasks |
| **ticket-planning** | When the plan also needs Jira-ready tickets, classification, or sprint placement |
| **rails-architecture-review** | When PRD reveals architectural concerns |
| **rails-engine-author** | When the PRD is clearly for a mountable engine or host-app integration |
| **rails-stack-conventions** | When PRD is for a Rails feature |
