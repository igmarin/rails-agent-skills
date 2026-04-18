# PRD Example (short)

Name: Search Autocomplete
Summary: Improve search UX by providing real-time autocomplete suggestions.

Problem: Users struggle to find items quickly; searches without suggestions return many irrelevant results.

Goal: Increase successful search completions by 15% in 3 months.

User story: As a user, I want inline suggestions while typing so I can select a result without completing the full query.

Acceptance criteria:
- Given the user types >= 2 chars, when suggestions exist, then show up to 5 relevant suggestions within 150ms.
- Given network errors, show graceful fallback and allow manual search.

Rollout: Feature flag, 10% -> 50% -> 100% with metrics check at each step.

Checklist:
- [ ] Tasks generated
- [ ] Specs added
- [ ] Frontend component tests
- [ ] Backend endpoint tests
- [ ] Monitoring dashboards

