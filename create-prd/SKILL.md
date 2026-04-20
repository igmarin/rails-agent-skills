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

A PRD is a *what/why* document — never include code, pseudo-code, SQL, class names, method signatures, or migration syntax. Naming a model or controller for scope is fine; writing its methods is not.

1. **Save to** `/tasks/prd-<feature-slug>.md` (lowercase, kebab-case slug — e.g. `/tasks/prd-google-oauth-login.md`). State the path in your response.
2. **Follow [PRD_TEMPLATE.md](./PRD_TEMPLATE.md) section by section**, in order. Every section appears, even if short or marked "TBD".
3. **Functional Requirements** are written in natural language ("the system must send a confirmation email when…"), not Ruby.
4. **Next Steps** closes the PRD with the suggested follow-on (typically: "Run `generate-tasks` against this PRD once approved.").
5. **English** unless the user explicitly requests another language.

After saving, surface the file path and request explicit approval before any implementation or task generation.
