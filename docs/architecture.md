# Repository boundaries

- `rails-agent-skills` owns Rails-specific implementation and review procedures.
- `ruby-core-skills` owns Ruby language patterns and shared Ruby workflows.
- `agnostic-planning-skills` owns the profile-aware `work-router` and cross-project planning skills.

Install the `ruby-rails` profile to use this pack with its Ruby foundation. The router chooses one next skill; invoke a specialist directly when the task is already clear.

## Repository map

- `skills/`: one `SKILL.md` per Rails capability. `directory.json` is the skill registry; `skills.sh.json` is the installer manifest.
- `docs/`: maintainer documentation; no persona chains or duplicate skill catalog.
- `scripts/`: validators and opt-in utilities.
- `personal-evals/`: evaluation fixtures, not runtime prompt content.

Every required rule belongs in its `SKILL.md`. Linked references are optional and are not auto-loaded by `scripts/eval_context_builder.rb`.
