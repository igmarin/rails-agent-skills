---
name: create-prd
description: >
  Generates a clear, actionable Product Requirements Document (PRD) in Markdown
  from a feature description and saves it to /tasks/prd-<feature-slug>.md. Use
  when a user asks to plan a feature, define requirements, create a PRD, or
  write a product spec. Covers goals, user stories, functional requirements,
  non-goals, design and technical considerations, implementation surface, success
  metrics, and open questions for Rails-oriented workflows. Trigger words: PRD,
  product requirements, plan a feature, write a spec, requirements document,
  /tasks/ folder.
---

# Generating a Product Requirements Document (PRD)

Focus on *what* and *why*, not *how*. No code until the PRD is approved.

## Process

1. **Receive prompt** — feature description or request.
2. **Clarify only if needed** — if the goal, scope, and success signals are already clear, skip questions and draft the PRD. If ambiguous, ask **3–5** targeted questions (see [assets/prd_questions.md](./assets/prd_questions.md) for areas to pull from).
3. **Draft** — fill **[PRD_TEMPLATE.md](./PRD_TEMPLATE.md)** section by section (canonical order and Rails-oriented fields). Do not invent a parallel outline.
4. **Validate** — present the PRD; get **explicit approval** before implementation, tasks, or code.

## Outputs & references

| Asset | Use |
|-------|-----|
| [PRD_TEMPLATE.md](./PRD_TEMPLATE.md) | Mandatory Markdown structure every PRD follows |
| [assets/prd_questions.md](./assets/prd_questions.md) | Clarification inventory (not an obligatory 12-question form) |
| [assets/examples.md](./assets/examples.md) | Short one-pager + full PRD example aligned to the template |

## Rails-specific notes

- Mention Rails only when it **constrains scope** (auth, jobs, timeouts, conventions), not as step-by-step implementation.
- Call out effects on **middleware, callbacks, or workers** in **Design and Technical Considerations** or **Non-Functional Requirements** when relevant.

## Output Style

When asked to plan a feature or write a PRD, your output MUST include EVERY item below.

1. **Save location** — write the PRD to `/tasks/prd-<feature-slug>.md` (slug is lowercase, kebab-case, derived from the feature name, e.g. `/tasks/prd-google-oauth-login.md`). State the path explicitly in your response. Do not ask the user where to save — `/tasks/` is the canonical location.
2. **All ten sections present**, in this order, even if a section is short or marked "TBD":
   - Introduction / Overview
   - Goals
   - User Stories
   - Functional Requirements
   - Non-Goals (Out of Scope)
   - Design and Technical Considerations
   - Implementation Surface (files, endpoints, jobs, models likely touched)
   - Success Metrics
   - Open Questions
   - Next Steps (typically: hand off to `generate-tasks`)
3. **What/why focus** — describe observable user-facing behavior and the business reason. Do NOT include code, pseudo-code, SQL, class names, method signatures, or migration syntax. Naming a model or controller for scope context is fine; writing its methods is not.
4. **No implementation code** — Functional Requirements use natural language ("the system MUST send a confirmation email when..."), not Ruby snippets.
5. **Next Steps section closes the PRD** with the suggested follow-on (typically: "Run `generate-tasks` against this PRD once approved.").
6. **English** — content in English unless the user explicitly requests another language.

After saving, surface the file path to the user and request explicit approval before any implementation, task generation, or code follows.
