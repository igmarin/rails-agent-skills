# Skill Template

Use this template when creating a new skill for the library.

Prefer improving an existing skill before creating a new one. Create a new skill only when the workflow has a distinct trigger, a different decision tree, or a HARD-GATE that would bloat another skill.

## Before You Write

Capture these decisions first:

1. **Purpose:** What specific workflow or decision should this skill improve?
2. **Trigger:** What user language or repo context should cause the agent to read it?
3. **Boundary:** What belongs in this skill vs a related existing skill?
4. **Verification:** What evidence proves the skill was followed correctly?
5. **Integration:** What skill usually comes before and after it?

If you cannot answer those five clearly, refine an existing skill instead of creating a new one.

## File Structure

```text
rails-agent-skills/
└── your-skill-name/
    ├── SKILL.md          # Required: main skill file
    ├── reference.md      # Optional: supplementary reference material
    └── examples.md       # Optional: example outputs or edge cases
```

## SKILL.md Template

```markdown
---
name: your-skill-name
description: >
  Use when [concrete trigger conditions that help AI agents discover this skill].
  Covers [key topics, tools, patterns]. Also applies when [alternative triggers].
---

# Your Skill Title

Use this skill when [brief one-line trigger].

**Core principle:** [One sentence that captures the skill's philosophy]

## Quick Reference

| Aspect | Rule |
|--------|------|
| Key concept 1 | Brief rule |
| Key concept 2 | Brief rule |
| Key concept 3 | Brief rule |

## HARD-GATE

<!-- Only include if the skill has non-negotiable rules -->

\```
DO NOT [forbidden action that must never be skipped].
ALWAYS [required action that must always happen].
\```

## When to Use

- Trigger condition 1
- Trigger condition 2
- **Next step:** [What to suggest after this skill completes]

## Process

1. **Step name:** Description of what to do.
2. **Step name:** Description of what to do.
3. **Step name:** Description of what to do.
4. **Verify:** Run verification and confirm results with evidence.

## Examples

**Good:**

\```ruby
# Good example with explanation
\```

**Bad:**

\```ruby
# Bad example with explanation of why it's bad
\```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Common excuse or bad practice" | Why it's wrong and what to do instead |
| "Another common mistake" | The correct approach |

## Red Flags

- Signal that the skill is being violated
- Another warning sign
- Pattern that indicates a problem

## Integration

| Skill | When to chain |
|-------|---------------|
| **related-skill-1** | When [condition triggers the related skill] |
| **related-skill-2** | When [condition triggers the related skill] |
```

## Conventions

### Naming

- Directory name: `kebab-case` (e.g., `rails-code-review`)
- `name` in frontmatter: matches directory name exactly
- Skill title in H1: human-readable (e.g., "Rails Code Review")

### Description (CSO - Claude Search Optimization)

- Start with "Use when..."
- Include concrete trigger words (error names, tool names, patterns)
- State both **what** the skill covers and **when** it applies
- Do NOT summarize the workflow
- Max 1024 characters total for frontmatter

### Content

- Write in English
- **Generated output** (documentation, YARD comments, Postman collections, examples) must be in **English** unless the user explicitly requests another language
- Use numbered steps for processes
- Use tables for structured comparisons
- Use code blocks for examples
- Use `HARD-GATE` or `EXTREMELY-IMPORTANT` for non-negotiable rules
- Include both "good" and "bad" examples where helpful
- Keep `SKILL.md` focused; move detailed examples, edge cases, or large references into `reference.md` / `examples.md`
- Prefer Rails-real terminology and file paths over generic abstractions
- If style/tooling matters, tell the agent to detect and run the project's linter/test command instead of assuming one tool

### Sections Priority

1. Quick Reference (always include)
2. Common Mistakes (always include)
3. Red Flags (always include)
4. Integration (always include)
5. HARD-GATE (only when the skill has non-negotiable rules)

### Progressive Disclosure

- Put only the minimum durable instructions in `SKILL.md`
- Put longer examples, deeper rationale, or exhaustive matrices in `reference.md`
- Put output samples or before/after examples in `examples.md`
- Link directly to those files from `SKILL.md`; avoid deep nesting

### Create vs Extend

Create a **new skill** when:

- the trigger language is distinct
- the workflow has a unique decision tree
- the verification loop differs from existing skills
- the skill will be reused independently in many tasks

Extend an **existing skill** when:

- the new guidance is just another branch of an existing workflow
- the same trigger already applies
- the same HARD-GATE and integration chain still fit
- a new file would fragment discovery instead of improving it

### Quality Checklist

Before finalizing a skill, verify:

- [ ] The description is specific and includes trigger terms
- [ ] The skill states both WHAT it covers and WHEN to use it
- [ ] The main workflow is concise and actionable
- [ ] The skill uses Rails/Ruby file paths or terms when relevant
- [ ] The verification step is explicit
- [ ] Related skills are named in `Integration`
- [ ] `HARD-GATE` exists if the workflow has non-negotiable blockers
- [ ] Large examples were moved out of `SKILL.md` when they add noise

### Adding to the Library

1. Create the directory and SKILL.md
2. Add the skill to the catalog table in README.md
3. Add the skill to the `rails-agent-skills/SKILL.md` discovery table
4. Update the mermaid relationship diagram if the skill connects to existing skills
5. Add the skill to any related skills' Integration tables
