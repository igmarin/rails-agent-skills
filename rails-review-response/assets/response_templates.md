# Review response templates

Templates to respond to common reviewer comments with clarity and code references.

1) Agree & implement

Thanks — good catch. I will:
- Add a unit spec covering this case (spec/path)
- Move logic into Service::Name and update controller to call it
- Update README with usage

2) Clarify & propose minimal change

Thanks for the note. I think the current behavior was intentional because X. Proposal:
- Apply a small guard in controller
- Add request spec verifying behavior
- Keep current API for backwards compatibility

3) Disagree respectfully

Thanks for the review. I believe changing this would break existing integrations because Y. Proposed alternative:
- Keep current behavior but add a deprecation note and feature flag
- Follow up in a separate PR to avoid expanding scope of this change

Helpful tips:
- Always reference the failing test line or example
- Provide a short code diff snippet when possible
- Offer to follow up in a new PR if the change is large
