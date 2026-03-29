---
name: rails-review-response
description: >
  Use when you have received code review feedback on Rails code and need to decide
  what to implement, how to respond, and in what order. Covers evaluating reviewer
  suggestions, pushing back with technical reasoning, avoiding performative agreement,
  implementing feedback safely one item at a time, and triggering a re-review when needed.
---

# Rails Review Response

Use this skill when **you have received review feedback** on your own Rails code (PR comments, pair review, async review). This is the counterpart to **rails-code-review**, which covers *giving* a review.

**Core principle:** Verify before implementing. Technical acknowledgment over performative agreement. Re-review after significant changes.

## HARD-GATE: Receiving Review Feedback

```
WHEN receiving code review feedback:

1. READ:      Read all feedback completely before reacting
2. UNDERSTAND: Restate each point as a technical requirement
3. VERIFY:    Check the suggestion against the actual codebase
4. EVALUATE:  Is this technically sound for THIS codebase?
5. RESPOND:   Technical acknowledgment, clarifying question, or reasoned pushback
6. IMPLEMENT: One item at a time — test after each change
7. RE-REVIEW: Trigger a re-review if any Critical items were addressed
```

**DO NOT start implementing before completing steps 1-4.**

## Forbidden Responses

These responses skip verification and add zero signal:

| Forbidden | Why |
|-----------|-----|
| "You're absolutely right!" | Performative — confirms nothing was verified |
| "Great point!" / "Excellent feedback!" | Performative — signals compliance, not understanding |
| "Let me implement that now" | Skips verification — reviewer may lack codebase context |
| "I'll fix all of these" | Batch commitment before evaluating each item individually |

**Instead:** Restate the technical requirement, ask clarifying questions, push back with reasoning if wrong, or just start implementing one item after reading all feedback.

## Evaluating Feedback

Before implementing any suggestion, classify it:

| Category | Description | Action |
|----------|-------------|--------|
| **Correct + Critical** | Real security, crash, or data risk | Fix immediately, re-review |
| **Correct + Suggestion** | Real improvement, not blocking | Fix in this PR or ticket follow-up |
| **Correct + Nice to have** | Style, minor optimization | Optional — acknowledge explicitly |
| **Incorrect** | Reviewer lacks context or misread the code | Push back with technical reasoning |
| **Ambiguous** | Unclear what change is actually requested | Clarify before implementing |

## Pushing Back

Push back when a suggestion is technically incorrect for the codebase. Use this structure:

1. Acknowledge what the reviewer is concerned about
2. Explain the relevant codebase constraint or reason
3. Propose an alternative if one exists, or explain why no change is needed

```
"I see the concern about N+1 here. In this case the association is already
preloaded at line 42 via `includes(:orders)`. Adding another `eager_load`
would run a duplicate JOIN. Happy to add a comment clarifying this if helpful."
```

**Never:** Push back without technical evidence. If unsure, verify before claiming it's fine.

## Implementation Order (Multi-Item Feedback)

1. **Clarify** anything ambiguous FIRST — before touching code
2. **Critical** blocking issues (crashes, security, data loss)
3. **Simple** fixes (typos, naming, missing requires)
4. **Complex** changes (refactoring, logic changes)
5. **Test** each fix individually — run the relevant spec after each change
6. **Verify** no regressions — run full suite before requesting re-review

## Re-Review Trigger

After implementing feedback, decide whether to request a re-review:

| Situation | Action |
|-----------|--------|
| Any Critical finding was addressed | Request re-review — mandatory |
| 3+ Suggestion items changed logic | Request re-review — recommended |
| Only Nice to have or cosmetic fixes | Comment what was done — no re-review needed |
| Architecture or class structure changed | Request re-review — mandatory |

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Implementing all feedback immediately | Verify each item first — some suggestions may be wrong |
| Treating all feedback as equally urgent | Classify by severity — Critical before cosmetic |
| Closing review comments without verifying | Comment what you checked and why you agree or disagree |
| Skipping re-review after Critical fixes | A fix can introduce new issues — re-review is mandatory |
| Asking for re-review after cosmetic changes | Wastes reviewer time — only request when logic changed |

## Red Flags

- Implementing feedback before reading all of it
- "Fixed!" comment with no technical explanation
- All review comments closed without any pushback (may indicate blind compliance)
- Tests not run after implementing a fix
- Re-review skipped after a Critical item was addressed

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-code-review** | The counterpart — use when giving a review, not receiving |
| **rspec-best-practices** | Run the TDD loop after implementing feedback that changes logic |
| **refactor-safely** | When feedback suggests a larger structural change |
| **rails-security-review** | When Critical feedback involves security — get a dedicated review |
