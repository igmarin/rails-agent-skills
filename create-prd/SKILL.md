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

## Process

1. **Receive prompt:** User provides a feature description or request.
2. **Socratic questioning phase:**
   - If the prompt is **already detailed** (clear goal, scope, and success criteria), skip clarifying questions and generate the PRD directly.
   - If anything is **ambiguous**, ask only the most essential questions (3-5 max). Understand "what" and "why", not "how". Use letter/number options for quick answers.
   - Ask one question at a time when possible — do not overwhelm with a wall of questions.
3. **Identify implementation surface:** Note which Rails areas the feature will touch: `controllers`, `models`, `services`, `jobs`, `mailers`, `engines`, or external integrations. This feeds directly into section 8 of the PRD.
4. **Generate PRD:** Use the structure below. Derive `[feature-name]` from the feature (lowercase, hyphenated slug, e.g. `user-onboarding`, `export-csv`).
5. **Save:** Save as `tasks/prd-[feature-name].md` in `/tasks/`. Create the directory if it does not exist.
6. **Verify:** Re-read the saved file and confirm it matches the agreed scope. In your reply, include this exact line: `Recommended next step: generate-tasks — break this PRD into implementation tasks with TDD gates.`
7. **Do NOT** start implementing the PRD — that is the user's decision after review.

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
| 8 | **Implementation Surface** | REQUIRED — name the specific Rails layers this feature will touch (e.g. `controllers`, `models`, `services`, `jobs`, `mailers`). Describe entry points and architectural areas in plain language — do NOT include class names, module paths, or code. |
| 9 | **Success Metrics** | How success is measured |
| 10 | **Open Questions** | Anything still to be decided |

## Output Style

Every PRD invocation MUST end the reply (after confirming the file was saved) with a **Recommended next step** line. Pick one from the list below — never omit this line, even when the user has not asked for next steps.

```text
Recommended next step: <skill-name> — <one-line reason>.
```

Allowed skills for the next-step line:

- **generate-tasks** — default when the PRD is approved and implementation is next
- **ticket-planning** — when tracker-ready tickets or sprint placement are needed
- **rails-architecture-review** — when the PRD surfaces structural concerns
- **rails-engine-author** — when the PRD scopes a mountable engine
- **rails-stack-conventions** — when the PRD is a Rails feature needing stack alignment

If none of the above clearly fits, default to `generate-tasks`.

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Vague requirements ("make it fast", "good UX") | Every requirement must use "must" and be testable |
| Skipping Non-Goals section | Non-Goals prevent scope creep. Always include them |
| Generic user stories | "As a user, I want a good experience" is not a user story |
| Generic Implementation Surface | "The Rails app" or "controllers and models" is insufficient — name the specific Rails layers and areas, e.g. `admin inventory controller`, `background import job`, `inventory validation service layer` |
## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-tasks** | After PRD is approved — implementation + tests + YARD + docs + review tasks |
| **ticket-planning** | When the plan also needs tracker-ready ticket drafts, classification, or sprint placement |
| **rails-architecture-review** | When PRD reveals architectural concerns |
| **rails-engine-author** | When the PRD is clearly for a mountable engine or host-app integration |
| **rails-stack-conventions** | When PRD is for a Rails feature |
