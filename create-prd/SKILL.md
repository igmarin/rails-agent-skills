---
name: create-prd
description: >
  Generates a clear, actionable Product Requirements Document (PRD) in Markdown
  from a feature description. Use when a user asks to plan a feature, define
  requirements, create a PRD, or write a product spec. Covers goals, user stories,
  requirements, and non-goals for Rails-oriented workflows.
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
- Call out effects on **middleware, callbacks, or workers** in **Technical Considerations** or **Non-Functional Requirements** when relevant.
- After approval, typical next step is **generate-tasks** (see **Next Steps** in the template).
