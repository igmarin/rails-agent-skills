# create-prd — examples

Short discovery shape (when the user wants a one-pager before a full PRD):

Name: Search Autocomplete
Summary: Improve search UX by providing real-time autocomplete suggestions.

Problem: Users struggle to find items quickly; searches without suggestions return many irrelevant results.

Goal: Increase successful search completions by 15% in 3 months.

User story: As a user, I want inline suggestions while typing so I can select a result without completing the full query.

Acceptance criteria:

- Given the user types >= 2 chars, when suggestions exist, then show up to 5 relevant suggestions within 150ms.
- Given network errors, show graceful fallback and allow manual search.

Rollout: Feature flag, 10% → 50% → 100% with metrics check at each step.

Checklist:

- [ ] Tasks generated
- [ ] Specs added
- [ ] Frontend component tests
- [ ] Backend endpoint tests
- [ ] Monitoring dashboards

---

## Full PRD (follows [PRD_TEMPLATE.md](../PRD_TEMPLATE.md))

**Input (feature description):**
Add the ability for admins to export user data as a CSV file from the Rails admin dashboard.

**Output:**

```markdown
# PRD: Admin CSV User Export

## Introduction

Admin users need to export a filtered list of user records as CSV from the admin dashboard for audits and reporting, without direct database access.

## Goals

- Admins can download user data without direct database access.
- Export completes in under 5 seconds for up to 10,000 records.
- Exported data respects existing admin permission scopes.

## User Stories

- As an admin, I want to export all users as a CSV so that I can share data with the ops team.
- As an admin, I want to filter users before exporting so that I only download relevant records.

## Functional Requirements

1. The system must show an **Export CSV** action on the admin users index page.
2. The system must trigger a `.csv` download when the admin confirms export, including columns: id, email, created_at, role, status.
3. The system must apply the same filters as the index (e.g. role, status) to the exported row set.

## Non-Functional Requirements

- Only users with the `admin` role can trigger an export.
- Exports larger than 10,000 rows must run via a background job and notify the admin (e.g. email with download link) to avoid request timeouts.

## Non-Goals

- Exporting associated records (orders, sessions, etc.).
- Custom column selection in v1.
- Scheduled or automated exports.

## Design Considerations

- Reuse existing admin index filters and table affordances; export entry point should be obvious and hard to trigger accidentally.

## Technical Considerations

- Prefer Active Job for large exports; consider streaming CSV for medium sizes if product wants synchronous download for <10k rows only.

## Implementation Surface

Rails areas likely touched (no code — discovery only):

- `controllers/` — admin users controller (or equivalent namespace)
- `models/` — `User` scopes for filtering
- `services/` — optional `UserCsvExport` orchestration
- `jobs/` — background export + delivery when row count exceeds threshold
- `mailers/` — export ready / link to file
- External integrations — none

## Success Metrics

- Median export time < 5s for ≤10k visible rows on staging hardware.
- Zero unauthorized export attempts succeeding (covered by policy/request specs).

## Open Questions

- Should each export be logged for audit (who, when, filter snapshot)?
- Hard cap on rows per export (product/legal)?

## Next Steps

Recommended next step: **generate-tasks** — break this PRD into implementation tasks with TDD gates.

Alternative chain targets: `ticket-planning`, `rails-architecture-review`, `rails-stack-conventions`.
```
