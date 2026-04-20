# Skill Design Principles

This document outlines the core principles for designing and maintaining high-quality skills within this project. Adhering to these principles ensures that skills are effective for AI agents (like Gemini CLI, Claude, Windsurf, Cursor, etc.), maintainable by humans, and provide clear, actionable guidance.

---

### The 6 Principles of High-Quality Skill Design

1. **Concise & Descriptive Metadata:**
  - **YAML `name`**: Must be lowercase, `snake_case`, and match the directory name.
  - **YAML `description`**: A concise paragraph (ideally 1-3 sentences). The first sentence should state the primary purpose. Focus on trigger words and outcomes for easy LLM discovery.
2. **Tool-Agnostic & Portable:**
  - **Focus on Principles, Not Tools**: Generalize specific tool names (e.g., `linter` instead of `RuboCop`, `API collection` instead of `Postman`). Exceptions are allowed for terms tightly coupled to a community standard (e.g., `graphql-ruby`, `RSpec`).
  - **Use Standard Markdown**: Ensure content is portable and renders correctly on any platform. Avoid custom syntax unless absolutely necessary and documented.
3. **Robust & Enforceable Workflows:**
  - **HARD-GATES**: Use for non-negotiable rules that prevent critical errors, security risks, or workflow violations. Keep them short, in ALL CAPS, and briefly explain *why* they are critical (e.g., "DO NOT implement code before tests").
  - **Explicit Steps**: Use numbered lists or tables for clear, sequential processes (e.g., `Review Order`, `Release Order`, `Process` sections).
  - **Checkpoints**: Define explicit points where user interaction, approval, or specific verification is required before proceeding.
  - **Integration Tables**: Clearly show how the skill chains with other skills in common workflows.
4. **Clear & Actionable Content Structure:**
  - **Quick Reference**: Provide a scannable table at the top for experienced users to quickly grasp key aspects.
  - **When to Use**: Clearly define the scenarios or trigger phrases that should invoke the skill.
  - **Common Mistakes / Red Flags**: Use these sections to highlight anti-patterns, critical warning signs, and behaviors to avoid.
  - **What Good Looks Like**: When applicable, provide a positive vision, best practices, or a checklist for successful outcomes.
  - **Severity Levels**: When applicable (e.g., in review skills), define a clear system for categorizing findings (e.g., Critical, Suggestion, Nice to have).
5. **Illustrative Code Examples:**
  - **"Good" vs. "Bad" Examples**: Where applicable, show both a good practice and a common bad practice side-by-side (or in sequential "Good" then "Bad" blocks), with clear, concise explanations of why one is better.
  - **Contextual & Copyable**: Ensure examples are realistic for the domain (Rails/Ruby) and can be easily copied and adapted.
  - **Avoid Fragmentation**: Keep examples focused and avoid breaking them into too many small snippets if a larger, coherent block is more illustrative.
6. **LLM-Friendly Language & Formatting:**
  - **Conciseness**: Keep all sections (especially descriptions, rules, and explanations) as concise as possible without losing meaning. Avoid conversational filler.
  - **Structure over Prose**: Maximize readability and parseability by using tables, bulleted lists, numbered lists, and clear headings. Avoid long blocks of unstructured text.
  - **Consistent Terminology**: Use consistent terms across skills (e.g., "linter," "API collection") to reduce ambiguity for AI agents.

---

### See Also

- [skill-structure.md](skill-structure.md) — the canonical 6-section SKILL.md shape every skill must converge on (Frontmatter → Quick Reference → HARD-GATE → Core Process → Output Style → Integration). Use this as the structural checklist when authoring or reinforcing a skill.
- [skill-optimization-guide.md](skill-optimization-guide.md) — the eval-driven loop for lifting baseline-vs-context scores; tells you *which* skill to reinforce next.
- [skill-template.md](skill-template.md) — fillable template that already follows `skill-structure.md`.

