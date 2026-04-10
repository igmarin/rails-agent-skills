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
7. **Do NOT** start implementing the PRD. Always suggest the recommended next step: **generate-tasks** (for implementation checklist with TDD sequencing, YARD, docs, and code review gate) and optionally **ticket-planning** (for Jira-ready tickets). Name the skill explicitly so the user can invoke it.

## PRD Structure

Include **all 10 sections** — none are optional. Sections with nothing to say get a one-line placeholder (e.g. "No open questions at this stage."). See [PRD_TEMPLATE.md](./PRD_TEMPLATE.md) for the ready-to-fill template.

| # | Section | Purpose |
|---|---------|---------|
| 1 | **Introduction** | What it is and what problem it solves |
| 2 | **Goals** | Measurable objectives |
| 3 | **User Stories** | One per key flow: "As a [role], I want [action] so that [benefit]" |
| 4 | **Functional Requirements** | Numbered must-have behaviors — testable |
| 5 | **Non-Goals** | What this version will NOT include |
| 6 | **Design Considerations** | UI/UX notes, mockup links, pending design decisions |
| 7 | **Technical Considerations** | Constraints, dependencies, performance concerns |
| 8 | **Implementation Surface** | Rails areas touched: `controllers`, `services`, `jobs`, `engines`, etc. — no code |
| 9 | **Success Metrics** | How success is measured |
| 10 | **Open Questions** | Anything still to be decided |

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
