# Skill Template

Use this template when creating a new skill for the library.

## File Structure

```
my-cursor-skills/
└── your-skill-name/
    ├── SKILL.md          # Required: main skill file
    └── reference.md      # Optional: supplementary reference material
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
- Do NOT summarize the workflow
- Max 1024 characters total for frontmatter

### Content
- Write in English
- Use numbered steps for processes
- Use tables for structured comparisons
- Use code blocks for examples
- Use `HARD-GATE` or `EXTREMELY-IMPORTANT` for non-negotiable rules
- Include both "good" and "bad" examples where helpful

### Sections Priority
1. Quick Reference (always include)
2. Common Mistakes (always include)
3. Red Flags (always include)
4. Integration (always include)
5. HARD-GATE (only when the skill has non-negotiable rules)

### Adding to the Library
1. Create the directory and SKILL.md
2. Add the skill to the catalog table in README.md
3. Add the skill to the `using-my-skills/SKILL.md` discovery table
4. Update the mermaid relationship diagram if the skill connects to existing skills
5. Add the skill to any related skills' Integration tables
