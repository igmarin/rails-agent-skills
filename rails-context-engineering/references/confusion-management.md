# Confusion Management — Surface Ambiguity, Never Silently Choose

Progressive-disclosure reference. Read when the Context Summary detects a conflict, a missing requirement, or spec/code drift.

## Principle

When two patterns coexist, requirements conflict, or specs disagree with code, **silently picking is the highest-risk failure mode**. The user's context-window is the source of truth for disambiguation — ask, do not guess.

## When to emit a Confusion Block

Emit a Confusion Block whenever any of the following is true after loading context:

| Trigger | Example |
|---------|---------|
| Two patterns in the same repo | Services split between `{ success:, response: }` hashes and `Dry::Monads::Result` |
| Spec passes against stale behavior | Spec asserts `status: 200` but code returns `201` and neither is recently changed |
| Requirement omitted | PRD says "user can cancel subscription" — no mention of refund behavior |
| Domain term drift | Same concept called `Plan`, `Tier`, and `Subscription::Level` across layers |
| Boundary ambiguity | Change could live in host app or in mounted engine — neither is wrong on its own |
| Version/gem mismatch | Feature requires Rails 7.1+ but `Gemfile.lock` shows 7.0 |
| Authorization gap | Endpoint being modified has no `before_action :authorize` and no Pundit policy nearby |

## Confusion Block format

After the Context Summary, attach:

```text
### Confusion Block
Ambiguity: <one-line description of the conflict>

Evidence:
- <path:line> — <what that file shows>
- <path:line> — <what the other file shows>

Options:
A. <option one — named, with consequence>
B. <option two — named, with consequence>
(C. <third if relevant>)

Recommendation: <A/B/C> — <one-line reason>
Needed from you: <specific question, yes/no or A/B/C>
```

Rules:

1. **Describe the conflict first.** One line. No preamble.
2. **Cite both sides.** Evidence must include at least two `path:line` citations that produce the ambiguity.
3. **Name the options.** Generic "we could do A or B" is not enough — each option has a name and a consequence.
4. **Give a recommendation** with a single-line reason. You are not abdicating, you are flagging.
5. **End with a closed question.** Binary or A/B/C — not "what do you want?". The user should be able to answer in one word.

## Examples

### Example 1 — service return-shape conflict

```text
### Confusion Block
Ambiguity: Two service return conventions coexist in this repo.

Evidence:
- app/services/billing/charge_service.rb:22 — returns `{ success: true, response: { charge_id: ... } }`
- app/services/onboarding/create_user_service.rb:18 — returns `Success(user)` / `Failure(:invalid_email)` (Dry::Monads)

Options:
A. Match billing pattern (hash) — consistent with most recent services, no new gem
B. Match onboarding pattern (Dry::Monads) — richer failure types, requires teaching callers

Recommendation: A — matches the cross-cutting convention in CLAUDE.md (`{ success:, response: }`).
Needed from you: A or B?
```

### Example 2 — spec vs code drift

```text
### Confusion Block
Ambiguity: Spec asserts behavior the code no longer performs.

Evidence:
- spec/models/subscription_spec.rb:44 — expects `subscription.active?` to be false after 30 days
- app/models/subscription.rb:78 — `active?` currently checks only `status: :active`, not time

Options:
A. Fix the code to match the spec (time-based `active?`)
B. Fix the spec to match the code (status-only `active?`)
C. Neither — the spec is testing a dropped requirement; delete the example

Recommendation: B — a git blame on subscription.rb shows the time check was removed in a refactor 4 months ago; the spec was left stale.
Needed from you: A, B, or C?
```

### Example 3 — engine vs host boundary

```text
### Confusion Block
Ambiguity: The new feature could live in the host app or in the `Billing::Engine`.

Evidence:
- engines/billing/lib/billing/engine.rb:1 — isolate_namespace Billing; owns Subscription, Invoice, Plan
- app/controllers/accounts_controller.rb:40 — host owns Account → Subscription wiring via a cross-boundary call

Options:
A. Host app — consistent with current Account wiring, ships faster
B. Billing engine — keeps billing logic inside the engine boundary, matches isolate_namespace intent

Recommendation: B — the feature is a billing concept; adding it to the host perpetuates the boundary leak.
Needed from you: A or B?
```

## Anti-patterns

| Don't | Do |
|-------|-----|
| "I'll go with option A unless you say otherwise." | End with a closed question — wait for the answer |
| "There are some differences here." (vague) | Name the conflict in one line, cite both sides |
| Offer five options | Two, maximum three — otherwise you are offloading the decision you should have made |
| Confusion Block without a recommendation | Always recommend — your job is to reduce decision load, not add to it |
| Silently picking and noting "we can revisit" | Never ship a silent choice when the Confusion Block applies |

## After the block is answered

Once the user picks an option, update the Context Summary with a one-line `Resolved:` note pointing back to the Confusion Block so the choice is auditable:

```text
### Context Summary
- ...
- Confusion: RESOLVED — chose A (hash-style service return) per user 2026-04-18
```

Then proceed with the next skill.
