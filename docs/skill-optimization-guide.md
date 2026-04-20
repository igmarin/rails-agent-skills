# Skill Optimization Guide — Rails Agent Skills

A systematic process for improving tessl evaluation scores across all skills in this library.

## Overview

This guide provides a repeatable workflow for diagnosing and fixing skill evaluation failures. It was developed while optimizing `rails-engine-release` and is designed to be applicable to any skill in the library.

## Library Baseline — 2026-04-20

Full-library eval on `claude-sonnet-4-6` (32 scenarios, tile `igmarin/rails-agent-skills`):

- **With-context avg: 100%** (28 scenarios at 100%, 4 at 98–99%)
- **Baseline avg: 78%** — the score any Sonnet-4.6 agent produces *without* this library loaded
- **Average lift: +22 points** — the value this library adds on top of the base model

### Why the 78% baseline is the right number, not a regression target

Per the library's eval strategy: *a skill that only beats baseline marginally is under-specified.* The gap between baseline and with-context is the **signal that skills are earning their token cost**. Chasing the baseline up means codifying what the model already knows — bloat without signal.

What this means in practice:

- **Low-lift scenarios** (e.g. S23 Fitness Class Booking: 100% baseline, 100% with-context) — the base model already handles the convention. The matching skill is decorative for this case; keep it for edge-case coverage, not for lift.
- **High-lift scenarios** (e.g. S32 ticket-planning: 30% → 100%, +70; S8 API client: 40% → 100%, +60) — the matching skill is doing real work. These skills are the library's load-bearing beams.
- **Zero-baseline criteria** (e.g. S24 Task 0.0 feature branch, TDD run-spec-fail, YARD gate — all 0% at baseline) are **training-knowledge gaps**, not signal problems. They exist only in this library. The with-context score is the true measure.

### Top-10 skills ranked by lift (what the library actually buys)

| Scenario | Skill | Baseline | With ctx | Lift |
|----------|-------|----------|----------|------|
| S32 | ticket-planning | 30% | 100% | **+70** |
| S8  | ruby-api-client-integration | 40% | 100% | **+60** |
| S24 | generate-tasks | 43% | 100% | **+57** |
| S13 | ruby-api-client-integration | 45% | 100% | **+55** |
| S4  | refactor-safely | 60% | 100% | **+40** |
| S14 | create-prd | 62% | 100% | **+38** |
| S10 | rails-code-conventions (logging + backtrace) | 65% | 100% | **+35** |
| S3  | ruby-service-objects | 71% | 100% | **+29** |
| S12 | rails-graphql-best-practices | 71% | 100% | **+27** |
| S27 | yard-documentation (inline tagged notes) | 76% | 100% | **+24** |

### How to use this baseline in future optimization cycles

1. **Regression guard:** if a future eval run drops any scenario below its 2026-04-20 with-context score, that scenario regressed — find the change that caused it.
2. **Low-lift flag:** if a new scenario lands with <10 points of lift, either the skill is redundant for that case or the scenario isn't testing skill content. Fix the scenario or retire the skill's coverage of that case.
3. **Model-bump recheck:** when a new Claude model ships, re-run baseline-only. If baseline creeps up significantly, some skills may become optional — candidates for slimming, not for new requirements.

## Prerequisites

- Access to `tessl` CLI with eval capabilities
- Understanding of the Agent Skills specification
- Familiarity with the skill's domain (Rails, testing, etc.)

## The Optimization Process

### Step 0: Review Skill Quality (tessl skill review)

Before running scenario evaluations, check the skill's intrinsic quality score:

```bash
tessl skill review --optimize rails-engine-release
```

This analyzes the skill file itself for:
- Description clarity and trigger coverage
- Structure and organization
- Content completeness
- Instruction specificity

**Example improvement:**
- Initial: 94% (good but room for improvement)
- Changes: Tightened Output Style section, made Versioning Rules more concise
- Result: 100% (fully optimized)

This step catches skill-level issues before running expensive scenario evaluations.

### Step 1: Analyze Current Scores

Run the evaluation and identify failing criteria:

```bash
tessl eval view --last
```

Document the scores for both scenarios:
- **Baseline (without context)**: Skill not loaded, agent uses only training knowledge
- **With context**: Skill loaded, agent has access to all files in the skill directory

### Step 2: Identify Score Patterns

Compare the two scenarios to understand the problem type:

| Pattern | Meaning | Solution Approach |
|---------|---------|-------------------|
| Baseline low, With-context high | Skill provides necessary guidance | Good - skill is valuable |
| Baseline high, With-context low | Context dilution or conflicting signals | **Fix**: Reduce noise, strengthen signal |
| Both low | Missing or incorrect instructions | **Fix**: Add explicit requirements |
| Both high | Skill is well-optimized | Document as reference |

### Step 3: Root Cause Analysis

For each failing criterion, determine the root cause:

#### A. Missing Output Requirements
**Symptom**: Agent doesn't mention required element in output
**Fix**: Add explicit requirement to **Output Style** section

Example from `rails-engine-release`:
```markdown
## Output Style

When asked to prepare a release, your output MUST include:

5. **Gemspec verification** — Explicitly state that gemspec metadata 
   (authors, description, files, dependencies) was verified
6. **Test suite status** — Confirm the full test suite passes 
   (`bundle exec rspec`) before proceeding
```

#### B. Context Dilution
**Symptom**: Scores drop when more files are present
**Fix**: Implement **progressive disclosure**

1. Tell the agent when to load auxiliary files:
```markdown
## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/checklist.md](assets/checklist.md)** — Use when you need 
  detailed verification steps
- **[references/advanced.md](references/advanced.md)** — Use for edge cases 
  or complex scenarios
```

2. Remove or fix confusing auxiliary files:
- Fix circular references
- Use relative paths (not absolute with skill name)
- Remove redundant content

#### C. Signal Burial
**Symptom**: Important instruction exists but agent doesn't prioritize it
**Fix**: Move to prominent position with explicit imperative language

- Use **MUST** for requirements, not "should" or "consider"
- Place in Quick Reference or Output Style sections
- Use bold formatting for key terms

### Step 4: Implement Fixes

Priority order for maximum score improvement:

1. **Output Style section** (highest impact for baseline scores)
   - Add numbered list of required output elements
   - Map each criterion to an explicit requirement

2. **Progressive disclosure** (highest impact for with-context scores)
   - Tell agent WHEN to load auxiliary files
   - Fix or remove confusing files in `assets/`, `references/`

3. **Quick Reference table** (medium impact for both)
   - Ensure all high-scoring criteria appear here
   - Use scannable format for fast lookup

4. **HARD-GATE section** (if applicable)
   - Reinforce non-negotiable requirements

### Step 5: Verify Improvements

Run the evaluation again:

```bash
tessl eval run --skill rails-engine-release
```

Verify both scenarios achieve 100% or acceptable threshold.

Iterate if needed: return to Step 1 with new scores.

## Common Fixes Reference

### Gemspec Verification (8 points)

**Problem**: Agent doesn't mention verifying gemspec metadata

**Solution**: Add to Output Style:
```markdown
5. **Gemspec verification** — Explicitly state that gemspec metadata 
   (authors, description, files, dependencies) was verified against 
   tested Rails/Ruby versions
```

### Test Suite Mention (8 points)

**Problem**: Agent doesn't confirm test suite passes

**Solution**: Add to Output Style:
```markdown
6. **Test suite status** — Confirm the full test suite passes 
   (`bundle exec rspec`) before proceeding to build
```

### Upgrade Notes (10 points)

**Problem**: Agent doesn't produce upgrade instructions for host apps

**Solution**: 
- Add to Output Style with explicit template
- Create `assets/upgrade_template.md` for reference
- Reference it with progressive disclosure

### Blockers Called Out (8 points)

**Problem**: Agent doesn't mention blockers or state "no blockers"

**Solution**: Add to Output Style:
```markdown
7. **Release blockers** — Call out any open issues preventing release, 
   or explicitly state "No blockers"
```

## Case Study: rails-engine-release

### Initial State

| Check | Baseline | With Context |
|-------|----------|--------------|
| Gemspec verified | 2/8 (25%) | 5/8 (63%) |
| Test suite mentioned | 7/8 (88%) | 8/8 (100%) |
| Upgrade notes produced | 3/10 (30%) | 10/10 (100%) |
| **Total** | **86/100** | **97/100** |

### Root Causes Identified

1. **Context dilution**: `assets/examples.md` had circular references and wrong paths
2. **Missing output requirements**: Output Style section didn't explicitly require gemspec mention
3. **No progressive disclosure**: Asset files loaded automatically, adding noise

### Fixes Applied

1. Rewrote `assets/examples.md` with clear relative paths and loading instructions
2. Rewrote **Output Style** section with 7 explicit requirements mapping to criteria
3. Added **Extended Resources** section telling agent when to load assets

### Result

- Baseline improved: 86% → 100%
- With context maintained: 97% → 100%

## Case Study: generate-tasks

### Initial State

| Check | Baseline | With Context |
|-------|----------|--------------|
| Feature branch task 0.0 | 0/10 (0%) | 10/10 (100%) |
| TDD write-spec sub-task | 3/10 (30%) | 10/10 (100%) |
| TDD run-spec-fail sub-task | 0/10 (0%) | 10/10 (100%) |
| TDD run-spec-pass sub-task | 0/8 (0%) | 8/8 (100%) |
| YARD post-implementation gate | 0/10 (0%) | 10/10 (100%) |
| Relevant Files section | 0/8 (0%) | 8/8 (100%) |
| **Total** | **43/100** | **100/100** |

### Root Causes Identified

1. **Missing Output Style section** — All requirements were in HARD-GATE code block, but no explicit "output MUST include" list
2. **Weak frontmatter signals** — Description didn't include "feature branch", "TDD", "write spec", "run spec" as trigger words
3. **Rules present but not prioritized** — The TDD quadruplet structure existed but wasn't surfaced for baseline performance

### Fixes Applied

1. Added **Output Style** section with 7 explicit requirements mapping directly to evaluation criteria:
   - Task 0.0 with feature branch command
   - Relevant Files section requirement
   - TDD quadruplets (write spec → run fail → implement → run pass)
   - YARD parent task
   - Documentation update task
   - Code review gate
   - Save location specification

2. Rewrote **frontmatter description** to include explicit trigger words:
   - "Task 0.0 Create feature branch"
   - "TDD quadruplets: write spec → run spec (fail) → implement → run spec (pass)"
   - Added trigger words: feature branch, TDD, write spec, run spec

### Result

- Baseline improved: 43% → 100% (target)
- With context maintained: 100% → 100%

### Pattern: Baseline Low, With-Context High

When you see this pattern, first determine if it's a **signal problem** or a **training knowledge gap**:

**Signal Problem** (fixable):
- Baseline scores are partial (30-70%) on criteria
- Agent attempts the requirement but incorrectly
- **Fix**: Add **Output Style** section with MUST requirements, strengthen **frontmatter description**

**Training Knowledge Gap** (inherent limitation):
- Baseline scores are 0% on highly specific conventions
- Agent has no concept of the requirement (e.g., Task 0.0, TDD quadruplets, YARD gates)
- These conventions exist only in this skill library, not in general training data
- **Reality**: Some baseline scores cannot be improved - the skill's value IS the context it provides

**For generate-tasks:**
- 0% on Task 0.0, TDD run-spec-fail/pass, YARD gate, Relevant Files = training gap
- 100% on file paths, save location, code review = general knowledge
- **With-context score (100%) is the true measure of skill quality**

## Template for New Skills

Use this structure to maximize eval scores from the start. The same six sections are codified in [skill-structure.md](skill-structure.md) — that doc is the canonical SKILL.md shape the reinforcement pass enforces; this template is the fillable version.

```markdown
---
name: skill-name
description: >
  Use when [concrete trigger]. Covers [specific topics].
  Trigger words: [symptom], [tool], [scenario].
---

# Skill Title

Use this skill when [brief trigger description].

## Quick Reference

| Aspect | Rule |
|--------|------|
| [Key point] | [Specific rule] |
| [Key point] | [Specific rule] |

## HARD-GATE (if applicable)

```
DO NOT [forbidden action].
ALWAYS [required action].
```

## Core Process

1. [Step with specific command or pattern]
2. [Step with specific command or pattern]
3. [Step with specific command or pattern]

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[assets/template.md](assets/template.md)** — Use when [specific condition]
- **[references/advanced.md](references/advanced.md)** — Use when [specific condition]

## Output Style

When asked to [task], your output MUST include:

1. **[Criterion name]** — [Explicit requirement]
2. **[Criterion name]** — [Explicit requirement]
3. **[Criterion name]** — [Explicit requirement]

## Examples

[Minimal working example]

## Integration

| Skill | When to chain |
|-------|---------------|
| [skill-name] | When [condition] |
```

## Next Steps: Optimizing Other Skills

Use this guide as the starting point for fixing any skill in the library:

### Quick Start for a New Skill

```bash
# 1. Check skill quality first
tessl skill review --optimize <skill-name>

# 2. Run scenario evaluations
tessl eval run . --variant without-context --variant with-context

# 3. View specific failures
tessl eval view --last

# 4. Follow this guide's workflow (Step 0 → Step 5)
```

### Systematic Improvement

For each skill below 100%:

1. **Start with Step 0** — Skill-level quality via `tessl skill review --optimize`
2. **Move to Step 1** — Scenario scores via `tessl eval view --last`
3. **Apply targeted fixes** — Use the Common Fixes Reference section
4. **Iterate** — Re-run evaluations until 100% achieved

### Skills to Review

Priority order for optimization:
- High impact: Skills with large eval point values
- Low hanging fruit: Skills close to 100% needing minor tweaks
- New skills: Apply this process from creation to avoid rework

Document new patterns discovered in the Maintainer Notes section.

---

**Maintainer Notes:**
- This guide is a living document. Update with new patterns as they're discovered.
- When adding a new skill, start from this template to minimize optimization needs later.
