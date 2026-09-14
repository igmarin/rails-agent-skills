# TDD Proof Checklist

Use this checklist when writing or reviewing specs for new behavior.

- [ ] State the selected spec type and why it is the smallest strong boundary.
- [ ] Show the exact spec file path.
- [ ] Write the first failing example before implementation.
- [ ] Run the focused spec command.
- [ ] State the expected RED failure message and confirm it is not setup-related.
- [ ] Include the actual expected failure class or matcher text, for example `NoMethodError: undefined method 'admin?'`, `NameError: uninitialized constant`, `ActionController::RoutingError`, or an explicit expectation failure.
- [ ] Implement only the minimal behavior needed.
- [ ] Re-run the same focused spec and confirm GREEN.
- [ ] Run the full relevant spec file.
- [ ] Run the broader suite (show standard green suite run output).
- [ ] Scan example descriptions for `and`; split any multi-behavior examples.
- [ ] Wrap related assertions in `aggregate_failures` so the artifact demonstrates all related expectations.
- [ ] Confirm time-dependent assertions use `travel_to` or `freeze_time`.
