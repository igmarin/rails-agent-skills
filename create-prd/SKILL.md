---
name: create-prd
description: >
  Generates a clear, actionable Product Requirements Document (PRD) in Markdown
  from a feature description. Use when a user asks to plan a feature, define
  requirements, or create a PRD. Covers goals, user stories, requirements,
  and non-goals for Rails-oriented workflows.
---

# Generating a Product Requirements Document (PRD)

Focus on *what* and *why*, not *how*. No code until the PRD is approved.

## Quick Reference

| Step | Action | Output |
|------|--------|--------|
| 1 | Receive feature description | Raw input |
| 2 | Ask clarifying questions (only if ambiguous) | Shared understanding |
| 3 | Identify likely implementation surface (when useful) | Rails-aware scope |
| 4 | Generate PRD | `prd-[feature-name].md` |
| 5 | Save to `/tasks/` | File on disk |
| 6 | Suggest next step | Link to **generate-tasks** / optional **ticket-planning** |

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

## PRD Structure

Write for a **junior developer**: explicit, unambiguous, minimal jargon. Generate with these sections:

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

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| PRD describes "how" instead of "what" | PRD is requirements, not implementation — leave "how" for tasks |
| Vague requirements ("make it fast", "good UX") | Every requirement must use "must" and be testable |
| Skipping Non-Goals section | Non-Goals prevent scope creep. Always include them |
| Generic user stories | "As a user, I want a good experience" is not a user story |
| PRD contains implementation details | No code, schema, or class names — requirements only |

## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-tasks** | After PRD is approved — implementation + tests + YARD + docs + review tasks |
| **ticket-planning** | When the plan also needs Jira-ready tickets, classification, or sprint placement |
| **rails-architecture-review** | When PRD reveals architectural concerns |
| **rails-engine-author** | When the PRD is clearly for a mountable engine or host-app integration |
| **rails-stack-conventions** | When PRD is for a Rails feature |
