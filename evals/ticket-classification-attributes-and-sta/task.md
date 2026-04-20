# Sprint Planning: Google OAuth Login Feature

## Problem/Feature Description

A B2B SaaS startup is preparing their next two-week sprint. The product manager has outlined a new feature: allow users to sign in with their Google account in addition to the existing email/password flow. The feature touches the Rails backend (OAuth callback endpoint, user creation/lookup), the React web frontend (login button and redirect handling), and the mobile app team is evaluating whether to include it in the same sprint.

The engineering lead has asked for a full set of draft tickets to bring into sprint planning. There is no existing project management tool integration — the team just wants well-structured markdown drafts they can paste into Jira. The initiative is straightforward and the plan is already clear: no re-planning is needed.

Your job is to take the initiative description above and produce draft tickets for the engineering team. Each ticket should be self-contained enough that a developer could pick it up independently. The team uses a standard sprint structure: infrastructure and API enablers should be ready before client-side tickets.

## Output Specification

Produce a single file `tickets.md` containing all draft tickets in sequence.

For each ticket include:
- The ticket title (with appropriate area prefix)
- All classification attributes (listed together, before the ticket body, in a simple key: value block)
- The full ticket body using the standard section structure

Also produce a `sequencing_notes.md` that briefly explains (3–5 sentences) the order the tickets should be worked on and why.

Do NOT create any issues in an external system — drafts only.
