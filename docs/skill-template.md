# Skill Template

Use this template when creating a new skill for the library.

**For detailed guidance on skill design, read the official [Skill Design Principles](skill-design-principles.md).**

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
  [Concise paragraph (1-3 sentences). First sentence states primary purpose.
  Focus on trigger words and outcomes for LLM discovery].
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

## Checkpoints

<!-- Only include if the skill introduces a pause-and-confirm step (not a hard blocker).
     Checkpoints differ from HARD-GATEs: they pause for collaboration, not to enforce a rule. -->

### [Checkpoint Name]

1. Present: [what to show the user]
2. Ask: [specific questions to confirm before proceeding]
3. Confirm: [what approval looks like — only proceed once confirmed]

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

Refer to the [Skill Design Principles](skill-design-principles.md) for all naming, description, content, and formatting conventions.





### Sections Priority

Refer to the [Skill Design Principles](skill-design-principles.md) for required sections and their priority.

### Progressive Disclosure

Refer to the [Skill Design Principles](skill-design-principles.md) for guidance on progressive disclosure.

### Create vs Extend

Refer to the [Skill Design Principles](skill-design-principles.md) for guidance on when to create a new skill versus extending an existing one.

### Quality Checklist

Refer to the [Skill Design Principles](skill-design-principles.md) for the comprehensive quality checklist.

### Adding to the Library

1. Create the directory and SKILL.md
2. Add the skill to the catalog table in `README.md`
3. Update the Mermaid relationship diagram in `README.md` if the skill connects to existing skills
4. Add the skill to the `rails-agent-skills/SKILL.md` discovery table
5. Add the skill to `CLAUDE.md` skill catalog (this is the first file Claude reads)
6. Add the skill to any related skills' Integration tables
