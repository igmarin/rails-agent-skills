---
name: review
license: MIT
description: >
  Multi-pass Rails code review loop that identifies bugs, security vulnerabilities, and architectural issues; assigns severity levels (Critical, Suggestion, Nice-to-have); and generates actionable review comments with a mandatory re-review loop for Critical findings. Use for full PR reviews, multi-pass security or architecture audits, or implementing and verifying responses to review feedback. Trigger: review this PR, full code review, multi-pass review, audit security vulnerabilities, review architecture, respond to review feedback, implement review fixes.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when conducting full PR review, multi-pass security/architecture audit, or implementing review feedback"
  phases: "Phase 1: Systematic Review, Phase 2: Deep Dive, Phase 3: Respond"
  hard_gates: "Security Check, Architecture Check, Findings Assessment, Re-review for Critical"
  dependencies: "code-review, security-check, review-architecture, respond-to-review"
  keywords: rails, review, audit, security, architecture, agent, pr, feedback
---
# Review Agent

Orchestrates systematic code review with optional deep dives for security/architecture and response handling.

## Agent Phases

### Phase 1: Systematic Review

**Load primary review skill:**
1. **code-review** — Systematic Rails PR review

**Concrete checklist per changed file:**
- Verify `before_action` callbacks match route constraints and cover all sensitive actions
- Check every `.save`, `.update`, `.destroy` call has error handling or a `!` bang with rescue
- Confirm strong parameters whitelist only the required attributes — no `permit!`
- Identify any `where`/`find` calls inside loops (N+1 risk) and flag for extraction
- Confirm `authorize` (or equivalent policy check) is called before rendering any resource
- Validate model associations use appropriate `dependent:` options to prevent orphaned records
- Check callbacks (`before_save`, `after_create`, etc.) for side-effects that cross domain boundaries
- Confirm test coverage exists for the changed logic path

**Output format per file:** `[CRITICAL|SUGGESTION|NICE-TO-HAVE] <file>:<line> — <finding>`

**Example Critical finding comment:**
```
[CRITICAL] app/controllers/orders_controller.rb:42 — Missing authorisation check;
  any authenticated user can access another user's order. Add `authorize @order`
  before rendering.
```

**Example Suggestion comment:**
```
[SUGGESTION] app/models/order.rb:17 — `Order.where(user: current_user)` called
  inside a loop; extract to a scoped query to avoid N+1.
```

**Decision Gate — Security Check:**
- Security concerns found? → Proceed to Phase 2 (Security)
- No security concerns → Skip to Phase 2 (Architecture check)

---

### Phase 2: Deep Dive (Optional)

**Branch A — Security Review (if triggered):**
- **skills/code-quality/security-check** — Deep security audit
  - Auth & session management
  - Authorization & IDOR
  - Input validation & SQL injection
  - Output encoding & XSS
  - Secrets handling

**Decision Gate — Architecture Check:**
- Architecture issues found? → Proceed to Architecture Review
- No architecture issues → Skip to Phase 3

**Branch B — Architecture Review (if triggered):**
- **skills/code-quality/review-architecture** — Structural review
  - Boundary recommendations
  - Extraction suggestions
  - Coupling assessment

---

### Phase 3: Respond

**Decision Gate — Findings Assessment:**

| Finding Level | Action |
|---------------|--------|
| **None/minor** | Proceed to merge |
| **Critical** | Must fix before merge |
| **Suggestion** | Fix in this PR or ticket separately |

**If Critical findings:**
1. **skills/code-quality/respond-to-review** — Evaluate and implement fixes

### TDD Enforcement for Critical Fixes

**Before implementing any code fix:**
1. **testing/plan-tests** — Choose the best test to reproduce the Critical issue
2. **testing/write-tests** — Write failing test that reproduces the Critical finding
3. **Test Verification** — Confirm test FAILS for the right reason (reproduces the issue)
4. **Fix Proposal** — Propose minimal fix to address the root cause
5. **User Approval** — Wait for explicit confirmation
6. **Implement Fix** — Apply minimal code change
7. **Verify PASS** — Confirm test now PASSES (issue is resolved)
8. **Regression Check** — Run full test suite to ensure no new issues

**HARD GATE — Fix Verification:**
- Reproduction test EXISTS and FAILS before fix (confirms issue)
- Reproduction test PASSES after fix (confirms resolution)
- Full test suite PASSES (no regressions)
- If test fails: Fix is incomplete or incorrect, revise and re-test

2. **Validation checkpoint** — For each Critical item, confirm a corresponding code change exists before marking resolved:
   - List each Critical finding by ID
   - For each: identify the changed file and line, verify the fix addresses the root cause
   - Confirm reproduction test exists and passes
   - Only mark resolved when the change is present and correct
3. **Re-review mandatory** — Return to Phase 1 (code-review)
4. Repeat until all Critical items are resolved

**Proceed-to-merge summary format:**
```
## Review Complete — Approved for Merge
- Critical findings: 0 remaining
- Suggestions addressed: <n> fixed, <n> ticketed as <TICKET-IDs>
- Files reviewed: <list>
- Re-review cycles: <n>
```

**If Suggestions only:**
1. Fix accepted items (one at a time)
2. Document deferred items as tickets
3. Proceed to merge

---

## Severity Levels

| Level | Definition | Action Required |
|-------|------------|-----------------|
| **Critical** | Security vulnerability, data loss, production risk | Fix before merge |
| **Suggestion** | Improvement opportunity, tech debt | Fix now or ticket |
| **Nice to have** | Optional enhancement | Does not block |

---

## Anti-Patterns to Avoid

- **Performative agreement:** "LGTM! Will address in follow-up" without actually fixing
- **Skipping re-review:** Critical fixes must be re-reviewed
- **Scope creep:** Don't turn review into feature work — ticket separately
