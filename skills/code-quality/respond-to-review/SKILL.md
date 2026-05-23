---
name: respond-to-review
license: MIT
description: >
  Applies when a developer has received code review feedback on Rails code and needs to decide
  what to implement, how to respond, and in what order. Use when addressing PR comments,
  pull request feedback, or review comments on Rails code. Covers evaluating reviewer
  suggestions, pushing back with technical reasoning, avoiding performative agreement,
  implementing feedback safely one item at a time, and triggering a re-review when needed.
  Trigger scenarios: respond to reviewer, address review comments, handle pull request feedback.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Respond to Review

## Quick Reference

| Category | Description | Action |
|----------|-------------|--------|
| **Correct + Critical** | Real security, crash, or data risk | Fix immediately, re-review |
| **Correct + Suggestion** | Real improvement, not blocking | Fix in this PR or ticket follow-up |
| **Correct + Nice to have** | Style, minor optimization | Optional — acknowledge explicitly |
| **Incorrect** | Reviewer lacks context or misread the code | Push back with technical reasoning |
| **Ambiguous** | Unclear what change is actually requested | Clarify before implementing |

## HARD-GATE

```text
WHEN receiving code review feedback:

1. READ:      Read all feedback completely before reacting
2. UNDERSTAND: Restate each point as a technical requirement
3. VERIFY:    Check the suggestion against the actual codebase
4. EVALUATE:  Is this technically sound for THIS codebase?
5. RESPOND:   Technical acknowledgment, clarifying question, or reasoned pushback
6. IMPLEMENT: One item at a time — test after each change
7. RE-REVIEW: Trigger a re-review if any Critical items were addressed

DO NOT start implementing before completing steps 1-4.
```

## Core Process

### Forbidden Responses

Never respond with performative agreement that skips verification. See [assets/response_templates.md](assets/response_templates.md) for copy-ready patterns and a full list of forbidden phrases.

The key rule: restate the technical requirement, ask clarifying questions, push back with reasoning if wrong, or start implementing one item after reading all feedback — never commit without verifying first.

### Evaluating Feedback

Before implementing any suggestion, classify it based on the Quick Reference table above.

### Pushing Back

Push back when a suggestion is technically incorrect for the codebase. Use this structure:

1. Acknowledge what the reviewer is concerned about
2. Explain the relevant codebase constraint or reason
3. Propose an alternative if one exists, or explain why no change is needed

```text
"I see the concern about N+1 here. In this case the association is already
preloaded at line 42 via `includes(:orders)`. Adding another `eager_load`
would run a duplicate JOIN. Happy to add a comment clarifying this if helpful."
```

**Never:** Push back without technical evidence. If unsure, verify before claiming it's fine.

### Implementation Order (Multi-Item Feedback)

1. **Clarify** anything ambiguous FIRST — before touching code
2. **Critical** blocking issues (crashes, security, data loss)
3. **Simple** fixes (typos, naming, missing requires)
4. **Complex** changes (refactoring, logic changes)
5. **Test** each fix individually — run the relevant spec after each change
6. **Verify** no regressions — run full suite before requesting re-review

### Re-Review Trigger

After implementing feedback, decide whether to request a re-review:

| Situation | Action |
|-----------|--------|
| Any Critical finding was addressed | Request re-review — mandatory |
| 3+ Suggestion items changed logic | Request re-review — recommended |
| Only Nice to have or cosmetic fixes | Comment what was done — no re-review needed |
| Architecture or class structure changed | Request re-review — mandatory |

### Common Mistakes & Red Flags

| Mistake / Red Flag | Reality |
|--------------------|----------|
| Closing review comments without verifying | Comment what you checked and why you agree or disagree |
| All review comments closed without any pushback | May indicate blind compliance — verify each item independently |

## Extended Resources

- [assets/response_templates.md](assets/response_templates.md) provide copy-ready response patterns for common review outcomes, including the full list of forbidden response phrases.

## Output Style

When responding to review feedback, output:

1. **Scope** — State that the user received review feedback on their own Rails code; if the task is asking you to give a review instead, use `code-review`.
2. **Feedback table** — For each reviewer point, include: restated technical requirement, code checked, classification, decision, and response.
3. **Verification evidence** — Name the exact file, method, line, spec, or behavior checked before agreeing, implementing, or pushing back.
4. **Reasoned pushback** — When a suggestion is incorrect, use the pushback structure: reviewer concern, codebase constraint/evidence, and alternative or no-change rationale. Never push back without technical evidence.
5. **Implementation order** — List fixes one item at a time, with relevant spec after each logic change and full-suite regression check before re-review.
6. **Re-review decision** — State whether re-review is mandatory, recommended, or unnecessary based on Critical fixes, logic changes, architecture changes, or cosmetic-only work.
7. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | The counterpart — use when giving a review, not receiving |
| **write-tests** | Run the TDD loop after implementing feedback that changes logic |
| **refactor-code** | When feedback suggests a larger structural change |
| **security-check** | When Critical feedback involves security — get a dedicated review |
