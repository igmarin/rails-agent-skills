# skill-router — Routing Examples

Extended routing examples covering common, ambiguous, and edge-case scenarios. Each example shows the user prompt, skill match rationale, and the full workflow chain.

Active responses must put `Next skill: ...` first. When multiple skills may apply, put one concise priority/chain statement immediately after it, before analysis or implementation.

---

## Single-Skill Routes (Clear Intent)

### 1. Write PRD

> **User:** "Write a PRD for adding multi-tenant support to the billing service."
>
> **Match:** Explicit planning request with clear scope.
>
> **Chain:** `load-context` → `create-prd`
>
> **Next skill: skills/context/load-context**

### 2. Triage Bug

> **User:** "Triage a 500 error observed in orders#create when item_id is nil."
>
> **Match:** Concrete bug with reproduction path. Do not reach for `optimize-performance` or `code-review` until the bug is isolated.
>
> **Chain:** `triage-bug` → `agents/tdd`
>
> **Next skill: skills/testing/triage-bug**

### 3. Review Rails Engine

> **User:** "Review my mountable engine for host-app integration risks and namespace leakage."
>
> **Match:** Engine-scoped review, not a general code review.
>
> **Chain:** `review-engine`
>
> **Next skill: skills/engines/review-engine**

### 4. Create Service Object

> **User:** "I need a service to sync users from our Salesforce CRM every night."
>
> **Match:** Service extraction + external API integration. Two skills apply.
>
> **Chain:** `load-context` → `integrate-api-client` (API layer) → `create-service-object` (orchestration service) → `write-tests` (spec)
>
> **Next skill: skills/context/load-context**

### 5. Safe Migration

> **User:** "I need to add a column to users but we can't afford downtime."
>
> **Match:** Production-safe schema change.
>
> **Chain:** `review-migration`
>
> **Next skill: skills/infrastructure/review-migration**

---

## Multi-Concern Routes (Workflow Chains)

### 6. Full Feature from Scratch

> **User:** "I want to add a payment feature but I'm not sure where to start."
>
> **Match:** Scope unclear, no existing PRD, vague starting point.
>
> **Chain:** `load-context` → `create-prd` → `generate-tasks` → `plan-tests` → `agents/tdd`
>
> **Next skill: skills/context/load-context**

### 7. Multi-Concern PR

> **User:** "I have a PR that adds a new controller, changes the Order model, adds a migration, and introduces a service object."
>
> **Match:** Multi-concern changeset. Decompose before reviewing.
>
> **Chain:** `load-context` → `security-check` (if auth/input handling touched) → `review-migration` (migration) → `review-architecture` (service/model boundary) → `code-review` (controller + model + tests)
>
> **Next skill: skills/context/load-context**
>
> **Priority: security-check > review-migration > review-architecture > code-review; Chain: load-context then security-check, review-migration, review-architecture, code-review.**

### 7b. Multi-Concern Engine PR

> **User:** "Review this engine PR. It changes the install generator, adds copied migrations, mounts routes in the dummy app, and touches authorization."
>
> **Match:** Multi-concern engine changeset. Do not collapse this to a single code review.
>
> **Chain:** `load-context` → `security-check` (authorization) → `review-migration` (copied migrations) → `review-engine` (host integration, dummy app, namespace) → `code-review` (final branch diff)
>
> **Next skill: skills/context/load-context**

### 8. DDD-First Feature

> **User:** "We're building an invoicing module and need to get the domain language right before coding."
>
> **Match:** Domain modeling before implementation.
>
> **Chain:** `load-context` → `define-domain-language` → `review-domain-boundaries` → `model-domain` → `create-prd` → `generate-tasks` → `agents/tdd`
>
> **Next skill: skills/context/load-context**

### 9. GraphQL API Feature

> **User:** "Build a GraphQL API for our product catalog with filtering and pagination."
>
> **Match:** GraphQL-specific, not REST. Do not use `generate-api-collection`.
>
> **Chain:** `define-domain-language` → `implement-graphql` → `agents/tdd` → `security-check`
>
> **Next skill: skills/ddd/define-domain-language**

### 10. New Rails Engine

> **User:** "Extract our notification system into a mountable engine."
>
> **Match:** Engine extraction from existing code, not greenfield authoring.
>
> **Chain:** `load-context` → `extract-engine` → `test-engine` → `document-engine` → `release-engine`
>
> **Next skill: skills/context/load-context**

---

## Ambiguous & Low-Context Routes

### 11. Vague Request — No Clear Skill

> **User:** "Help me improve this Rails app."
>
> **Match:** No specific concern. Start with context discovery to identify what needs work.
>
> **Chain:** `load-context` → (assess findings) → route to appropriate skill
>
> **Next skill: skills/context/load-context**

### 12. Ambiguous — Architecture vs Code Review

> **User:** "This codebase feels messy, can you take a look?"
>
> **Match:** "Messy" suggests structural issues, not a specific PR. Use architecture review, not code review.
>
> **Chain:** `load-context` → `review-architecture` → (if refactoring needed) `refactor-code`
>
> **Next skill: skills/context/load-context**

### 13. Ambiguous — Which Test Skill?

> **User:** "I need to add tests for the billing module."
>
> **Match:** "Add tests" is ambiguous. If the user doesn't know *what* to test first → `plan-tests`. If they know what but not *how* → `write-tests`.
>
> **Disambiguation:** Ask: "Do you know which behavior to test first, or should we figure that out?" If unclear, default to `plan-tests`.
>
> **Next skill: skills/testing/plan-tests**

### 14. Ambiguous — Performance vs Bug

> **User:** "The checkout page is really slow sometimes."
>
> **Match:** Could be a performance issue or a latent bug. "Sometimes" suggests intermittent, which leans bug. Clarify, but default to `triage-bug` if there's no profiling data yet.
>
> **Disambiguation:** Ask: "Is it consistently slow or only under specific conditions?" Default to bug triage if intermittent.
>
> **Next skill: skills/testing/triage-bug**

### 15. Zero Context — New to Project

> **User:** "I just joined this team, where do I start?"
>
> **Match:** Onboarding, not planning or coding.
>
> **Chain:** `setup-environment` → `load-context`
>
> **Next skill: skills/context/setup-environment**

---

## Edge Cases

### 16. User Asks for Tickets Explicitly

> **User:** "Create Jira tickets from this task list."
>
> **Match:** Explicit ticket request. Do not generate tickets unless explicitly asked.
>
> **Chain:** `plan-tickets`
>
> **Next skill: skills/planning/plan-tickets**

### 17. Security Concern Mid-Feature

> **User:** "Wait, does this endpoint have proper authorization?"
>
> **Match:** Security concern interrupting a feature workflow. Route to security review, then return to previous workflow.
>
> **Chain:** `security-check` → (if policies needed) `implement-authorization` → resume prior workflow
>
> **Next skill: skills/code-quality/security-check**

### 18. Refactoring with No Tests

> **User:** "I want to refactor this controller but there are no tests."
>
> **Match:** Refactoring requires characterization tests first. TDD gate applies.
>
> **Chain:** `load-context` → `write-tests` (write characterization tests) → **[GATE: tests pass on current code]** → `refactor-code`
>
> **Next skill: skills/context/load-context**

### 19. Background Job Design

> **User:** "We need to process invoice PDFs asynchronously."
>
> **Match:** Background job with potential service object and external integration.
>
> **Chain:** `load-context` → `implement-background-job` → `create-service-object` (if job logic is complex) → `write-tests`
>
> **Next skill: skills/context/load-context**

### 20. Hotwire Frontend Work

> **User:** "Make this form submit without a full page reload using Turbo."
>
> **Match:** Frontend-specific, Hotwire/Turbo integration.
>
> **Chain:** `load-context` → `implement-hotwire` → `agents/tdd` (system specs)
>
> **Next skill: skills/context/load-context**
