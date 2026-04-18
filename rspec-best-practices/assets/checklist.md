# RSpec Best Practices — Checklist

- Always prefer `let`/`let!` sparingly; use `build`/`create` explicitly when reading tests is easier
- Keep tests isolated; prefer doubles for external APIs
- Use `aggregate_failures` when asserting multiple related items
- Keep time-dependent tests deterministic with `travel_to`
- Use `have_enqueued_job` and `perform_enqueued_jobs` for job assertions
- Tests are the gate: WRITE -> RUN -> FAIL -> IMPLEMENT -> PASS
