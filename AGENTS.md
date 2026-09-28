# Repository guidance

- `directory.json` is the registry. Keep each registered skill path valid.
- Continue only work authorized by the user; obtain authorization before beginning additional work or actions that require it.
- Use the `ruby-rails` profile with `ruby-core-skills`; the shared router is in `agnostic-planning-skills`.
- Behavior changes need focused evidence. Reviews, docs, setup, and mechanical changes do not inherit a TDD gate.
- Pause only for production data, security/authorization, deployment, irreversible actions, or unverified external APIs.
- Keep Rails-specific procedures here and Ruby language patterns in ruby-core-skills.
- Run `scripts/validate-skills.sh` after registry changes.
