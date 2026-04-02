# Skill Architecture — Rails Agent Skills

Conventions and structure for every `SKILL.md` in this library.

- **Overview and catalog:** [README](../README.md)
- **Install and hooks:** [implementation-guide.md](implementation-guide.md)
- **Workflow chains:** [workflow-guide.md](workflow-guide.md)

## Directory Structure

```text
rails-agent-skills/
├── .claude-plugin/          # Claude Code plugin metadata
│   ├── plugin.json
│   └── marketplace.json
├── .codex/                  # Codex installation instructions
│   └── INSTALL.md
├── .cursor-plugin/          # Cursor plugin metadata
│   └── plugin.json
├── hooks/                   # Session hooks
│   ├── hooks.json
│   └── session-start
├── docs/                    # Documentation
│   ├── implementation-guide.md
│   ├── architecture.md
│   ├── workflow-guide.md
│   └── skill-template.md
├── rails-agent-skills/      # Bootstrap skill (loaded at session start)
│   └── SKILL.md
├── <skill-name>/            # One directory per skill
│   ├── SKILL.md             # Main skill file (required)
│   └── reference.md         # Optional reference material
├── README.md
└── .gitignore
```

## SKILL.md Structure

Every skill follows this structure:

### 1. YAML Frontmatter (Required)

```yaml
---
name: skill-name
description: >
  Use when [concrete trigger conditions]. Covers [key topics].
  [Additional trigger words for discovery].
---
```

**Rules:**

- `name`: kebab-case, matches directory name
- `description`: starts with "Use when...", third person
- Include concrete trigger words (error symptoms, tools, scenarios)
- Do NOT summarize the workflow (prevents model from skipping the skill body)
- Max 1024 characters total for frontmatter

### 2. Title and Core Principle

```markdown
# Skill Title

Use this skill when [brief trigger].

**Core principle:** [One sentence philosophy]
```

### 3. Quick Reference (High Priority)

A scannable table at the top for fast lookup:

```markdown
## Quick Reference

| Aspect | Rule |
|--------|------|
| ... | ... |
```

### 4. HARD-GATE (Where Applicable)

Non-negotiable blockers in a code block:

```markdown
## HARD-GATE

\```
DO NOT [forbidden action].
ALWAYS [required action].
\```
```

### 5. Core Rules / Process

The main instructions. Use numbered steps for processes, bullet lists for rules.

### 6. Common Mistakes (High Priority)

Table format with "Mistake" and "Reality" columns:

```markdown
## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Excuse or bad practice" | Why it's wrong and what to do instead |
```

### 7. Red Flags (High Priority)

Bullet list of signals that the skill is being violated:

```markdown
## Red Flags

- Signal that something is wrong
- Another signal
```

### 8. Integration (Medium Priority)

Table of related skills and when to chain them:

```markdown
## Integration

| Skill | When to chain |
|-------|---------------|
| **other-skill** | When [condition] |
```

## Frontmatter Optimization (CSO)

"Claude Search Optimization" — how the description helps AI agents find the right skill:

1. Start with "Use when..." (activation trigger)
2. Include concrete nouns: "controller", "migration", "factory"
3. Include action verbs: "reviewing", "creating", "fixing"
4. Include symptoms: "N+1", "fat model", "flaky tests"
5. Do NOT summarize the workflow (the model will skip reading the body)

**Good:**

```yaml
description: >
  Use when reviewing Rails pull requests, checking controller conventions,
  or validating migration safety. Covers routing, query optimization, security.
```

**Bad:**

```yaml
description: >
  This skill reviews code by checking routing, then controllers, then models,
  then queries, then migrations, then security, then caching.
```

## Skill Types

### Rigid Skills

Follow exactly. Do not adapt away discipline.

- `rspec-best-practices` (tests gate / TDD discipline)
- `refactor-safely` (characterization tests hard-gate)
- `rails-migration-safety` (phased rollout hard-gate)

### Flexible Skills

Adapt principles to context.

- `rails-stack-conventions`
- `rails-code-conventions`
- `ticket-planning`
- `ruby-service-objects`
- `rails-background-jobs`
- `ddd-rails-modeling`

### Review Skills

Produce findings with severity levels.

- `rails-code-review` — giving a review
- `rails-review-response` — receiving and responding to feedback (split from `rails-code-review`)
- `rails-architecture-review`
- `rails-security-review`
- `rails-engine-reviewer`
- `ddd-boundaries-review`

## Workflow Checkpoints

Beyond HARD-GATEs (which block entirely), some skills use **checkpoints** — explicit pause-and-confirm steps that require user approval before continuing. Checkpoints differ from gates in that they pause for collaboration, not to enforce a rule.

### Test Feedback Checkpoint

Defined in: `rails-tdd-slices` (step after writing the first failing spec).

Purpose: Present the failing test(s) to the user before implementation begins. Confirm:
- Is the right behavior being tested?
- Is the boundary correct (request vs service vs model)?
- Are edge cases represented?

Only proceed to the Implementation Proposal once the test design is approved.

### Implementation Proposal Checkpoint

Defined in: `rspec-best-practices` (step in the gate cycle between test validation and implementation).

Purpose: Before writing implementation code, propose the approach in plain language:
- Which classes and methods will be created or changed?
- Rough structure and dependencies
- Any risks or flags

Wait for confirmation before writing code. This prevents surprise implementations that require full rewrites.

### Linters + Full Test Suite Gate

Defined in: `docs/workflow-guide.md` (TDD Feature Loop), `rails-code-review`.

Purpose: Run linters (`bundle exec rubocop` or project equivalent) and the full test suite before proceeding to YARD documentation or PR. Fix all failures before continuing.

## Platform Compatibility

All skills use standard Markdown and YAML frontmatter, which is compatible across:

| Platform | How skills are loaded |
|----------|----------------------|
| **Cursor** | Read from `~/.cursor/skills/` directories |
| **Codex** | Read from `~/.codex/skills/` directories |
| **Claude Code** | Loaded via `.claude-plugin/plugin.json` |

Platform-specific features (hooks, commands, agents) are handled by the infrastructure files, not the skills themselves.
